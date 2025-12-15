import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest, logActivity } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// GET /api/products - List products with stock
export async function GET(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get("limit") || "10");
    const offset = parseInt(searchParams.get("offset") || "0");

    const { data, error } = await supabase
      .rpc("get_products_with_stock")
      .range(offset, offset + limit - 1);

    if (error) {
      console.error("Get products error:", error);
      return errorResponse("Failed to get products", 500);
    }

    return successResponse(data || []);
  } catch (e) {
    console.error("Get products error:", e);
    return errorResponse("Internal server error", 500);
  }
}

// POST /api/products - Create product with initial stock
export async function POST(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const body = await request.json();
    const { name, price, category_id, vehicle_type_id, image_url, stock } =
      body;

    if (!name || price === undefined || !category_id || !vehicle_type_id) {
      return errorResponse(
        "Name, price, category_id, and vehicle_type_id are required",
        400
      );
    }

    const { data, error } = await supabase.rpc(
      "create_product_with_initial_stock",
      {
        p_name: name,
        p_price: price,
        p_category_id: category_id,
        p_vehicle_type_id: vehicle_type_id,
        p_image_url: image_url || null,
        p_stock: stock || 0,
      }
    );

    if (error) {
      console.error("Create product error:", error);
      return errorResponse(error.message || "Failed to create product", 500);
    }

    await logActivity(
      auth.username!,
      "CREATE_PRODUCT",
      `Created product: ${name}`
    );

    return successResponse({ id: data }, "Product created successfully", 201);
  } catch (e) {
    console.error("Create product error:", e);
    return errorResponse("Internal server error", 500);
  }
}
