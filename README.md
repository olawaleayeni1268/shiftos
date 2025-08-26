# ShiftOS (Flutter + Supabase)

Run (fixed port 5555):
flutter clean; flutter pub get; flutter run -d chrome --web-port=5555 --dart-define=SUPABASE_URL=https://<my-project>.supabase.co --dart-define=SUPABASE_ANON_KEY=<my-anon-public-key>

Backend (run once in Supabase → SQL Editor):
See all.sql (creates table, RLS, and RPC upsert_today_shift).
