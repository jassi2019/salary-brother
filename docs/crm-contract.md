# CRM request bodies

The exact field names each `event_name` expects. These came from tracing a
working app against the same CRM — they are not in any published spec, and
getting a key wrong produces a generic rejection that says nothing useful.

Every call is a POST. `profile_id` and `event_name` go in every body;
`profile_id` comes from `JourneyService.requireProfileId()`.

Which endpoint: **`saveCustomerProfile`** for the customer's own profile,
**`saveleadDetails`** for the loan application. The split is listed per event
below and is easy to get wrong.

## Built already

| Event | Endpoint | Body |
|---|---|---|
| `login` | saveCustomerProfile | `mobile`, `utm_source_test` |
| `otp_verify` | saveCustomerProfile | `profile_id`, `otp`, `fcm` |
| `resend_otp` | saveCustomerProfile | `profile_id`, `mobile` |
| `pancard_verification` | saveCustomerProfile | `pancard`, `monthly_income` |
| `personal_details` | saveCustomerProfile | `first_name`, `personal_email`, `dob`, `gender`, `marital_status_id`, `spouse_name`, `spouse_mobile` |
| `residence_details` | saveCustomerProfile | `residence_address_1`, `residence_address_2`, `residence_landmark`, `residence_pincode`, `residence_type_id` |
| `income_details` | saveCustomerProfile | `monthly_income`, `income_type_id`, `salary_mode_id`, `salary_date` |
| uploads (6) | see below | `doc_type`, `file_ext`, `file` |
| `loan_quotation_decision` | saveleadDetails | `amount`, `tenure`, `accepted_id` |

## Still to build

### `employment_details` → `saveleadDetails`

```json
{
  "profile_id": "...",
  "event_name": "employment_details",
  "work_mode": "1",
  "office_email": "rahul@acme.com",
  "company_name": "Acme Pvt Ltd",
  "department": "Engineering",
  "company_type_id": "1",
  "designation": "Analyst",
  "address_1": "...",
  "address_2": "...",
  "landmark": "...",
  "emp_since": "2022-04-01",
  "pincode": "110088"
}
```

`company_type_id` is sent as the literal `"1"` by the reference app — it never
varies it. `emp_since` is `yyyy-MM-dd`.

### `banking_details` → `saveleadDetails`

```json
{
  "profile_id": "...",
  "event_name": "banking_details",
  "account_name": "Rahul Kumar",
  "account_number": "50100234564521",
  "confirm_account_number": "50100234564521",
  "account_ifsc": "HDFC0001234",
  "account_branch": "Shalimar Bagh",
  "account_type_id": 1,
  "verification_consent": 1
}
```

`account_type_id: 1` is savings. `verification_consent: 1` is required — the
CRM uses it to run a penny-drop check. Both are numbers here, not strings.
`confirm_account_number` must match `account_number`; the reference app sends
the same controller's text twice after validating them equal in the UI.

### `register_now` → `saveCustomerProfile`

```json
{ "profile_id": "...", "event_name": "register_now" }
```

Nothing else. This is the "I have finished the form" signal, so the screen
behind it is a review of everything already entered plus the Key Fact
Statement. After this the CRM sets `registration_successful: 1`.

### `generate_loan_quote` → `saveleadDetails`

```json
{ "profile_id": "...", "event_name": "generate_loan_quote" }
```

Answers with the sanctioned limit:

```json
{ "min_loan_amount": 5000, "max_loan_amount": 30000,
  "min_loan_tenure": 7, "max_loan_tenure": 30 }
```

`LoanPricing.fromJson` already parses exactly these keys, and
`DashboardController.loadLimit()` already makes this call — so the offer
screen mostly needs to present what is already being fetched.

## Document uploads

Base64 inside JSON, never multipart. One document per request, posted in
sequence.

```json
{
  "profile_id": "...",
  "event_name": "aadhaar_upload",
  "doc_type": "aadhaar_front",
  "file_ext": "jpg",
  "file": "<base64, no data: prefix>"
}
```

Two traps, both already handled in `DocumentsController`:

1. **The endpoint splits by event.** `selfie_upload` → `saveCustomerProfile`.
   The other five → `saveleadDetails`.
2. **`doc_type` does not always match the event.**

   | Event | `doc_type` |
   |---|---|
   | `selfie_upload` | *(empty)* |
   | `pan_upload` | `pan_upload` |
   | `aadhaar_upload` | `aadhaar_front` **and** `aadhaar_back` — posted twice |
   | `residence_proof_upload` | `electricity_bill` |
   | `bank_statement_upload` | `bank_statement_upload` |
   | `pay_slip_upload` | `pay_slip_upload` |

`file_ext` carries the extension; HEIC is sent as `jpg`, since the picker
re-encodes it. The selfie response carries `Data.selfie_doc_url`.

These are currently hardcoded in `DocumentsController.required`. The CRM has a
`mandatoryDocuments` endpoint that returns the real list per customer — worth
moving to once the rest of the journey is done.

## Dropdown ids

Labels can change; these keys cannot.

| Field | Values |
|---|---|
| `gender` | 1 male, 2 female |
| `marital_status_id` | 1 single, 2 married (spouse fields become required) |
| `residence_type_id` | 1 owned, 2 rented, 3 family owned |
| `income_type_id` | 1 salaried, 2 self-employed |
| `salary_mode_id` | 1 bank transfer, 2 cheque, 3 cash |
| `account_type_id` | 1 savings |
| `accepted_id` | 1 accepted |

A test in `test/kyc_screens_test.dart` pins the first five, so a rename fails
the suite rather than reaching the CRM.

## Response envelope

```json
{ "Status": 1, "Message": "...", "Data": { ... } }
```

| `Status` | Meaning | What the app does |
|---|---|---|
| 1 | ok | follow `Data.next_step` |
| 2 | input rejected | show `Message`, stay put |
| 3 | already done | bounce to the dashboard |
| 4 | session over | log out |

`Message` is written for the customer and is safe to show. Aadhaar OKYC is a
separate module with a lowercase `statusCode` / `data` envelope and no
platform prefix — `ApiService.postOkyc` handles it, though nothing calls it
yet.
