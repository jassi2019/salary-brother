/// Pricing config. These are the sample numbers from the design canvas —
/// replace them with the lending partner's final terms before launch.
class LoanPricing {
  const LoanPricing({
    this.minAmount = 5000,
    this.maxAmount = 35000,
    this.stepAmount = 1000,
    this.ratePerDay = 1.0,
    this.processingFeePct = 10.0,
    this.gstPct = 18.0,
    this.tenureOptions = const [7, 15, 30, 40],
  });

  final int minAmount;
  final int maxAmount;
  final int stepAmount;

  /// Interest charged per day, in percent of the principal.
  final double ratePerDay;

  /// Processing fee, in percent of the principal. Deducted at disbursal.
  final double processingFeePct;

  /// GST charged on the processing fee.
  final double gstPct;

  final List<int> tenureOptions;

  LoanPricing copyWith({int? maxAmount}) => LoanPricing(
        minAmount: minAmount,
        maxAmount: maxAmount ?? this.maxAmount,
        stepAmount: stepAmount,
        ratePerDay: ratePerDay,
        processingFeePct: processingFeePct,
        gstPct: gstPct,
        tenureOptions: tenureOptions,
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
