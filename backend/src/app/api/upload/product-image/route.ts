import { NextRequest } from "next/server";
import { supabase } from "@/lib/supabase";
import { authenticateRequest } from "@/lib/auth";
import {
  successResponse,
  errorResponse,
  unauthorizedResponse,
} from "@/lib/response";

// POST /api/upload/product-image - Upload product image
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
    const allowedTypes = ["image/jpeg", "image/png", "image/webp"];
    if (!allowedTypes.includes(file.type)) {
      return errorResponse("Invalid file type. Allowed: jpeg, png, webp", 400);
    }

    // Generate unique filename
    const timestamp = Date.now();
    const extension = file.type === "image/webp" ? "webp" : "webp"; // Always convert to webp
    const fileName = `${timestamp}.${extension}`;

    // Convert to buffer
    const arrayBuffer = await file.arrayBuffer();
    const buffer = new Uint8Array(arrayBuffer);

    // Upload to Supabase Storage
    const { error: uploadError } = await supabase.storage
      .from("productimage_bucket")
      .upload(fileName, buffer, {
        contentType: "image/webp",
        upsert: true,
      });

    if (uploadError) {
      console.error("Upload error:", uploadError);
      return errorResponse(`Failed to upload image: ${uploadError.message}`, 500);
    }

    // Get public URL
    const { data: urlData } = supabase.storage
      .from("productimage_bucket")
      .getPublicUrl(fileName);

    return successResponse(
      {
        file_name: fileName,
        url: urlData.publicUrl,
      },
      "Image uploaded successfully"
    );
  } catch (e) {
    console.error("Upload error:", e);
    return errorResponse("Internal server error", 500);
  }
}
