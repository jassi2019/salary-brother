# Salary Brother

Flutter app for short-term salary-advance loans. Flutter 3.32 / Dart 3.8, GetX
for state and routing, Dio for networking.

The UI follows the **Salary Brother App UI** design canvas (9 screens: welcome,
login + OTP, home, calculator, KYC, review + KFS, money sent, repay, profile).
Design tokens from that canvas live in [`lib/utils/`](lib/utils/) — change a
colour, radius or type size there and it changes everywhere.

The lender is **Sanyog Finlease Private Limited** (RBI Reg. No. B-14.02050);
Salary Brother is its brand, not a third party's service.

## Getting started

```bash
flutter pub get
flutter run
```

Requires the Flutter SDK on PATH. On this machine it is at `C:\Users\HP\flutter`.

```bash
flutter analyze   # must be clean before a PR
flutter test      # 143 tests
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
- **Never navigate forward with a bare `Get.toNamed`.** Post the event, then
  `JourneyService.goToStep(next_step)`. The server owns the journey; a
  hardcoded destination will send the customer somewhere the CRM refuses.
- A control with no screen behind it is dimmed and inert, never enabled-looking
  and dead. `JourneyService.isRegistered` is how a widget checks.
- Read `profile_id` through `JourneyService.requireProfileId()`, which logs out
  cleanly when it is missing, rather than posting an empty string the CRM
  rejects with an opaque error.

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
| Grid | 8 px spacing · touch targets â‰¥ 44 px |

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

`/api` is confirmed: the website's own JS bundle calls
`https://crm.salarybrother.com/api`. (`/apply` is a CRM page, not an API root.)

### Auth

Three modes, and **which endpoint takes which is irregular** — do not infer a
pre-login / post-login split:

| Endpoint | Header |
|---|---|
| login, resend_otp, otp_verify | `Auth`, platform key |
| verifyRazorPayCheckPaymentStatus | `Auth`, platform key |
| checkInstantAppVersion | `Auth`, platform key |
| fetchOkycData | `Auth`, platform key |
| getOkycOtp | `Auth`, general key |
| feedback | `Auth`, general key |
| everything else | `Authtoken` |

The platform key differs between Android and iOS; the general key does not.
The token is `Data.app_login_token` from the OTP response, stored under the
`token` pref and read fresh on every request.

### Uploads

All six document events share one path: **base64 in JSON**, never multipart.
The body is `{profile_id, doc_type, event_name, file_ext, file}`, where `file`
is a bare base64 string and `file_ext` carries the extension (`HEIC` is sent as
`jpg`). Files are posted one at a time, not batched.

Two traps:

- `selfie_upload` posts to `saveCustomerProfile`; the other five post to
  `saveleadDetails`.
- `doc_type` does not always match the event name — `residence_proof_upload`
  sends `doc_type: electricity_bill`, and `aadhaar_upload` is posted twice,
  once per side (`aadhaar_front`, `aadhaar_back`). These values come from
  `mandatoryDocuments`, not from the client.

### Deliberately not ported

- `backgroung_logs/` — posted contacts, SMS, call logs and GPS to an old
  SuryaLoan host over plain HTTP. Dead code in SalaryUncle; those permissions
  alone can fail Play Store review.
- 16 unused endpoint constants, and `getMethod` / `putMethod`, which nothing
  calls.
- The hardcoded Razorpay key. Payments need build-time config, not a literal
  in the client.

## The journey

The CRM drives it. Each response names the next step; the app follows.

| # | Step (`event_name`) | Screen | Built |
|---|---|---|---|
| 0-2 | `login` · `otp_verify` · `resend_otp` | Login, OTP | yes |
| 3 | `pancard_verification` | PAN | yes |
| 4 | `personal_details` | Personal details | yes |
| 5 | `residence_details` | Address | yes |
| 6 | `income_details` | Income | yes |
| 7 | `selfie_upload` | Documents (selfie mode) | yes |
| 8 | `register_now` | Review + KFS | **no** |
| 9 | `generate_loan_quote` | Offer | **no** |
| 9 | `loan_quotation_decision` | Calculator | yes |
| 10 | `employment_details` | Employment | **no** |
| 11 | five upload events | Documents | yes |
| 12 | `banking_details` | Bank account | **no** |
| 13 | `completed` | Dashboard | yes |

