import { createClient, SupabaseClient } from "@supabase/supabase-js";

const supabaseUrl = process.env.SUPABASE_URL!;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY!;

// Server-side Supabase client with service role key
export const supabase: SupabaseClient = createClient(
  supabaseUrl,
  supabaseServiceKey
);

// For storage operations
export const getStorageUrl = (bucket: string, path: string): string => {
  return `${supabaseUrl}/storage/v1/object/public/${bucket}/${path}`;
};
