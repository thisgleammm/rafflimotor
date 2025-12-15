import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// GET /api/categories - Get all categories
export async function GET(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { data, error } = await supabase
      .from("category")
      .select("*")
      .order("name", { ascending: true });

    if (error) {
      console.error("Get categories error:", error);
      return errorResponse("Failed to get categories", 500);
    }

    return successResponse(data || []);
  } catch (e) {
    console.error("Get categories error:", e);
    return errorResponse("Internal server error", 500);
  }
}
