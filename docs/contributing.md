# Contributing to MediMind

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Production-ready code; triggers release build |
| `develop` | Integration branch; all PRs target here |
| `feature/<ticket>-<slug>` | New features (e.g., `feature/MM-42-video-call`) |
| `fix/<ticket>-<slug>` | Bug fixes (e.g., `fix/MM-91-otp-timer`) |
| `chore/<slug>` | Dependencies, CI, tooling |

## Commit Format

```
<type>(<scope>): <subject>

[optional body]
```

Types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `style`

Examples:

```
feat(appointments): add slot availability cache
fix(auth): reset OTP timer on page re-entry
test(prescriptions): add bloc unit tests
```

## Pull Request Process

1. Branch from `develop`
2. Implement your change with tests
3. Run `flutter analyze` — zero issues required
4. Run `flutter test` — all tests must pass
5. Open PR targeting `develop`
6. PR title follows commit format
7. Fill in the PR template (summary + test plan)
8. Request review from at least one team member
9. Squash-merge after approval

## Code Style

- Follow the rules in `analysis_options.yaml`
- No `print()` — use `logger` from the core logger
- No `dynamic` without justification
- No business logic in widgets — use BLoC
- No `context.read()` inside `build()` — use `BlocBuilder`/`BlocListener`

## Testing Requirements

- Unit tests for every BLoC (events → states)
- Unit tests for every use case with mocked repository
- Widget tests for complex custom widgets
- Aim for 70%+ line coverage on new code

## Adding a New Feature

1. Create `lib/features/<name>/` with the standard structure
2. Add domain entities + repository interface
3. Implement data layer (model + datasource + repo)
4. Create use cases
5. Build presentation layer (bloc + pages + widgets)
6. Create `<name>_injection.dart` and register with GetIt
7. Call `init<Name>Feature(sl)` in `bootstrap.dart`
8. Add routes in `app_router.dart` and names in `route_names.dart`
9. Add translation keys to both `en-US.json` and `am-ET.json`
10. Write tests

## Secrets and Environment Variables

- Never commit `.env`, `google-services.json`, or `GoogleService-Info.plist`
- These are provided via GitHub Actions secrets in CI
- Locally, copy `.env.example` to `.env`
