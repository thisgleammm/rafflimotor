import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest, logActivity } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// POST /api/products/stock - Add stock movement
export async function POST(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const body = await request.json();
    const { product_id, quantity, type = "manual_add" } = body;

    if (!product_id || quantity === undefined) {
      return errorResponse("product_id and quantity are required", 400);
    }

    // Insert stock movement
    const { error: stockError } = await supabase
      .from("stock_movements")
      .insert({
        product_id,
        quantity_change: quantity,
        type,
      });

    if (stockError) {
      console.error("Add stock error:", stockError);
      return errorResponse("Failed to add stock", 500);
    }

    // Update product timestamp
    const { error: updateError } = await supabase
      .from("products")
      .update({ updated_at: new Date().toISOString() })
      .eq("id", product_id);

    if (updateError) {
      console.error("Update timestamp error:", updateError);
    }

    await logActivity(
      auth.username!,
      "ADD_STOCK",
      `Added ${quantity} stock to product ID: ${product_id}`
    );

    return successResponse(null, "Stock added successfully");
  } catch (e) {
    console.error("Add stock error:", e);
    return errorResponse("Internal server error", 500);
  }
}
