import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/zakat_model.dart';

class ZakatInputs {
  // Gold (in selected unit: tola or grams)
  final double gold24k;
  final double gold22k;
  final double gold21k;
  final double gold18k;

  // Silver (in selected unit: tola or grams)
  final double silver;

  // Cash & Liquidity
  final double cashInHand;
  final double cashInBank;
  final double foreignCurrency;
  final double loansReceivable;

  // Business & Investments
  final double businessGoods;
  final double investments;
  final double rentalSavings;
  final double propertyForResale;

  // Deductions & Liabilities
  final double immediateDebts;
  final double billsAndSalariesDue;

  const ZakatInputs({
    this.gold24k = 0,
    this.gold22k = 0,
    this.gold21k = 0,
    this.gold18k = 0,
    this.silver = 0,
    this.cashInHand = 0,
    this.cashInBank = 0,
    this.foreignCurrency = 0,
    this.loansReceivable = 0,
    this.businessGoods = 0,
    this.investments = 0,
    this.rentalSavings = 0,
    this.propertyForResale = 0,
    this.immediateDebts = 0,
    this.billsAndSalariesDue = 0,
  });

  ZakatInputs copyWith({
    double? gold24k,
    double? gold22k,
    double? gold21k,
    double? gold18k,
    double? silver,
    double? cashInHand,
    double? cashInBank,
    double? foreignCurrency,
    double? loansReceivable,
    double? businessGoods,
    double? investments,
    double? rentalSavings,
    double? propertyForResale,
    double? immediateDebts,
    double? billsAndSalariesDue,
  }) {
    return ZakatInputs(
      gold24k: gold24k ?? this.gold24k,
      gold22k: gold22k ?? this.gold22k,
      gold21k: gold21k ?? this.gold21k,
      gold18k: gold18k ?? this.gold18k,
      silver: silver ?? this.silver,
      cashInHand: cashInHand ?? this.cashInHand,
      cashInBank: cashInBank ?? this.cashInBank,
      foreignCurrency: foreignCurrency ?? this.foreignCurrency,
      loansReceivable: loansReceivable ?? this.loansReceivable,
      businessGoods: businessGoods ?? this.businessGoods,
      investments: investments ?? this.investments,
      rentalSavings: rentalSavings ?? this.rentalSavings,
      propertyForResale: propertyForResale ?? this.propertyForResale,
      immediateDebts: immediateDebts ?? this.immediateDebts,
      billsAndSalariesDue: billsAndSalariesDue ?? this.billsAndSalariesDue,
    );
  }

  Map<String, dynamic> toJson() => {
        'gold24k': gold24k,
        'gold22k': gold22k,
        'gold21k': gold21k,
        'gold18k': gold18k,
        'silver': silver,
        'cashInHand': cashInHand,
        'cashInBank': cashInBank,
        'foreignCurrency': foreignCurrency,
        'loansReceivable': loansReceivable,
        'businessGoods': businessGoods,
        'investments': investments,
        'rentalSavings': rentalSavings,
        'propertyForResale': propertyForResale,
        'immediateDebts': immediateDebts,
        'billsAndSalariesDue': billsAndSalariesDue,
      };

  factory ZakatInputs.fromJson(Map<String, dynamic> json) {
    return ZakatInputs(
      gold24k: (json['gold24k'] as num?)?.toDouble() ?? 0,
      gold22k: (json['gold22k'] as num?)?.toDouble() ?? 0,
      gold21k: (json['gold21k'] as num?)?.toDouble() ?? 0,
      gold18k: (json['gold18k'] as num?)?.toDouble() ?? 0,
      silver: (json['silver'] as num?)?.toDouble() ?? 0,
      cashInHand: (json['cashInHand'] as num?)?.toDouble() ?? 0,
      cashInBank: (json['cashInBank'] as num?)?.toDouble() ?? 0,
      foreignCurrency: (json['foreignCurrency'] as num?)?.toDouble() ?? 0,
      loansReceivable: (json['loansReceivable'] as num?)?.toDouble() ?? 0,
      businessGoods: (json['businessGoods'] as num?)?.toDouble() ?? 0,
      investments: (json['investments'] as num?)?.toDouble() ?? 0,
      rentalSavings: (json['rentalSavings'] as num?)?.toDouble() ?? 0,
      propertyForResale: (json['propertyForResale'] as num?)?.toDouble() ?? 0,
      immediateDebts: (json['immediateDebts'] as num?)?.toDouble() ?? 0,
      billsAndSalariesDue: (json['billsAndSalariesDue'] as num?)?.toDouble() ?? 0,
    );
  }
}

class ZakatState {
  final ZakatRates rates;
  final ZakatInputs inputs;
  final ZakatCalculationResult result;
  final bool isLoaded;

  const ZakatState({
    required this.rates,
    required this.inputs,
    required this.result,
    this.isLoaded = false,
  });

  ZakatState copyWith({
    ZakatRates? rates,
    ZakatInputs? inputs,
    ZakatCalculationResult? result,
    bool? isLoaded,
  }) {
    return ZakatState(
      rates: rates ?? this.rates,
      inputs: inputs ?? this.inputs,
      result: result ?? this.result,
      isLoaded: isLoaded ?? this.isLoaded,
    );
  }
}

class ZakatNotifier extends StateNotifier<ZakatState> {
  static const String _ratesKey = 'wasila_zakat_rates_v1';
  static const String _inputsKey = 'wasila_zakat_inputs_v1';

