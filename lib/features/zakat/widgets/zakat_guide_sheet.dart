import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';

class ZakatGuideSheet extends StatelessWidget {
  const ZakatGuideSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
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
                  Icons.menu_book_rounded,
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
                      'Zakat Rules & Guide',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Shariat ke mutabiq Zakat ke zaroori masail',
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
          const SizedBox(height: 14),

          // Guide Content List
          Expanded(
            child: ListView(
              children: [
                _buildGuideCard(
                  icon: Icons.scale_rounded,
                  title: '1. Nisab (نصاب) kiya hai?',
                  urduSubtitle: 'زکوٰۃ فرض ہونے کا شرعی معیار',
                  content:
                      '• **Sona (Gold) ka Nisab:** 7.5 Tola (87.48 Grams)\n• **Chandi (Silver) ka Nisab:** 52.5 Tola (612.36 Grams)\n\nAgar kisi ke paas sirf sona ho toh 7.5 tola ka hisab hoga. Lekin agar sonay ke sath naqad raqam ya chandi bhi ho toh **52.5 tola chandi** ki qeemat ka nisab lagoo hota hai taakay ghareebon ka zyada faida ho.',
                ),
                _buildGuideCard(
                  icon: Icons.person_rounded,
                  title: '2. Kis shakhs par Zakat Farz hai?',
                  urduSubtitle: 'صاحبِ نصاب مسلمان',
                  content:
                      '• Musalman, aaqil aur baaligh ho.\n• Zaroorat-e-asliyya (bunyadi zarooriyat) aur qarz se zaid maal nisab ke barabar ho.\n• Us maal par **1 Qamri Saal (Lunar Year)** guzar chuka ho (Hawlan al-Hawl).',
                ),
                _buildGuideCard(
                  icon: Icons.percent_rounded,
                  title: '3. Kitni Zakat Ada Karni Hoti Hai?',
                  urduSubtitle: 'شرح زکوٰۃ: اڑھائی فیصد',
                  content:
                      'Kul qabil-e-zakat maal par **2.5% (40wan hissa / 1/40)** Zakat ada karna farz hai.',
                ),
                _buildGuideCard(
                  icon: Icons.check_circle_outline_rounded,
                  title: '4. Jin Cheezon Par Zakat Farz Hai:',
                  urduSubtitle: 'اموالِ زکوٰۃ',
                  content:
                      '✔ Har qism ka sona aur chandi (chahe zewar ho ya dhalay huay).\n✔ Naqad raqam (Cash in hand, Bank accounts, Savings, Prize Bonds).\n✔ Tijarat ka maal (Resale ke liye kharidi gayi items / stock).\n✔ Shares, Mutual funds aur Trade ke liye li gayi Property.',
                ),
                _buildGuideCard(
                  icon: Icons.highlight_off_rounded,
                  title: '5. Jin Cheezon Par Zakat Nahi Hoti:',
                  urduSubtitle: 'ضرورتِ اصلیہ کے سامان پر زکوٰۃ نہیں',
                  content:
                      '✖ Rehaishi ghar (apna zati makaan).\n✖ Zati istemal ki gaari (car / motorcycle).\n✖ Ghar ka furniture, kapray, bartan aur electronic appliances.\n✖ Karobari machinery, tools ya dukan ki zameen (tijarat ke maal par hogi, factory/machinery par nahi).',
                ),
                _buildGuideCard(
                  icon: Icons.volunteer_activism_rounded,
                  title: '6. Masarif-e-Zakat (Zakat kis ko de saktay hain?)',
                  urduSubtitle: 'قرآن پاک (سورۃ التوبہ: 60) کے 8 مصارف',
                  content:
                      '1. **Fuqara** (Nihayat ghareeb jinke paas kuch na ho)\n2. **Masakeen** (Zarooratmand log)\n3. **Aamileen** (Zakat ikatha karne walay idaray)\n4. **Muallafat-ul-Quloob**\n5. **Gharimeen** (Maqrooz log jo qarz ada na kar sakte hon)\n6. **Ghulamon ki azaadi**\n7. **Fi Sabeelillah** (Deen ke raste me)\n8. **Ibn-us-Sabeel** (Musaafir jo safar me be-yar-o-madadgaar ho)',
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideCard({
    required IconData icon,
    required String title,
    required String urduSubtitle,
    required String content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sageBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.sageLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColors.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      urduSubtitle,
                      style: GoogleFonts.notoNastaliqUrdu(
                        fontSize: 11,
                        color: AppColors.primary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.poppins(
              fontSize: 11.5,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
