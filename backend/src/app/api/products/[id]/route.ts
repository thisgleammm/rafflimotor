import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest, logActivity } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
  notFoundResponse,
} from "@/lib/response";

interface RouteParams {
  params: Promise<{ id: string }>;
}

// GET /api/products/:id - Get single product
export async function GET(request: NextRequest, { params }: RouteParams) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { id } = await params;
    const productId = parseInt(id);

    if (isNaN(productId)) {
      return errorResponse("Invalid product ID", 400);
    }

    const { data, error } = await supabase
      .rpc("get_products_with_stock")
      .eq("id", productId)
      .maybeSingle();

    if (error) {
      console.error("Get product error:", error);
      return errorResponse("Failed to get product", 500);
    }

    if (!data) {
      return notFoundResponse("Product not found");
    }

    return successResponse(data);
  } catch (e) {
    console.error("Get product error:", e);
    return errorResponse("Internal server error", 500);
  }
}

// PUT /api/products/:id - Update product
export async function PUT(request: NextRequest, { params }: RouteParams) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { id } = await params;
    const productId = parseInt(id);
    const body = await request.json();
    const { name, price, category_id, vehicle_type_id, image_url } = body;

    if (isNaN(productId)) {
      return errorResponse("Invalid product ID", 400);
    }

    const { error } = await supabase.rpc("update_product", {
      p_product_id: productId,
      p_name: name,
      p_price: price,
      p_category_id: category_id,
      p_vehicle_type_id: vehicle_type_id,
      p_image_url: image_url || null,
    });

    if (error) {
      console.error("Update product error:", error);
      return errorResponse(error.message || "Failed to update product", 500);
    }

    await logActivity(
      auth.username!,
      "UPDATE_PRODUCT",
      `Updated product ID: ${productId}`
    );

    return successResponse(null, "Product updated successfully");
  } catch (e) {
    console.error("Update product error:", e);
    return errorResponse("Internal server error", 500);
  }
}

// DELETE /api/products/:id - Delete product
export async function DELETE(request: NextRequest, { params }: RouteParams) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { id } = await params;
    const productId = parseInt(id);

    if (isNaN(productId)) {
      return errorResponse("Invalid product ID", 400);
    }

    const { error } = await supabase.rpc("delete_product", {
      p_product_id: productId,
    });

    if (error) {
      console.error("Delete product error:", error);
      return errorResponse(error.message || "Failed to delete product", 500);
    }

    await logActivity(
      auth.username!,
      "DELETE_PRODUCT",
      `Deleted product ID: ${productId}`
    );

    return successResponse(null, "Product deleted successfully");
  } catch (e) {
    console.error("Delete product error:", e);
    return errorResponse("Internal server error", 500);
  }
}
