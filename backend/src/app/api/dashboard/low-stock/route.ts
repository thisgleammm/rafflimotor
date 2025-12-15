import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// GET /api/dashboard/low-stock - Get low stock products
export async function GET(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { searchParams } = new URL(request.url);
    const limit = parseInt(searchParams.get("limit") || "5");
    const threshold = parseInt(searchParams.get("threshold") || "3");

    const { data, error } = await supabase
      .rpc("get_products_with_stock")
      .lte("stock", threshold)
      .order("stock", { ascending: true })
      .limit(limit);

    if (error) {
      console.error("Get low stock error:", error);
      return errorResponse("Failed to get low stock products", 500);
    }

    return successResponse(data || []);
  } catch (e) {
    console.error("Get low stock error:", e);
    return errorResponse("Internal server error", 500);
  }
}
