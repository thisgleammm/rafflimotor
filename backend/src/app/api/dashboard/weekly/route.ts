import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// GET /api/dashboard/weekly - Get weekly revenue chart data
export async function GET(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { data, error } = await supabase.rpc("get_weekly_revenue_chart");

    if (error) {
      console.error("Get weekly revenue error:", error);
      return errorResponse("Failed to get weekly revenue", 500);
    }

    // Transform data for chart compatibility
    const chartData = (data || []).map(
      (item: { date_label: string; daily_revenue: number }) => ({
        date: item.date_label,
        count: item.daily_revenue,
      })
    );

    return successResponse(chartData);
  } catch (e) {
    console.error("Get weekly revenue error:", e);
    return errorResponse("Internal server error", 500);
  }
}
