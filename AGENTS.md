# ShiftOS — Agent Guide (Codex)

## Scripts (use only these)
- Analyze: `flutter analyze`
- Test: `flutter test --coverage`
- Build: `flutter build apk --release`

## Conventions
- Material 3 only; use Theme tokens (no hard-coded hex in widgets).
- UI in `lib/src/screens` and `lib/src/widgets`.
- State in `lib/src/state`; data access in `lib/src/data` (repositories).
- No API/Supabase calls in widgets; use repositories.
- One feature/fix per PR; keep diffs focused.

## Definition of Done
- Acceptance criteria met.
- `flutter analyze` clean; tests pass (if present).
- Release APK builds.
- No secrets committed; README updated if env/flags change.
