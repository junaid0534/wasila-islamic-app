import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../models/zakat_model.dart';
import '../providers/zakat_provider.dart';

class ZakatRatesModal extends ConsumerStatefulWidget {
  const ZakatRatesModal({super.key});

  @override
  ConsumerState<ZakatRatesModal> createState() => _ZakatRatesModalState();
}

class _ZakatRatesModalState extends ConsumerState<ZakatRatesModal> {
  late TextEditingController _goldController;
  late TextEditingController _silverController;

  final List<Map<String, dynamic>> _currencyPresets = [
    {'code': 'PKR', 'symbol': 'Rs.', 'goldTola': 285000.0, 'silverTola': 3250.0},
    {'code': 'USD', 'symbol': '\$', 'goldTola': 1020.0, 'silverTola': 12.0},
    {'code': 'SAR', 'symbol': 'SR', 'goldTola': 3820.0, 'silverTola': 44.0},
    {'code': 'AED', 'symbol': 'AED', 'goldTola': 3740.0, 'silverTola': 43.0},
    {'code': 'GBP', 'symbol': '£', 'goldTola': 790.0, 'silverTola': 9.5},
    {'code': 'INR', 'symbol': '₹', 'goldTola': 85000.0, 'silverTola': 980.0},
  ];

  @override
  void initState() {
    super.initState();
    final rates = ref.read(zakatProvider).rates;
    final isTola = rates.weightUnit == WeightUnit.tola;
    _goldController = TextEditingController(
      text: (isTola ? rates.goldPricePerTola : rates.goldPricePerGram).round().toString(),
    );
    _silverController = TextEditingController(
      text: (isTola ? rates.silverPricePerTola : rates.silverPricePerGram).round().toString(),
    );
  }

  @override
  void dispose() {
    _goldController.dispose();
    _silverController.dispose();
    super.dispose();
  }

  void _onSave() {
    final rates = ref.read(zakatProvider).rates;
    final isTola = rates.weightUnit == WeightUnit.tola;

    final double enteredGold = double.tryParse(_goldController.text.trim()) ?? 0;
    final double enteredSilver = double.tryParse(_silverController.text.trim()) ?? 0;

    final double goldTola = isTola ? enteredGold : (enteredGold * ZakatRates.gramsPerTola);
    final double silverTola = isTola ? enteredSilver : (enteredSilver * ZakatRates.gramsPerTola);

    ref.read(zakatProvider.notifier).updateRates(
          rates.copyWith(
            goldPricePerTola: goldTola > 0 ? goldTola : rates.goldPricePerTola,
            silverPricePerTola: silverTola > 0 ? silverTola : rates.silverPricePerTola,
          ),
        );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(zakatProvider);
    final rates = state.rates;
    final isTola = rates.weightUnit == WeightUnit.tola;
    final unitText = isTola ? 'Tola' : 'Gram';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        left: 20,
        right: 20,
        top: 16,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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

            // Modal Title
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
                    Icons.tune_rounded,
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
                        'Market Rates & Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        'Sona, Chandi ke live rate aur Currency',
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
            const SizedBox(height: 18),

            // 1. Weight Unit Toggle (Tola vs Grams)
            Text(
              'Weight Unit (Wazan ki Ikai)',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sageBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (!isTola) {
                          ref.read(zakatProvider.notifier).setWeightUnit(WeightUnit.tola);
                          setState(() {
                            _goldController.text = rates.goldPricePerTola.round().toString();
                            _silverController.text = rates.silverPricePerTola.round().toString();
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: isTola ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Tola (تولہ)',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: isTola ? FontWeight.w600 : FontWeight.w500,
                              color: isTola ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (isTola) {
                          ref.read(zakatProvider.notifier).setWeightUnit(WeightUnit.grams);
                          setState(() {
                            _goldController.text = rates.goldPricePerGram.round().toString();
                            _silverController.text = rates.silverPricePerGram.round().toString();
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: !isTola ? AppColors.primary : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            'Grams (گرام)',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              fontWeight: !isTola ? FontWeight.w600 : FontWeight.w500,
                              color: !isTola ? Colors.white : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. Currency Selector
            Text(
              'Select Currency',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _currencyPresets.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _currencyPresets[index];
                  final isSelected = rates.currency == item['code'];

                  return GestureDetector(
                    onTap: () {
                      ref.read(zakatProvider.notifier).setCurrency(
                            code: item['code'],
                            symbol: item['symbol'],
                            goldTola: item['goldTola'],
                            silverTola: item['silverTola'],
                          );
                      final newRates = ref.read(zakatProvider).rates;
                      setState(() {
                        _goldController.text = (isTola
                                ? newRates.goldPricePerTola
                                : newRates.goldPricePerGram)
                            .round()
                            .toString();
                        _silverController.text = (isTola
                                ? newRates.silverPricePerTola
                                : newRates.silverPricePerGram)
                            .round()
                            .toString();
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : AppColors.background,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.sageBorder,
                          width: 1.2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${item['code']} (${item['symbol']})',
                          style: GoogleFonts.poppins(
                            fontSize: 11.5,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected ? Colors.white : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 18),

            // 3. Custom Gold Price Input
            Text(
              'Gold Price (Fi $unitText Sona Rate)',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sageBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.stars_rounded, color: Color(0xFFD48806), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${rates.currencySymbol} ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _goldController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter gold rate',
                      ),
                    ),
                  ),
                  Text(
                    '/ $unitText',
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Custom Silver Price Input
            Text(
              'Silver Price (Fi $unitText Chandi Rate)',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.sageBorder, width: 1.2),
              ),
              child: Row(
                children: [
                  const Icon(Icons.brightness_medium_rounded, color: Color(0xFF78909C), size: 18),
                  const SizedBox(width: 8),
                  Text(
                    '${rates.currencySymbol} ',
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _silverController,
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter silver rate',
                      ),
                    ),
                  ),
                  Text(
                    '/ $unitText',
                    style: GoogleFonts.poppins(fontSize: 11.5, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // Save Rates Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text(
                  'Rates Save Karein',
                  style: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
