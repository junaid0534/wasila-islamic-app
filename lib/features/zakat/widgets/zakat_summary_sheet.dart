import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/zakat_provider.dart';

class ZakatSummarySheet extends StatelessWidget {
  final ZakatState state;

  const ZakatSummarySheet({
    super.key,
    required this.state,
  });

  String _formatNum(double value) {
    return NumberFormat('#,##0').format(value);
  }

  void _copyReport(BuildContext context) {
    final sym = state.rates.currencySymbol;
    final res = state.result;
    final r = state.rates;

    final report = '''
==============================
🌙 WASILA (وَسِیْلَہ) - ZAKAT REPORT
==============================
Currency: ${r.currency} (${r.currencySymbol})
Gold Rate: $sym ${_formatNum(r.goldPricePerTola)} / Tola
Silver Rate: $sym ${_formatNum(r.silverPricePerTola)} / Tola
Silver Nisab Threshold: $sym ${_formatNum(res.silverNisabValue)}

--- 📊 ASSETS BREAKDOWN ---
• Sona (Gold): $sym ${_formatNum(res.totalGoldValue)}
• Chandi (Silver): $sym ${_formatNum(res.totalSilverValue)}
• Naqad / Bank (Cash): $sym ${_formatNum(res.totalCashValue)}
• Karobar / Shares: $sym ${_formatNum(res.totalBusinessValue)}
------------------------------
• Kul Asasay (Gross Wealth): $sym ${_formatNum(res.totalGrossWealth)}
• Wajib-ul-Ada Qarz (Debts): $sym ${_formatNum(res.totalLiabilities)}
------------------------------
• Qabil-e-Zakat Raqam (Net Wealth): $sym ${_formatNum(res.netZakatableWealth)}
• Nisab Status: ${res.isEligible ? 'ZAKAT FARZ HAI (Eligible)' : 'Nisab se kam (Not Eligible)'}

⭐ TOTAL ZAKAT PAYABLE (2.5%):
👉 $sym ${_formatNum(res.zakatPayable)}
==============================
Calculated via Wasila Islamic App''';

    Clipboard.setData(ClipboardData(text: report));
    HapticFeedback.lightImpact();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Zakat summary report copy ho gaya!',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.white),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(milliseconds: 1800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final res = state.result;
    final rates = state.rates;
    final sym = rates.currencySymbol;

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.sageBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.sageBorder, width: 1),
                ),
                child: const Icon(
                  Icons.receipt_long_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Zakat Breakdown Report',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Mukammal Tafseel aur Hisab Kitab',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Report Content Scrollable
          Expanded(
            child: ListView(
              children: [
                // Top Highlight Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: res.isEligible
                          ? [const Color(0xFF1E6050), const Color(0xFF14473B)]
                          : [const Color(0xFF546E7A), const Color(0xFF37474F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        res.isEligible ? 'Total Zakat Payable (2.5%)' : 'Nisab Status',
                        style: GoogleFonts.poppins(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        res.isEligible ? '$sym ${_formatNum(res.zakatPayable)}' : 'Zakat Farz Nahi',
                        style: GoogleFonts.poppins(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFD54F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        res.isEligible
                            ? 'Aap Sahib-e-Nisab hain (Nisab: $sym ${_formatNum(res.silverNisabValue)})'
                            : 'Aap ka net maal Nisab ($sym ${_formatNum(res.silverNisabValue)}) se kam hai',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Table Breakdown
                _buildSectionHeader('Zakatable Wealth (اموالِ زکوٰۃ)'),
                _buildRowItem('Sona (Gold Value)', '$sym ${_formatNum(res.totalGoldValue)}'),
                _buildRowItem('Chandi (Silver Value)', '$sym ${_formatNum(res.totalSilverValue)}'),
                _buildRowItem('Naqad o Bank (Cash & Bank)', '$sym ${_formatNum(res.totalCashValue)}'),
                _buildRowItem('Karobar o Shares (Business)', '$sym ${_formatNum(res.totalBusinessValue)}'),
                const Divider(height: 20, color: AppColors.sageBorder),
                _buildRowItem(
                  'Gross Wealth (کل اثاثہ جات)',
                  '$sym ${_formatNum(res.totalGrossWealth)}',
                  isBold: true,
                ),
                const SizedBox(height: 12),

                _buildSectionHeader('Deductions (واجب الادا قرض جات)'),
                _buildRowItem('Debts & Bills Due', '- $sym ${_formatNum(res.totalLiabilities)}',
                    color: Colors.redAccent),
                const Divider(height: 20, color: AppColors.sageBorder),
                _buildRowItem(
                  'Net Zakatable Wealth (قابلِ زکوٰۃ رقم)',
                  '$sym ${_formatNum(res.netZakatableWealth)}',
                  isBold: true,
                  highlight: true,
                ),
                const SizedBox(height: 12),

                _buildSectionHeader('Nisab Comparison (نصاب کا موازنہ)'),
                _buildRowItem('Silver Nisab (52.5 Tola)', '$sym ${_formatNum(res.silverNisabValue)}'),
                _buildRowItem('Gold Nisab (7.5 Tola)', '$sym ${_formatNum(res.goldNisabValue)}'),
                const SizedBox(height: 20),
              ],
            ),
          ),

          // Bottom Action: Copy / Share
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => _copyReport(context),
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: Text(
                'Report Copy Karein (WhatsApp / Note)',
                style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildRowItem(String label, String value,
      {bool isBold = false, bool highlight = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
                color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12.5,
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
              color: color ?? (highlight ? AppColors.primary : AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
