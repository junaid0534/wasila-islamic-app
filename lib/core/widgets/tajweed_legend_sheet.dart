import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';
import '../services/tajweed_parser.dart';

class TajweedLegendSheet extends StatelessWidget {
  const TajweedLegendSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const TajweedLegendSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rules = [
      _TajweedRuleItem(
        title: 'قلقلہ (Qalqalah)',
        urduDesc: 'حروفِ قطب جد (ق ، ط ، ب ، ج ، د) ساکن ہونے پر مخرج میں جھٹکا دے کر آواز لوٹانا۔',
        exampleArabic: 'خَ[q[لَ]][q[قَ]] ، سُ[q[بْ]]حٰنَ ، ٱلْفَ[q[لَ]][q[قِ]]',
        color: TajweedColors.qalqalah,
        ruleName: 'ق ، ط ، ب ، ج ، د (ساکن)',
      ),
      _TajweedRuleItem(
        title: 'غنہ (Ghunnah)',
        urduDesc: 'نون مشدد (نّ) اور میم مشدد (مّ) پر ناک کے بانسے سے ایک الف کی مقدار آواز نکالنا۔',
        exampleArabic: 'إِ[g[نَّ]] ٱللَّٰهَ ، ثُ[g[مَّ]] ٱرْجِعِ',
        color: TajweedColors.ghunnah,
        ruleName: 'نّ ، مّ (مشدد)',
      ),
      _TajweedRuleItem(
        title: 'مد / تفخیم (Madd & Tafkheem)',
        urduDesc: 'حروفِ مد کے بعد ہمزہ یا سکون آنے پر آواز کو 3 سے 5 الف تک لمبا اور پر پڑھنا۔',
        exampleArabic: 'إِ[m[سْرَآءِ]]يلَ ، [m[جَآءَ]] نَصْرُ ٱللَّٰهِ',
        color: TajweedColors.madd,
        ruleName: 'مد واجب ، منفصل ، لازم (ٓ)',
      ),
      _TajweedRuleItem(
        title: 'اخفاء (Ikhfa)',
        urduDesc: 'نون ساکن یا تنوین کے بعد 15 حروف اخفاء آئیں تو نون کی آواز ناک میں چھپا کر ادا کرنا۔',
        exampleArabic: 'مِ[f[ن دُو]]نِهِ ، عَظِ[f[يمًا فِ]]يهَا',
        color: TajweedColors.ikhfa,
        ruleName: 'نون ساکن / تنوین + 15 حروف',
      ),
      _TajweedRuleItem(
        title: 'اخفائے میم ساکن (Ikhfa-e-Meem Sakin)',
        urduDesc: 'میم ساکن کے بعد حرف (ب) آئے تو میم کو ناک میں چھپا کر غنہ کے ساتھ ادا کرنا۔',
        exampleArabic: 'تَرْمِي[c[هِم بِ]]حِجَارَةٍ',
        color: TajweedColors.ikhfaMeem,
        ruleName: 'میم ساکن + ب',
      ),
      _TajweedRuleItem(
        title: 'ادغام (Idgham)',
        urduDesc: 'نون ساکن یا تنوین کے بعد حروفِ یرملون (ی ، ر ، م ، ل ، و ، ن) آئیں تو ملا کر پڑھنا۔',
        exampleArabic: 'مَ[w[ن يَّ]]قُولُ ، مِ[w[ن مَّ]]الٍ',
        color: TajweedColors.idgham,
        ruleName: 'یرملون (ی ، ر ، م ، ل ، و ، ن)',
      ),
      _TajweedRuleItem(
        title: 'ادغام میم (Idgham-e-Meem)',
        urduDesc: 'میم ساکن کے بعد دوسری متحرک میم آئے تو ادغام مع الغنہ کرنا۔',
        exampleArabic: 'فِى قُلُوبِ[d[هِم مَّ]]رَضٌ',
        color: TajweedColors.idghamMeem,
        ruleName: 'میم ساکن + مّ',
      ),
      _TajweedRuleItem(
        title: 'قلب / اقلاب (Qalb / Iqlab)',
        urduDesc: 'نون ساکن یا تنوین کے بعد حرف (ب) آئے تو اسے چھوٹی میم (م) سے بدل کر غنہ کرنا۔',
        exampleArabic: 'مِ[i[نۢ بَ]]عْدِ ، سَمِي[i[عٌۢ بَ]]صِيرٌ',
        color: TajweedColors.qalb,
        ruleName: 'نون ساکن / تنوین + ب',
      ),
      _TajweedRuleItem(
        title: 'ساکن (Sakin & Waqf)',
        urduDesc: 'حروفِ ساکنہ اور وقف کے وقت حرف کو بغیر حرکت کے سکون کے ساتھ ٹھہرانا۔',
        exampleArabic: 'ٱلْحَمْ[s[دُ]] ، نَسْتَعِي[s[نُ]]',
        color: TajweedColors.sakin,
        ruleName: 'سکون اور وقوف (ْ)',
      ),
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.78,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Drag Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: AppColors.sageBorder,
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.palette_rounded, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Indo-Pak Tajweed Rules',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              'رنگین تجوید کے 9 قواعد (مصحف تاج کمپنی)',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.notoNastaliqUrdu(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.sageBorder),

          // Legend Rules List
          Expanded(
            child: ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final rule = rules[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.sageBorder, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            width: 13,
                            height: 13,
                            decoration: BoxDecoration(
                              color: rule.color,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: rule.color.withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Text(
                                    rule.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: rule.color.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    rule.ruleName,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.scheherazadeNew(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: rule.color,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        rule.urduDesc,
                        style: GoogleFonts.notoNastaliqUrdu(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          height: 1.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.sageBorder),
                        ),
                        child: Text.rich(
                          TajweedParser.parse(
                            rule.exampleArabic,
                            baseStyle: GoogleFonts.scheherazadeNew(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          textAlign: TextAlign.center,
                          textDirection: TextDirection.rtl,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TajweedRuleItem {
  final String title;
  final String urduDesc;
  final String exampleArabic;
  final Color color;
  final String ruleName;

  const _TajweedRuleItem({
    required this.title,
    required this.urduDesc,
    required this.exampleArabic,
    required this.color,
    required this.ruleName,
  });
}
