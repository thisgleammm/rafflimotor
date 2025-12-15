import { NextRequest } from "next/server";
import { supabase } from "./supabase";
import CryptoJS from "crypto-js";

// Hash password dengan SHA-256 (sama dengan Flutter app)
export function hashPassword(password: string): string {
  return CryptoJS.SHA256(password).toString();
}

// Generate secure random session token
export function generateSessionToken(): string {
  const randomBytes = CryptoJS.lib.WordArray.random(32);
  return CryptoJS.enc.Base64url.stringify(randomBytes);
}

// Get session token from request header
export function getSessionToken(request: NextRequest): string | null {
  const authHeader = request.headers.get("Authorization");
  if (!authHeader || !authHeader.startsWith("Bearer ")) {
    return null;
  }
  return authHeader.substring(7);
}

// Validate session token against database
export async function validateSession(
  sessionToken: string
): Promise<{ valid: boolean; username?: string; error?: string }> {
  try {
    const { data: session, error } = await supabase
      .from("user_sessions")
      .select("username, expires_at, is_active")
      .eq("session_token", sessionToken)
      .eq("is_active", true)
      .maybeSingle();

    if (error) {
      return { valid: false, error: error.message };
    }

    if (!session) {
      return { valid: false, error: "Invalid session token" };
    }

    // Check expiration
    const expiresAt = new Date(session.expires_at);
    if (new Date() > expiresAt) {
      // Invalidate expired session
      await supabase
        .from("user_sessions")
        .update({
          is_active: false,
          invalidated_at: new Date().toISOString(),
        })
        .eq("session_token", sessionToken);

      return { valid: false, error: "Session expired" };
    }

    // Update last activity
    await supabase
      .from("user_sessions")
      .update({ last_activity: new Date().toISOString() })
      .eq("session_token", sessionToken);

    return { valid: true, username: session.username };
  } catch (e) {
    return { valid: false, error: String(e) };
  }
}

// Middleware helper to validate request
export async function authenticateRequest(
  request: NextRequest
): Promise<{ authenticated: boolean; username?: string; error?: string }> {
  const sessionToken = getSessionToken(request);

  if (!sessionToken) {
    return { authenticated: false, error: "No authorization token provided" };
  }

  const result = await validateSession(sessionToken);
  return {
    authenticated: result.valid,
    username: result.username,
    error: result.error,
  };
}

// Log activity
export async function logActivity(
  username: string,
  action: string,
  description: string
): Promise<void> {
  try {
    await supabase.from("activity_logs").insert({
      username,
      action,
      description,
    });
  } catch (e) {
    console.error("Error logging activity:", e);
  }
}
