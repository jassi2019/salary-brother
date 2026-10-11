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

## Backend: the Salary Brother CRM

The CRM mirrors the SalaryUncle CRM — only the host differs. It is **not** a
REST API, and three things about it drive the whole design:

**1. One write endpoint.** Login, OTP, PAN, every profile step and every
document upload all POST to `saveCustomerProfile`. The body's `event_name`
field decides what the CRM does. `saveleadDetails` works the same way for
loan-application writes. See `ApiEvents`.

**2. The outcome is in the body, not the HTTP status.** Almost everything
returns HTTP 200 with an envelope:

| Field | Meaning |
|---|---|
| `Status` | `1` ok · `3` bounce to dashboard · `4` log the customer out |
| `Message` | written for the customer — safe to show |
| `Data` | the payload |

`ApiService` reads this and hands back an `ApiResult`, so a 200 with
`Status: 4` surfaces as a failure that asks for a logout.

Aadhaar OKYC is a separate module: it skips the platform prefix and uses a
lowercase `statusCode` / `data` envelope. Call it through `postOkyc`.

**3. The server decides navigation.** Every response carries
`Data.next_step`, an `event_name` naming the step still to be done.
`JourneyService.goToStep` maps that to a route; an unrecognised step logs the
customer out rather than guessing. On launch, `JourneyService.resume()` reopens
wherever the customer left off.

### URL shape

```
https://crm.salarybrother.com/api  +  /andrd | /ios  +  /saveCustomerProfile
```

Built in one place by `ApiConfig.url()`. Endpoint constants carry **no leading
slash** — the CRM rejects the doubled `//`.

### Auth

| Header | When |
|---|---|
| `Auth` (pre-login key) | login, OTP, resend |
| `Auth` (general key) | static endpoints |
| `Authtoken` | everything after login |

The token is `Data.app_login_token` from the OTP response, stored under the
`token` pref and read fresh on every request.

### Deliberately not ported

- `backgroung_logs/` — posted contacts, SMS, call logs and GPS to an old
  SuryaLoan host over plain HTTP. Dead code in SalaryUncle; those permissions
  alone can fail Play Store review.
- 16 unused endpoint constants, and `getMethod` / `putMethod`, which nothing
  calls.
- The hardcoded Razorpay key. Payments need build-time config, not a literal
  in the client.

## What is built and what is not

Done:

- Splash, welcome, login, OTP (4-digit, as the CRM issues), home dashboard,
  loan calculator
- Theme, design tokens, shared widgets (`PrimaryButton`, `AppCard`, `HeroCard`,
  `BrandLogo`, `SquareIconButton`)
- CRM client: URL building, the three auth modes, the `Status` envelope, the
  OKYC envelope
- `event_name` catalogue and the server-driven journey router
- Auth flow: login, OTP verify, resend
- Loan pricing engine with tests
- 48 tests

Still to build — screens 05 through 09 of the canvas:

- [ ] PAN verification
- [ ] Personal, residence, income, employment details
- [ ] Document uploads (selfie, PAN, Aadhaar, residence proof, bank statement,
      pay slip) — one shared screen, as the CRM routes them all to one place
- [ ] Banking details
- [ ] Review + Key Fact Statement, e-Sign
- [ ] Money sent / disbursal confirmation
- [ ] Repay
- [ ] Profile

## Before launch

These are placeholders in the code and **must** be replaced:

1. **Auth keys** — `ApiConfig` has `REPLACE_ME_*` for the pre-login (Android
   and iOS) and general `Auth` keys. Until they are real, every request is
   rejected. `ApiConfig.hasPlaceholderKeys` warns in debug.
2. **Confirm the base URL** — `https://crm.salarybrother.com/api`. If the CRM
   actually serves under a different path, it is one line in `ApiConfig`.
3. **Firebase** — create a **new** Firebase project for Salary Brother. Do not
   reuse SalaryUncle's `google-services.json`: it points at the SuryaLoan
   project (`suryaloan-e961a`, bundle `com.raghavi.suryaloan`), so analytics and
   Crashlytics would mix with another product's.
4. **NBFC partner name** — the legal line on the welcome screen reads
   `[NBFC Partner Name]`. RBI digital-lending rules require the registered
   lender's name.
5. **Pricing** — `LoanPricing` carries the design's sample terms (1%/day
   interest, 10% processing fee, 18% GST). Swap in the lending partner's final
   terms; the APR shown to the borrower is derived from them.
6. **App icons and splash assets** — `assets/images/` is empty.
7. **Android package / iOS bundle id** — currently
   `com.salarybrother.salary_brother`.
