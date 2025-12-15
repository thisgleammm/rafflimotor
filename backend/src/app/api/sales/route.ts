import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// GET /api/sales - Get sales history for a specific month
export async function GET(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { searchParams } = new URL(request.url);
    const year = parseInt(
      searchParams.get("year") || new Date().getFullYear().toString()
    );
    const month = parseInt(
      searchParams.get("month") || (new Date().getMonth() + 1).toString()
    );

    const startDate = new Date(year, month - 1, 1);
    const endDate = new Date(year, month, 1);

    // Determine caching strategy
    const today = new Date();
    const isCurrentMonth =
      today.getFullYear() === year && today.getMonth() + 1 === month;

    // Cache-Control headers
    // Current month: 10s (fresh data)
    // Past months: 1 hour (historical data rarely changes)
    const cacheControl = isCurrentMonth
      ? "public, max-age=10, stale-while-revalidate=60"
      : "public, max-age=3600, stale-while-revalidate=86400";

    const { data, error } = await supabase
      .from("sales")
      .select(
        "id, customer_name, type, service_fee, total_amount, created_at, receipt_url, payment_method"
      )
      .gte("created_at", startDate.toISOString())
      .lt("created_at", endDate.toISOString())
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Get sales history error:", error);
      return errorResponse("Failed to get sales history", 500);
    }

    // Return response with Cache-Control header
    const response = successResponse(data || []);
    response.headers.set("Cache-Control", cacheControl);
    response.headers.set("CDN-Cache-Control", cacheControl);
    response.headers.set("Vercel-CDN-Cache-Control", cacheControl);

    return response;
  } catch (e) {
    console.error("Get sales history error:", e);
    return errorResponse("Internal server error", 500);
  }
}

// POST /api/sales - Create new sale
export async function POST(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const body = await request.json();
    const {
      customer_name,
      type,
      service_fee = 0,
      items = [],
      receipt_url,
      payment_method,
    } = body;

    // Calculate total price
    let totalItemsPrice = 0;
    for (const item of items) {
      const quantity = Number(item.quantity);
      const price = Number(item.price);
      totalItemsPrice += quantity * price;
    }
    const totalPrice = Number(service_fee) + totalItemsPrice;

    // Insert sale
    const { data: sale, error: saleError } = await supabase
      .from("sales")
      .insert({
        customer_name,
        type,
        service_fee: Number(service_fee),
        total_amount: totalPrice,
        receipt_url: receipt_url || "NULL",
        user: auth.username,
        payment_method,
      })
      .select()
      .single();

    if (saleError) {
      console.error("Create sale error:", saleError);
      return errorResponse(saleError.message || "Failed to create sale", 500);
    }

    const saleId = sale.id;

    // Insert sale items and update stock
    for (const item of items) {
      const quantity = Number(item.quantity);
      const price = Number(item.price);
      const subtotal = quantity * price;

      // Insert sale detail
      const { error: detailError } = await supabase
        .from("sales_details")
        .insert({
          sale_id: saleId,
          product_id: item.product_id,
          quantity,
          price_at_sale: price,
          subtotal,
        });

      if (detailError) {
        console.error("Insert sale detail error:", detailError);
      }

      // Update stock via stock_movements
      const { error: stockError } = await supabase
        .from("stock_movements")
        .insert({
          product_id: item.product_id,
          quantity_change: -quantity,
          type: "sale",
        });

      if (stockError) {
        console.error("Insert stock movement error:", stockError);
      }
    }

    return successResponse(
      { id: saleId, total_amount: totalPrice },
      "Sale created successfully",
      201
    );
  } catch (e) {
    console.error("Create sale error:", e);
    return errorResponse("Internal server error", 500);
  }
}
