import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import 'models/zakat_model.dart';
import 'providers/zakat_provider.dart';
import 'widgets/zakat_guide_sheet.dart';
import 'widgets/zakat_input_tile.dart';
import 'widgets/zakat_rates_modal.dart';
import 'widgets/zakat_summary_sheet.dart';

class ZakatScreen extends ConsumerStatefulWidget {
  const ZakatScreen({super.key});

  @override
  ConsumerState<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends ConsumerState<ZakatScreen> {
  String _formatNum(double value) {
    return NumberFormat('#,##0').format(value);
  }

  void _openRatesModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ZakatRatesModal(),
    );
  }

  void _openGuideSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ZakatGuideSheet(),
    );
  }

  void _openSummarySheet(ZakatState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ZakatSummarySheet(state: state),
    );
  }

  void _confirmReset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Reset Calculator?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Tamam enter kiye gaye aasaasay aur qarz 0 par reset ho jayenge.',
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(zakatProvider.notifier).resetAll();
              Navigator.pop(ctx);
              HapticFeedback.mediumImpact();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: Text(
              'Reset',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zakatProvider);
    final notifier = ref.read(zakatProvider.notifier);
    final rates = state.rates;
    final inputs = state.inputs;
    final res = state.result;
    final sym = rates.currencySymbol;
    final isTola = rates.weightUnit == WeightUnit.tola;
    final unitLabel = isTola ? 'Tola' : 'g';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Header Bar
            _buildHeader(),

            // 2. Main Scrollable Inputs Body
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
                children: [
                  // Live Nisab & Eligibility Status Banner
                  _buildNisabStatusBanner(state),
                  const SizedBox(height: 16),

                  // Quick Rates Pill Bar
                  _buildRatesPill(rates),
                  const SizedBox(height: 16),

                  // Category 1: Gold & Silver
                  _buildSectionCard(
                    title: 'Gold & Silver (سونا اور چاندی)',
                    urduSubtitle: 'خالص و زیوراتی سونا اور چاندی',
                    icon: Icons.stars_rounded,
                    iconColor: const Color(0xFFD48806),
                    subTotal: res.totalGoldValue + res.totalSilverValue,
                    sym: sym,
                    children: [
                      ZakatInputTile(
                        label: '24K Pure Gold (خالص سونا)',
                        subtitle: 'Gold bars / 24 Karat',
                        prefix: '',
                        suffix: unitLabel,
                        value: inputs.gold24k,
                        onChanged: (val) => notifier.updateInputs(inputs.copyWith(gold24k: val)),
                      ),
                      ZakatInputTile(
                        label: '22K Gold Jewelry (زیورات)',
                        subtitle: 'Aam zewar / 22 Karat',
                        prefix: '',
                        suffix: unitLabel,
                        value: inputs.gold22k,
                        onChanged: (val) => notifier.updateInputs(inputs.copyWith(gold22k: val)),
                      ),
                      ZakatInputTile(
                        label: '21K / 18K Gold',
                        subtitle: '18 ya 21 Karat sona',
                        prefix: '',
                        suffix: unitLabel,
                        value: inputs.gold18k,
                        onChanged: (val) => notifier.updateInputs(inputs.copyWith(gold18k: val)),
                      ),
                      ZakatInputTile(
                        label: 'Silver (چاندی)',
                        subtitle: 'Chandi ke bartan ya zewar',
                        prefix: '',
                        suffix: unitLabel,
                        value: inputs.silver,
                        onChanged: (val) => notifier.updateInputs(inputs.copyWith(silver: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category 2: Cash & Bank Balance
                  _buildSectionCard(
                    title: 'Cash & Bank Balance (نقد رقم)',
                    urduSubtitle: 'بینک بیلنس، پرائز بانڈز اور بچت',
                    icon: Icons.account_balance_wallet_rounded,
                    iconColor: const Color(0xFF2E7D32),
                    subTotal: res.totalCashValue,
                    sym: sym,
                    children: [
                      ZakatInputTile(
                        label: 'Cash in Hand (گھر میں نقد رقم)',
                        subtitle: 'Pass mojood naqad raqam',
                        prefix: sym,
                        value: inputs.cashInHand,
                        onChanged: (val) => notifier.updateInputs(inputs.copyWith(cashInHand: val)),
                      ),
                      ZakatInputTile(
                        label: 'Bank Accounts (بینک بیلنس)',
                        subtitle: 'Current / Savings account',
                        prefix: sym,
                        value: inputs.cashInBank,
                        onChanged: (val) => notifier.updateInputs(inputs.copyWith(cashInBank: val)),
                      ),
                      ZakatInputTile(
                        label: 'Foreign Currency / Savings',
                        subtitle: 'Ghair mulki currency, Prize bonds',
                        prefix: sym,
                        value: inputs.foreignCurrency,
                        onChanged: (val) =>
                            notifier.updateInputs(inputs.copyWith(foreignCurrency: val)),
                      ),
                      ZakatInputTile(
                        label: 'Loans Receivable (دیا ہوا قرض)',
                        subtitle: 'Jo wapas milne ki yaqeenan umeed ho',
                        prefix: sym,
                        value: inputs.loansReceivable,
                        onChanged: (val) =>
                            notifier.updateInputs(inputs.copyWith(loansReceivable: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category 3: Business & Investments
                  _buildSectionCard(
                    title: 'Business & Investments (تجارت و شیئرز)',
                    urduSubtitle: 'تجارتی مال، شیئرز اور ری سیل پلاٹس',
                    icon: Icons.trending_up_rounded,
                    iconColor: const Color(0xFF1565C0),
                    subTotal: res.totalBusinessValue,
                    sym: sym,
                    children: [
                      ZakatInputTile(
                        label: 'Business Stock / Merchandise',
                        subtitle: 'Resale ke liye kharida maal',
                        prefix: sym,
                        value: inputs.businessGoods,
                        onChanged: (val) =>
                            notifier.updateInputs(inputs.copyWith(businessGoods: val)),
                      ),
                      ZakatInputTile(
                        label: 'Shares, Mutual Funds & Crypto',
                        subtitle: 'Sarmayakari / Trading balance',
                        prefix: sym,
                        value: inputs.investments,
                        onChanged: (val) =>
                            notifier.updateInputs(inputs.copyWith(investments: val)),
                      ),
                      ZakatInputTile(
                        label: 'Trade Plots / Real Estate',
                        subtitle: 'Munafa ke liye li gayi property',
                        prefix: sym,
                        value: inputs.propertyForResale,
                        onChanged: (val) =>
                            notifier.updateInputs(inputs.copyWith(propertyForResale: val)),
                      ),
                      ZakatInputTile(
                        label: 'Rental Income Savings',
                        subtitle: 'Kiraye se bachi hui raqam',
                        prefix: sym,
                        value: inputs.rentalSavings,
                        onChanged: (val) =>
                            notifier.updateInputs(inputs.copyWith(rentalSavings: val)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Category 4: Deductions & Liabilities
                  _buildSectionCard(
                    title: 'Debts & Deductions (واجب الادا قرض)',
                    urduSubtitle: 'فوری ادا کرنے والے قرض اور بلز (منفی ہوں گے)',
                    icon: Icons.receipt_long_rounded,
                    iconColor: Colors.redAccent,
                    subTotal: res.totalLiabilities,
                    sym: sym,
                    isDeduction: true,
                    children: [
                      ZakatInputTile(
                        label: 'Immediate Debts (فوری واجب الادا قرض)',
                        subtitle: 'Jo foran wapas karne hain',
                        prefix: sym,
                        value: inputs.immediateDebts,
                        onChanged: (val) =>
                            notifier.updateInputs(inputs.copyWith(immediateDebts: val)),
                      ),
                      ZakatInputTile(
                        label: 'Due Bills & Salaries (بلز اور تنخواہ)',
                        subtitle: 'Due utility bills, mulazmeen ki tankhwah',
                        prefix: sym,
                        value: inputs.billsAndSalariesDue,
                        onChanged: (val) =>
                            notifier.updateInputs(inputs.copyWith(billsAndSalariesDue: val)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // 3. Floating Bottom Calculation Summary Bar
      bottomNavigationBar: _buildBottomSummaryBar(state),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E6050), // Forest Pine Green
            Color(0xFF14473B), // Deep Forest Pine
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back Button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Title & Quran Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        'Zakat Calculator',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD54F).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFFFD54F).withValues(alpha: 0.5),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'زکوٰۃ',
                        style: GoogleFonts.amiri(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Shariah Compliant 2.5% Calculation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ],
            ),
          ),

          // Guide / Masail Button
          IconButton(
            onPressed: _openGuideSheet,
            tooltip: 'Zakat Guide & Rules',
            icon: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 22),
          ),

          // Reset Button
          IconButton(
            onPressed: _confirmReset,
            tooltip: 'Reset Inputs',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 22),
          ),
        ],
      ),
    );
  }

  Widget _buildNisabStatusBanner(ZakatState state) {
    final res = state.result;
    final rates = state.rates;
    final sym = rates.currencySymbol;
    final isEligible = res.isEligible;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isEligible
              ? const Color(0xFF2E7D32).withValues(alpha: 0.4)
              : AppColors.sageBorder,
          width: 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: isEligible
                ? const Color(0xFF2E7D32).withValues(alpha: 0.08)
                : AppColors.primary.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Badge Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isEligible
                      ? const Color(0xFFE8F5E9)
                      : AppColors.sageLight,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isEligible ? Icons.verified_rounded : Icons.info_outline_rounded,
                  color: isEligible ? const Color(0xFF2E7D32) : AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Status Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isEligible ? 'Zakat Farz Hai (Sahib-e-Nisab)' : 'Nisab se kam (Not Payable)',
                      style: GoogleFonts.poppins(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: isEligible ? const Color(0xFF2E7D32) : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      isEligible
                          ? 'Aap ka net maal Nisab ki had ($sym ${_formatNum(res.silverNisabValue)}) se zyada hai.'
                          : 'Zakat farz hone ke liye net maal $sym ${_formatNum(res.silverNisabValue)} ya is se zyada hona zaroori hai.',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mini Stats Grid (Net Wealth vs Silver Nisab)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Zakatable Wealth',
                      style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    Text(
                      '$sym ${_formatNum(res.netZakatableWealth)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                Container(height: 24, width: 1, color: AppColors.sageBorder),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Silver Nisab (52.5 Tola)',
                      style: GoogleFonts.poppins(fontSize: 10, color: AppColors.textSecondary),
                    ),
                    Text(
                      '$sym ${_formatNum(res.silverNisabValue)}',
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatesPill(ZakatRates rates) {
    final sym = rates.currencySymbol;
    final isTola = rates.weightUnit == WeightUnit.tola;
    final unitText = isTola ? 'Tola' : 'Gram';

    return GestureDetector(
      onTap: _openRatesModal,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.sageBorder, width: 1.1),
        ),
        child: Row(
          children: [
            const Icon(Icons.tune_rounded, color: AppColors.primary, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Gold: $sym ${_formatNum(isTola ? rates.goldPricePerTola : rates.goldPricePerGram)} • Silver: $sym ${_formatNum(isTola ? rates.silverPricePerTola : rates.silverPricePerGram)} / $unitText',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.sageLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Change Rates',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required String urduSubtitle,
    required IconData icon,
    required Color iconColor,
    required double subTotal,
    required String sym,
    required List<Widget> children,
    bool isDeduction = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.sageBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Header Row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      urduSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDeduction
                      ? const Color(0xFFFFEBEE)
                      : AppColors.sageLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${isDeduction ? '-' : ''}$sym ${_formatNum(subTotal)}',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDeduction ? Colors.redAccent : AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Input Tiles
          ...children,
        ],
      ),
    );
  }

  Widget _buildBottomSummaryBar(ZakatState state) {
    final res = state.result;
    final rates = state.rates;
    final sym = rates.currencySymbol;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: AppColors.sageBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left Side: Total Zakat Due
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Zakat Payable (2.5%)',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (res.isEligible) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Farz',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  res.isEligible ? '$sym ${_formatNum(res.zakatPayable)}' : '$sym 0',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: res.isEligible ? AppColors.primary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Right Side: Breakdown & Report Button
          ElevatedButton.icon(
            onPressed: () => _openSummarySheet(state),
            icon: const Icon(Icons.receipt_long_rounded, size: 16),
            label: Text(
              'Tafseel & Share',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
