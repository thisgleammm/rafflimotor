import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { getSessionToken } from "@/lib/auth";
import { successResponse, errorResponse, unauthorizedResponse } from "@/lib/response";

export async function POST(request: NextRequest) {
  try {
    const sessionToken = getSessionToken(request);

    if (!sessionToken) {
      return unauthorizedResponse("No session token provided");
    }

    // Get session info
    const { data: session, error: sessionError } = await supabase
      .from("user_sessions")
      .select("username")
      .eq("session_token", sessionToken)
      .eq("is_active", true)
      .maybeSingle();

    if (sessionError || !session) {
      return errorResponse("Session not found or already invalidated", 400);
    }

    // Invalidate session
    const { error: updateError } = await supabase
      .from("user_sessions")
      .update({
        is_active: false,
        invalidated_at: new Date().toISOString(),
      })
      .eq("session_token", sessionToken);

    if (updateError) {
      console.error("Logout error:", updateError);
      return errorResponse("Failed to invalidate session", 500);
    }

    return successResponse(null, "Logout successful");
  } catch (e) {
    console.error("Logout error:", e);
    return errorResponse("Internal server error", 500);
  }
}
