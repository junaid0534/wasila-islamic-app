import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/hijri_service.dart';

class AnimatedDatePill extends StatefulWidget {
  const AnimatedDatePill({super.key});

  @override
  State<AnimatedDatePill> createState() => _AnimatedDatePillState();
}

class _AnimatedDatePillState extends State<AnimatedDatePill> {
  bool _showHijri = true;
  Timer? _toggleTimer;

  @override
  void initState() {
    super.initState();
    _toggleTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _showHijri = !_showHijri;
        });
      }
    });
  }

  @override
  void dispose() {
    _toggleTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hijriText = HijriService.getTodayHijriUrdu();
    final adText = HijriService.getTodayGregorianEnglish();

    return Container(
      width: 132,
      height: 30,
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.sageBorder, width: 1),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              ...previousChildren,
              ?currentChild,
            ],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          final inAnimation = Tween<Offset>(
            begin: const Offset(0.0, 0.45),
            end: Offset.zero,
          ).animate(animation);

          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: inAnimation,
              child: child,
            ),
          );
        },
        child: _showHijri
            ? Row(
                key: const ValueKey('hijri_urdu_view'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.nightlight_round,
                    size: 11,
                    color: Color(0xFFE65100),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hijriText,
                    style: GoogleFonts.scheherazadeNew(
                      fontSize: 11.5,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              )
            : Row(
                key: const ValueKey('ad_english_view'),
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                    size: 11,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    adText,
                    style: GoogleFonts.poppins(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
