import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// GET /api/storage/url - Get public URL for a file
export async function GET(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { searchParams } = new URL(request.url);
    const fileName = searchParams.get("fileName");
    const bucket = searchParams.get("bucket") || "productimage_bucket";

    if (!fileName) {
      return errorResponse("fileName is required", 400);
    }

    const { data } = supabase.storage.from(bucket).getPublicUrl(fileName);

    return successResponse({
      url: data.publicUrl,
      fileName,
      bucket,
    });
  } catch (e) {
    console.error("Get storage URL error:", e);
    return errorResponse("Internal server error", 500);
  }
}
