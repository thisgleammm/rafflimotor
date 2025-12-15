import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// GET /api/sales/today - Get today's sales
export async function GET(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const now = new Date();
    const startOfDay = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const endOfDay = new Date(
      now.getFullYear(),
      now.getMonth(),
      now.getDate(),
      23,
      59,
      59
    );

    const { data, error } = await supabase
      .from("sales")
      .select("*")
      .gte("created_at", startOfDay.toISOString())
      .lte("created_at", endOfDay.toISOString())
      .order("created_at", { ascending: false });

    if (error) {
      console.error("Get today sales error:", error);
      return errorResponse("Failed to get today's sales", 500);
    }

    return successResponse(data || []);
  } catch (e) {
    console.error("Get today sales error:", e);
    return errorResponse("Internal server error", 500);
  }
}
