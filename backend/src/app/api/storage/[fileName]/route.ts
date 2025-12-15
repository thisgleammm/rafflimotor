import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest, logActivity } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

interface RouteParams {
  params: Promise<{ fileName: string }>;
}

// DELETE /api/storage/:fileName - Delete a file from storage
export async function DELETE(request: NextRequest, { params }: RouteParams) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const { fileName } = await params;
    const { searchParams } = new URL(request.url);
    const bucket = searchParams.get("bucket") || "productimage_bucket";

    if (!fileName) {
      return errorResponse("fileName is required", 400);
    }

    const { error } = await supabase.storage.from(bucket).remove([fileName]);

    if (error) {
      console.error("Delete storage error:", error);
      return errorResponse("Failed to delete file", 500);
    }

    await logActivity(
      auth.username!,
      "DELETE_FILE",
      `Deleted file: ${fileName} from ${bucket}`
    );

    return successResponse(null, "File deleted successfully");
  } catch (e) {
    console.error("Delete storage error:", e);
    return errorResponse("Internal server error", 500);
  }
}
