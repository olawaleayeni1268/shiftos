param()

$u = Read-Host "Enter SUPABASE_URL (e.g. https://your-id.supabase.co)"
$k = Read-Host "Enter SUPABASE_ANON_KEY"

flutter clean
flutter pub get

$ArgsList = @(
  "run",
  "-d","chrome",
  "--web-hostname=0.0.0.0",   # listen on LAN
  "--web-port=5555",
  "--dart-define=SUPABASE_URL=$u",
  "--dart-define=SUPABASE_ANON_KEY=$k"
)

Write-Host "Running: flutter $($ArgsList -join ' ')"
flutter @ArgsList
