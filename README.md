# Salary Brother

Flutter app for short-term salary-advance loans. Flutter 3.32 / Dart 3.8, GetX
for state and routing, Dio for networking.

The UI follows the **Salary Brother App UI** design canvas (9 screens: welcome,
login + OTP, home, calculator, KYC, review + KFS, money sent, repay, profile).
Design tokens from that canvas live in [`lib/utils/`](lib/utils/) â€” change a
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
- Every API call returns an `ApiResult` â€” callers never catch `DioException`.

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
| Radius | 14 buttons Â· 18â€“24 cards Â· 28â€“32 hero cards |
| Grid | 8 px spacing Â· touch targets â‰¥ 44 px |

## Backend: the Salary Brother CRM

The CRM mirrors the SalaryUncle CRM â€” only the host differs. It is **not** a
REST API, and three things about it drive the whole design:

**1. One write endpoint.** Login, OTP, PAN, every profile step and every
document upload all POST to `saveCustomerProfile`. The body's `event_name`
field decides what the CRM does. `saveleadDetails` works the same way for
loan-application writes. See `ApiEvents`.

**2. The outcome is in the body, not the HTTP status.** Almost everything
returns HTTP 200 with an envelope:

| Field | Meaning |
|---|---|
| `Status` | `1` ok Â· `3` bounce to dashboard Â· `4` log the customer out |
| `Message` | written for the customer â€” safe to show |
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
slash** â€” the CRM rejects the doubled `//`.

`/api` is confirmed: the website's own JS bundle calls
`https://crm.salarybrother.com/api`. (`/apply` is a CRM page, not an API root.)

### Auth

Three modes, and **which endpoint takes which is irregular** â€” do not infer a
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
- `doc_type` does not always match the event name â€” `residence_proof_upload`
  sends `doc_type: electricity_bill`, and `aadhaar_upload` is posted twice,
  once per side (`aadhaar_front`, `aadhaar_back`). These values come from
  `mandatoryDocuments`, not from the client.

### Deliberately not ported

- `backgroung_logs/` â€” posted contacts, SMS, call logs and GPS to an old
  SuryaLoan host over plain HTTP. Dead code in SalaryUncle; those permissions
  alone can fail Play Store review.
- 16 unused endpoint constants, and `getMethod` / `putMethod`, which nothing
  calls.
- The hardcoded Razorpay key. Payments need build-time config, not a literal
  in the client.

## What is built and what is not

**4 of the CRM's 14 calls are wired up.** The client and the contract metadata
are complete â€” every `event_name`, every path spelling, both envelopes â€” but
most screens that would use them do not exist yet.

Done:

- Splash, welcome, login, OTP (4-digit, as the CRM issues), home dashboard,
  loan calculator
- Theme, design tokens, shared widgets (`PrimaryButton`, `AppCard`, `HeroCard`,
  `BrandLogo`, `SquareIconButton`)
- CRM client: URL building, the three auth modes, the `Status` envelope, the
  OKYC envelope with its `otpSentStatus` check
- `event_name` catalogue and the server-driven journey router
- Calls wired: `login`, `resend_otp`, `otp_verify`, `getDashboardData`
- Support screen: call, WhatsApp, email, office address
- Loan pricing engine
- 79 tests

Still to build â€” screens 05 through 09 of the canvas, and the calls behind
them:

- [ ] PAN verification â€” `pancard_verification`
- [ ] Personal, residence, income details â€” three `saveCustomerProfile` events
- [ ] Employment, banking details â€” two `saveleadDetails` events
- [ ] Document uploads â€” six events, base64; needs `mandatoryDocuments` first
- [ ] Review + Key Fact Statement â€” `register_now`
- [ ] Loan quote and decision â€” `generate_loan_quote`,
      `loan_quotation_decision`
- [ ] Money sent / disbursal confirmation
- [ ] Repay â€” `generateRazorpayorderId`,
      `verifyRazorPayCheckPaymentStatus`
- [ ] Profile, loan list and detail â€” `getLeadList`, `getLeadDetail`
- [ ] Aadhaar OKYC â€” `getOkycOtp`, `fetchOkycData`
- [ ] Feedback form on the support screen â€” `feedback`
- [ ] SMS Retriever wiring for OTP auto-fill
- [ ] Version gate â€” `checkInstantAppVersion`
- [ ] CRM overrides for the contact details: the reference app prefers numbers
      the CRM sends over its own constants, falling back to them

