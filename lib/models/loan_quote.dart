/// Pricing config.
///
/// The defaults are the published Salary Brother terms: interest per day from
/// 0.25% to 1% depending on the borrower's profile, a one-time 2% processing
/// fee deducted before disbursal, and tenures of 7 to 30 days timed to the
/// next salary credit.
///
/// [ratePerDay] and the limit are per-borrower, so the server decides them —
/// use [fromJson] with the eligibility response rather than trusting these
/// defaults in front of a customer.
class LoanPricing {
  const LoanPricing({
    this.minAmount = 5000,
    this.maxAmount = 30000,
    this.stepAmount = 1000,
    this.ratePerDay = 1.0,
    this.processingFeePct = 2.0,
    this.gstPct = 18.0,
    this.tenureOptions = const [7, 15, 21, 30],
    this.lateFee = 250,
  });

  /// Builds the config from the CRM's eligibility payload, falling back to the
  /// published defaults for anything it does not send.
  factory LoanPricing.fromJson(Map<String, dynamic> json) {
    const fallback = LoanPricing();

    double? asDouble(Object? value) =>
        value == null ? null : double.tryParse(value.toString());
    int? asInt(Object? value) =>
        value == null ? null : int.tryParse(value.toString().split('.').first);

    final minTenure = asInt(json['min_loan_tenure']);
    final maxTenure = asInt(json['max_loan_tenure']);

    return LoanPricing(
      minAmount: asInt(json['min_loan_amount']) ?? fallback.minAmount,
      maxAmount: asInt(json['max_loan_amount']) ?? fallback.maxAmount,
      ratePerDay: asDouble(json['interest_rate_per_day']) ?? fallback.ratePerDay,
      processingFeePct:
          asDouble(json['processing_fee_pct']) ?? fallback.processingFeePct,
      tenureOptions: _tenuresBetween(minTenure, maxTenure) ??
          fallback.tenureOptions,
    );
  }

  /// Keeps the published tenure choices that the server's range allows, so the
  /// picker never offers a tenure the CRM would reject.
  static List<int>? _tenuresBetween(int? min, int? max) {
    if (min == null && max == null) return null;

    final low = min ?? 1;
    final high = max ?? 36500;
    final allowed = const LoanPricing()
        .tenureOptions
        .where((d) => d >= low && d <= high)
        .toList();

    // The range may not overlap the published choices at all; offer its
    // endpoints rather than an empty picker.
    if (allowed.isEmpty) return {low, high}.toList()..sort();
    return allowed;
  }

  final int minAmount;
  final int maxAmount;
  final int stepAmount;

  /// Interest charged per day, in percent of the principal. Published range is
  /// 0.25% to 1%, set per borrower.
  final double ratePerDay;

  /// One-time processing fee, in percent of the principal. Deducted before the
  /// money lands.
  final double processingFeePct;

  /// GST charged on the processing fee.
  final double gstPct;

  final List<int> tenureOptions;

  /// Flat late fee in rupees, charged once. It does not accrue per day.
  final int lateFee;

  LoanPricing copyWith({int? maxAmount, double? ratePerDay}) => LoanPricing(
        minAmount: minAmount,
        maxAmount: maxAmount ?? this.maxAmount,
        stepAmount: stepAmount,
        ratePerDay: ratePerDay ?? this.ratePerDay,
        processingFeePct: processingFeePct,
        gstPct: gstPct,
        tenureOptions: tenureOptions,
        lateFee: lateFee,
      );
}

/// One priced loan offer, derived from an amount, a tenure and a [LoanPricing].
class LoanQuote {
  const LoanQuote({
    required this.amount,
    required this.days,
    required this.processingFee,
    required this.gst,
    required this.interest,
    required this.dueDate,
  });

  /// Builds the quote the way the design's calculator does.
  factory LoanQuote.from({
    required int amount,
    required int days,
    required LoanPricing pricing,
    DateTime? today,
  }) {
    final fee = (amount * pricing.processingFeePct / 100).round();
    final gst = (fee * pricing.gstPct / 100).round();
    final interest = (amount * pricing.ratePerDay / 100 * days).round();
    final from = today ?? DateTime.now();

    return LoanQuote(
      amount: amount,
      days: days,
      processingFee: fee,
      gst: gst,
      interest: interest,
      dueDate: DateTime(from.year, from.month, from.day + days),
    );
  }

  final int amount;
  final int days;
  final int processingFee;
  final int gst;
  final int interest;
  final DateTime dueDate;

  /// What actually lands in the borrower's bank account.
  int get netDisbursed => amount - processingFee - gst;

  /// Principal plus interest — what the borrower repays on the due date.
  int get totalRepayable => amount + interest;

  /// Every charge added together.
  int get totalCost => interest + processingFee + gst;

  /// Annualised cost on the amount actually received, as required for a KFS.
  double? get apr {
    if (netDisbursed <= 0 || days <= 0) return null;
    return totalCost / netDisbursed * 365 / days * 100;
  }

  String get aprLabel {
    final value = apr;
    return value == null ? '—' : '${value.toStringAsFixed(1)}%';
  }
}
