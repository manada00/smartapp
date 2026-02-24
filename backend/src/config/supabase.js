const { createClient } = require('@supabase/supabase-js');

let supabaseClient;

const getSupabaseClient = () => {
  if (supabaseClient) return supabaseClient;

  const url = process.env.SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url || !serviceKey) {
    return null;
  }

  supabaseClient = createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });

  return supabaseClient;
};

module.exports = {
  getSupabaseClient,
};