  ZakatNotifier()
      : super(
          ZakatState(
            rates: const ZakatRates(),
            inputs: const ZakatInputs(),
            result: _calculate(const ZakatRates(), const ZakatInputs()),
          ),
        ) {
    _loadPersistedData();
  }

  static ZakatCalculationResult _calculate(ZakatRates rates, ZakatInputs inputs) {
    // Determine effective unit price (per tola or per gram)
    final double goldBasePrice = rates.weightUnit == WeightUnit.tola
        ? rates.goldPricePerTola
        : rates.goldPricePerGram;

    final double silverBasePrice = rates.weightUnit == WeightUnit.tola
        ? rates.silverPricePerTola
        : rates.silverPricePerGram;

    // Gold Karats: 24K (1.0), 22K (22/24), 21K (21/24), 18K (18/24)
    final double gold24kVal = inputs.gold24k * goldBasePrice * (24.0 / 24.0);
    final double gold22kVal = inputs.gold22k * goldBasePrice * (22.0 / 24.0);
    final double gold21kVal = inputs.gold21k * goldBasePrice * (21.0 / 24.0);
    final double gold18kVal = inputs.gold18k * goldBasePrice * (18.0 / 24.0);
    final double totalGoldValue = gold24kVal + gold22kVal + gold21kVal + gold18kVal;

    // Silver Value
    final double totalSilverValue = inputs.silver * silverBasePrice;

    // Cash Value
    final double totalCashValue = inputs.cashInHand +
        inputs.cashInBank +
        inputs.foreignCurrency +
        inputs.loansReceivable;

    // Business & Investments Value
    final double totalBusinessValue = inputs.businessGoods +
        inputs.investments +
        inputs.rentalSavings +
        inputs.propertyForResale;

    // Gross Wealth
    final double totalGrossWealth =
        totalGoldValue + totalSilverValue + totalCashValue + totalBusinessValue;

    // Liabilities
    final double totalLiabilities = inputs.immediateDebts + inputs.billsAndSalariesDue;

    // Net Zakatable Wealth (cannot be negative)
    final double netZakatableWealth =
        (totalGrossWealth - totalLiabilities) > 0 ? (totalGrossWealth - totalLiabilities) : 0;

    // Nisab Threshold: According to contemporary Islamic jurisprudence, when wealth is in mixed forms (cash + silver + gold/business), the Silver Nisab (52.5 Tola) is the standard threshold to benefit the poor (Fuqara).
    final double silverNisabValue = rates.silverNisabValue;
    final double goldNisabValue = rates.goldNisabValue;

    final bool isEligible = netZakatableWealth >= silverNisabValue;
    final double zakatPayable = isEligible ? (netZakatableWealth * 0.025) : 0.0;

    return ZakatCalculationResult(
      totalGoldValue: totalGoldValue,
      totalSilverValue: totalSilverValue,
      totalCashValue: totalCashValue,
      totalBusinessValue: totalBusinessValue,
      totalGrossWealth: totalGrossWealth,
      totalLiabilities: totalLiabilities,
      netZakatableWealth: netZakatableWealth,
      silverNisabValue: silverNisabValue,
      goldNisabValue: goldNisabValue,
      isEligible: isEligible,
      zakatPayable: zakatPayable,
    );
  }

  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      ZakatRates rates = state.rates;
      final ratesStr = prefs.getString(_ratesKey);
      if (ratesStr != null) {
        rates = ZakatRates.fromJson(jsonDecode(ratesStr));
      }

      ZakatInputs inputs = state.inputs;
      final inputsStr = prefs.getString(_inputsKey);
      if (inputsStr != null) {
        inputs = ZakatInputs.fromJson(jsonDecode(inputsStr));
      }

      final result = _calculate(rates, inputs);
      state = state.copyWith(
        rates: rates,
        inputs: inputs,
        result: result,
        isLoaded: true,
      );
    } catch (_) {
      state = state.copyWith(isLoaded: true);
    }
  }

  void updateInputs(ZakatInputs newInputs) {
    final result = _calculate(state.rates, newInputs);
    state = state.copyWith(inputs: newInputs, result: result);
    _persistInputs(newInputs);
  }

  void updateRates(ZakatRates newRates) {
    final result = _calculate(newRates, state.inputs);
    state = state.copyWith(rates: newRates, result: result);
    _persistRates(newRates);
  }

  void setWeightUnit(WeightUnit unit) {
    final newRates = state.rates.copyWith(weightUnit: unit);
    updateRates(newRates);
  }

  void setCurrency({required String code, required String symbol, double? goldTola, double? silverTola}) {
    final newRates = state.rates.copyWith(
      currency: code,
      currencySymbol: symbol,
      goldPricePerTola: goldTola ?? state.rates.goldPricePerTola,
      silverPricePerTola: silverTola ?? state.rates.silverPricePerTola,
    );
    updateRates(newRates);
  }

  void resetAll() {
    const defaultInputs = ZakatInputs();
    final result = _calculate(state.rates, defaultInputs);
    state = state.copyWith(inputs: defaultInputs, result: result);
    _persistInputs(defaultInputs);
  }

  Future<void> _persistRates(ZakatRates rates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ratesKey, jsonEncode(rates.toJson()));
  }

  Future<void> _persistInputs(ZakatInputs inputs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_inputsKey, jsonEncode(inputs.toJson()));
  }
}

final zakatProvider = StateNotifierProvider<ZakatNotifier, ZakatState>((ref) {
  return ZakatNotifier();
});
