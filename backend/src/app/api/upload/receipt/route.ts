import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// POST /api/upload/receipt - Upload receipt PDF
export async function POST(request: NextRequest) {
  const auth = await authenticateRequest(request);
  if (!auth.authenticated) {
    return unauthorizedResponse(auth.error);
  }

  try {
    const formData = await request.formData();
    const file = formData.get("file") as File | null;

    if (!file) {
      return errorResponse("No file provided", 400);
    }

    // Validate file type
    if (file.type !== "application/pdf") {
      return errorResponse("Invalid file type. Only PDF allowed", 400);
    }

    // Generate unique filename
    const timestamp = Date.now();
    const fileName = `receipt_${timestamp}.pdf`;

    // Convert to buffer
    const arrayBuffer = await file.arrayBuffer();
    const buffer = new Uint8Array(arrayBuffer);

    // Upload to Supabase Storage
    const { error: uploadError } = await supabase.storage
      .from("receipts")
      .upload(fileName, buffer, {
        contentType: "application/pdf",
        upsert: true,
      });

    if (uploadError) {
      console.error("Upload error:", uploadError);
      return errorResponse(`Failed to upload receipt: ${uploadError.message}`, 500);
    }

    // Get public URL
    const { data: urlData } = supabase.storage
      .from("receipts")
      .getPublicUrl(fileName);

    return successResponse(
      {
        file_name: fileName,
        url: urlData.publicUrl,
      },
      "Receipt uploaded successfully"
    );
  } catch (e) {
    console.error("Upload error:", e);
    return errorResponse("Internal server error", 500);
  }
}
