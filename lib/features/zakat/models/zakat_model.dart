enum WeightUnit { tola, grams }

class ZakatRates {
  final String currency;
  final String currencySymbol;
  final double goldPricePerTola;
  final double silverPricePerTola;
  final WeightUnit weightUnit;

  const ZakatRates({
    this.currency = 'PKR',
    this.currencySymbol = 'Rs.',
    this.goldPricePerTola = 285000.0,
    this.silverPricePerTola = 3250.0,
    this.weightUnit = WeightUnit.tola,
  });

  // 1 Tola = 11.6638 grams
  static const double gramsPerTola = 11.6638;

  double get goldPricePerGram => goldPricePerTola / gramsPerTola;
  double get silverPricePerGram => silverPricePerTola / gramsPerTola;

  // Nisab thresholds: 7.5 Tola Gold / 52.5 Tola Silver
  double get goldNisabThresholdTola => 7.5;
  double get silverNisabThresholdTola => 52.5;

  double get goldNisabValue => goldNisabThresholdTola * goldPricePerTola;
  double get silverNisabValue => silverNisabThresholdTola * silverPricePerTola;

  ZakatRates copyWith({
    String? currency,
    String? currencySymbol,
    double? goldPricePerTola,
    double? silverPricePerTola,
    WeightUnit? weightUnit,
  }) {
    return ZakatRates(
      currency: currency ?? this.currency,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      goldPricePerTola: goldPricePerTola ?? this.goldPricePerTola,
      silverPricePerTola: silverPricePerTola ?? this.silverPricePerTola,
      weightUnit: weightUnit ?? this.weightUnit,
    );
  }

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'currencySymbol': currencySymbol,
        'goldPricePerTola': goldPricePerTola,
        'silverPricePerTola': silverPricePerTola,
        'weightUnit': weightUnit.index,
      };

  factory ZakatRates.fromJson(Map<String, dynamic> json) {
    return ZakatRates(
      currency: json['currency'] as String? ?? 'PKR',
      currencySymbol: json['currencySymbol'] as String? ?? 'Rs.',
      goldPricePerTola: (json['goldPricePerTola'] as num?)?.toDouble() ?? 285000.0,
      silverPricePerTola: (json['silverPricePerTola'] as num?)?.toDouble() ?? 3250.0,
      weightUnit: WeightUnit.values[json['weightUnit'] as int? ?? 0],
    );
  }
}

class ZakatCalculationResult {
  final double totalGoldValue;
  final double totalSilverValue;
  final double totalCashValue;
  final double totalBusinessValue;
  final double totalGrossWealth;
  final double totalLiabilities;
  final double netZakatableWealth;
  final double silverNisabValue;
  final double goldNisabValue;
  final bool isEligible;
  final double zakatPayable;

  const ZakatCalculationResult({
    required this.totalGoldValue,
    required this.totalSilverValue,
    required this.totalCashValue,
    required this.totalBusinessValue,
    required this.totalGrossWealth,
    required this.totalLiabilities,
    required this.netZakatableWealth,
    required this.silverNisabValue,
    required this.goldNisabValue,
    required this.isEligible,
    required this.zakatPayable,
  });
}
