import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// GET /api/dashboard/monthly - Get monthly revenue
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

    const { data, error } = await supabase.rpc("get_monthly_revenue_fixed", {
      m_year: year,
      m_month: month,
    });

    if (error) {
      console.error("Get monthly revenue error:", error);
      return errorResponse("Failed to get monthly revenue", 500);
    }

    return successResponse({ revenue: Number(data) || 0, year, month });
  } catch (e) {
    console.error("Get monthly revenue error:", e);
    return errorResponse("Internal server error", 500);
  }
}