`JourneyService.routeFor` already maps the routes for these, so a CRM
`next_step` naming one will navigate to a route that is not registered yet.
Register each page as its screen lands.

## Before launch

These are placeholders in the code and **must** be replaced:

1. **Auth keys** â€” `ApiConfig` has `REPLACE_ME_*` for the pre-login (Android
   and iOS) and general `Auth` keys. Until they are real, every request is
   rejected. `ApiConfig.hasPlaceholderKeys` warns in debug.
2. **Confirm the base URL** â€” `https://crm.salarybrother.com/api`. If the CRM
   actually serves under a different path, it is one line in `ApiConfig`.
3. **Firebase** â€” create a **new** Firebase project for Salary Brother. Do not
   reuse SalaryUncle's `google-services.json`: it points at the SuryaLoan
   project (`suryaloan-e961a`, bundle `com.raghavi.suryaloan`), so analytics and
   Crashlytics would mix with another product's.
4. **NBFC partner name** â€” the legal line on the welcome screen reads
   `[NBFC Partner Name]`. RBI digital-lending rules require the registered
   lender's name.
4. **App icons and splash assets** â€” `assets/images/` is empty.
5. **Android package / iOS bundle id** â€” currently
   `com.salarybrother.salary_brother`.
6. **Razorpay key** â€” passed at build time via
   `--dart-define=RAZORPAY_KEY=...`, never committed.
   `PaymentConfig.isConfigured` is false without it.

`BrandConfig.hasPlaceholders` is the release gate for the brand strings, and a
test pins it false.

## SMS and the OTP

The gateway is a plain HTTP API with Basic auth
(`GET /api/basic?mobileno=…&senderid=…&countrycode=ALL&msgtext=…`).

**The app never calls it.** A gateway password in the APK is a password
anyone can read, and anyone who reads it can send SMS on the company's
account. The CRM sends the OTP server-side when the app posts
`event_name: login`.

`SmsConfig` records the DLT registration so it sits next to the code that
parses the message:

| | |
|---|---|
| Sender ID | `SYFLSB` |
| Template id | `1777178863021936003` |
| Validity | 5 minutes, per the template's own wording |

The registered body is fixed — editing the wording needs re-approval on the
DLT portal before it will deliver, so a test asserts it still renders the
approved sample exactly.

`OtpParser.extract` reads the code from an incoming SMS. It matches the
template's own slot rather than grabbing the first digits it finds, and
requires the sender ID, so another app's OTP is never typed into this one.
Hook `AuthController.onSmsReceived` to the SMS Retriever API to finish
auto-fill; until something does, `isAutoReadingSms` stays false and the OTP
screen does not promise it.

## Lender and pricing

Salary Brother is a brand of **Sanyog Finlease Private Limited**, the
RBI-registered NBFC (Reg. No. B-14.02050) that sanctions and disburses the
loans â€” not a third party's service provider. Note the spelling: **Finlease**,
not Finance. A separate "Sanyog Fin-lease Private Limited" had its RBI
registration cancelled in 2018; it is not this entity.

`BrandConfig.lenderDisclosure` builds the sentence the welcome screen must
carry. Grievances go to `Grievance@salarybrother.com`.

`LoanPricing`'s defaults are the published terms:

| Term | Value |
|---|---|
| Interest | per day, 0.25%â€“1% by borrower profile |
| Processing fee | one-time 2%, deducted before disbursal |
| GST | 18% on the fee |
| Tenure | 7â€“30 days, timed to the salary credit |
| Late fee | flat â‚¹250, does not accrue |
| Prepayment | no charge â€” interest stops on repayment |

The rate and the limit are **per borrower**, so the server decides them. Use
`LoanPricing.fromJson` with the eligibility response rather than showing a
customer the defaults; it keeps only the tenure choices the CRM's range allows.

### A note on the reference app's branding

SalaryUncle has **three** layers of stale branding under the surface, which is
why nothing was copied wholesale:

| Layer | Where it survives |
|---|---|
| `tejas_loan` | the Dart package name, and so 273 import lines; iOS `Info.plist` |
| `suryaloan` | **both** Firebase projects (`suryaloan-e961a`), iOS bundle `com.raghavi.suryaloan`, a live AppsFlyer `SuryaLoan` meta-data tag |
| `salarytopup` | Android namespace and the `MainActivity.java` package path |

Only the outermost layer says SalaryUncle. This app starts clean, so none of it
carries over â€” but it is worth knowing when comparing the two repos.
