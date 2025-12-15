import { NextRequest, NextResponse } from "next/server";

const supabaseUrl = process.env.SUPABASE_URL!;

export async function GET(request: NextRequest) {
  try {
    // Return storage configuration for the client
    const config = {
      storageBaseUrl: `${supabaseUrl}/storage/v1/object/public`,
      buckets: {
        productImage: "productimage_bucket",
        items: "items",
      },
    };

    return NextResponse.json({
      success: true,
      data: config,
    });
  } catch (error) {
    console.error("Error fetching config:", error);
    return NextResponse.json(
      { success: false, error: "Failed to fetch config" },
      { status: 500 }
    );
  }
}
