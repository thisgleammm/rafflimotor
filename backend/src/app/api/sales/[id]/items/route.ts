import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

interface RouteParams {
  params: Promise<{ id: string }>;
}

// GET /api/sales/:id/items - Get items for a specific sale
export async function GET(request: NextRequest, { params }: RouteParams) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { id } = await params;
    const saleId = parseInt(id);

    if (isNaN(saleId)) {
      return errorResponse("Invalid sale ID", 400);
    }

    const { data, error } = await supabase
      .from("sales_details")
      .select("*, products(name)")
      .eq("sale_id", saleId);

    if (error) {
      console.error("Get sale items error:", error);
      return errorResponse("Failed to get sale items", 500);
    }

    // Transform data to include product_name
    const items = (data || []).map((item) => ({
      ...item,
      product_name: item.products?.name || "Unknown Product",
      products: undefined, // Remove nested object
    }));

    return successResponse(items);
  } catch (e) {
    console.error("Get sale items error:", e);
    return errorResponse("Internal server error", 500);
  }
}