An unbuilt step falls back to the dashboard rather than stranding the
customer, and the "Next" tile dims itself instead of offering a tap that
would go nowhere. A test fails if a route is neither registered nor on the
known-unbuilt list, so the table above cannot drift from the code.

### The calculator is gated

`loan_quotation_decision` is position 9. Opening the amount picker earlier
shows figures the CRM has not sanctioned, and its Continue button can only
fail — the server answers *"your registration is not completed"*.
`JourneyService.canChooseAmount` gates all three entry points (the limit
card, the quick action, the bottom tab); the limit card's button continues
the application instead.

The limit itself is **not** in `getDashboardData` — it is the answer to a
separate `generate_loan_quote` post. Until that returns, the dashboard says
there is no quote yet rather than inventing a ceiling.

## What is built

- Splash, welcome, login, OTP (4-digit, auto-filled from the SMS)
- Dashboard, profile, support
- PAN, personal, address, income
- Documents: camera or gallery, base64 upload, selfie shown on the dashboard
  and profile
- Loan calculator, posting the chosen amount and tenure to the CRM
- CRM client: URL building, the three auth modes, the `Status` envelope
  (1 ok · 2 rejected · 3 bounce · 4 logout), the OKYC envelope
- Server-driven routing, with a fallback for every unbuilt step
- 143 tests

## Still to build

- [ ] Review + Key Fact Statement — `register_now`
- [ ] Offer screen — `generate_loan_quote`
- [ ] Employment details — `employment_details`
- [ ] Bank account — `banking_details`
- [ ] Repay — `generateRazorpayorderId`, `verifyRazorPayCheckPaymentStatus`
- [ ] Loan list and detail — `getLeadList`, `getLeadDetail`
- [ ] Aadhaar OKYC — `getOkycOtp`, `fetchOkycData` (the client is written;
      nothing calls it)
- [ ] Feedback form on the support screen — `feedback`
- [ ] Version gate — `checkInstantAppVersion`
- [ ] `mandatoryDocuments`, so the document list comes from the CRM rather
      than being hardcoded

## Before launch

1. **Auth keys** — `ApiConfig`'s three keys are empty, so no `Auth` header is
   sent at all. The CRM tolerates that today but answers `Status: 4` to a
   *wrong* key, which the app treats as "log out" — so a placeholder is worse
   than nothing. Fill them in when the CRM issues this app's keys;
   `ApiConfig.hasPlaceholderKeys` warns in debug meanwhile.
2. **SMS sender ID** — live OTPs arrive signed `JULANA`, not the registered
   `SYFNSB`. That is a gateway-side misconfiguration; the parser accepts both
   so auto-fill still works, with a TODO to drop `JULANA` once fixed. Worth
   correcting at the gateway: an unregistered sender ID can be blocked under
   TRAI rules.
3. **Privacy policy and terms pages** — the URLs resolve to a placeholder
   page. RBI digital-lending rules require both to be reachable from the app,
   so this is a launch blocker on the website side.
4. **Firebase** — create a **new** project. Do not reuse SalaryUncle's
   `google-services.json`: it points at `suryaloan-e961a`, so analytics and
   Crashlytics would mix with another product's.
5. **Release signing** — the APK is signed with the debug keys. Fine for
   testing, not for a store upload.
6. **Android package / iOS bundle id** — currently
   `com.salarybrother.salary_brother`.
7. **Razorpay key** — passed at build time via
   `--dart-define=RAZORPAY_KEY=...`, never committed.

`BrandConfig.hasPlaceholders` is the release gate for the brand strings, and
a test pins it false.
