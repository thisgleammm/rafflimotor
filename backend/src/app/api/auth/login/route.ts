import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import {
  hashPassword,
  generateSessionToken,
} from "@/lib/auth";
import { successResponse, errorResponse } from "@/lib/response";

const SESSION_DURATION_DAYS = 7;

export async function POST(request: NextRequest) {
  try {
    const body = await request.json();
    const { username, password } = body;

    if (!username || !password) {
      return errorResponse("Username and password are required", 400);
    }

    // Hash password
    const hashedPassword = hashPassword(password);

    // Validate credentials
    const { data: user, error: userError } = await supabase
      .from("user")
      .select("username, fullname, role_id")
      .eq("username", username)
      .eq("password", hashedPassword)
      .maybeSingle();

    if (userError) {
      console.error("Login error:", userError);
      return errorResponse("Database error", 500);
    }

    if (!user) {
      return errorResponse("Invalid username or password", 401);
    }

    // Generate session token
    const sessionToken = generateSessionToken();
    const loginTime = new Date();
    const expiresAt = new Date(
      loginTime.getTime() + SESSION_DURATION_DAYS * 24 * 60 * 60 * 1000
    );

    // Get device info from user agent
    const userAgent = request.headers.get("user-agent") || "Unknown Device";

    // Save session to database
    const { error: sessionError } = await supabase
      .from("user_sessions")
      .insert({
        username: user.username,
        session_token: sessionToken,
        login_time: loginTime.toISOString(),
        expires_at: expiresAt.toISOString(),
        device_info: userAgent.substring(0, 255),
      });

    if (sessionError) {
      console.error("Session creation error:", sessionError);
      return errorResponse("Failed to create session", 500);
    }

    return successResponse(
      {
        username: user.username,
        fullname: user.fullname,
        role_id: user.role_id,
        session_token: sessionToken,
        expires_at: expiresAt.toISOString(),
      },
      "Login successful"
    );
  } catch (e) {
    console.error("Login error:", e);
    return errorResponse("Internal server error", 500);
  }
}
