# Salary Brother

Flutter app for short-term salary-advance loans. Flutter 3.32 / Dart 3.8, GetX
for state and routing, Dio for networking.

The UI follows the **Salary Brother App UI** design canvas (9 screens: welcome,
login + OTP, home, calculator, KYC, review + KFS, money sent, repay, profile).
Design tokens from that canvas live in [`lib/utils/`](lib/utils/) — change a
colour, radius or type size there and it changes everywhere.

## Getting started

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK on PATH. On this machine it is at `C:\Users\HP\flutter`.

```bash
flutter analyze   # must be clean before a PR
flutter test      # 33 tests
```

## Project layout

```
lib/
  bindings/     GetX dependency wiring, one per feature
  controllers/  business logic, no widgets
  models/       data classes + the loan pricing maths
  routes/       route names and the GetPage table
  services/     API client, endpoints, local storage
  utils/        design tokens, theme, validators, formatters
  views/        one file per screen
  widgets/      shared UI pieces
```

### Conventions

- **Never hard-code a colour, radius or text style in a widget.** Add it to
  `AppColors` / `AppSizes` / `AppTextStyles` first, then use it.
- Controllers hold no `BuildContext` and build no widgets. Views hold no maths.
- Routes go through `RouteNames`, never raw strings.
- Money arithmetic belongs in `LoanQuote`, so it can be unit-tested without a
  widget tree.
- Every API call returns an `ApiResult` — callers never catch `DioException`.

## Design tokens

| Token | Value |
|---|---|
| Primary (plum) | `#840753` |
| Tint | `#E8CDD6` |
| Surface | `#FBF5F8` |
| Ink | `#1F1219` |
| Muted | `#6B5662` |
| Success | `#0B7A5C` |
| Headings + amounts | Sora |
| Body | Manrope |
| Radius | 14 buttons · 18–24 cards · 28–32 hero cards |
| Grid | 8 px spacing · touch targets ≥ 44 px |

## What is built and what is not

Done:

- Splash, welcome, login, OTP, home dashboard, loan calculator
- Theme, design tokens, shared widgets (`PrimaryButton`, `AppCard`, `HeroCard`,
  `BrandLogo`, `SquareIconButton`)
- Auth flow wired to `/auth/send-otp` and `/auth/verify-otp`
- Loan pricing engine with tests

Still to build — screens 05 through 09 of the canvas:

- [ ] KYC (PAN, Aadhaar via DigiLocker)
- [ ] Employment and bank details
- [ ] Review + Key Fact Statement, e-Sign
- [ ] Money sent / disbursal confirmation
- [ ] Repay
- [ ] Profile
- [ ] Loan history

## Before launch

These are placeholders in the code and **must** be replaced:

1. **`ApiEndpoints.baseUrl`** — currently `https://api.salarybrother.com/v1`.
2. **NBFC partner name** — the legal line on the welcome screen reads
   `[NBFC Partner Name]`. RBI digital-lending rules require the registered
   lender's name here.
3. **Pricing** — `LoanPricing` carries the design's sample terms (1%/day
   interest, 10% processing fee, 18% GST). Swap in the lending partner's final
   terms; the APR shown to the borrower is derived from them.
4. **App icons and splash assets** — `assets/images/` is empty.
5. **Android package / iOS bundle id** — currently `com.salarybrother.salary_brother`.
