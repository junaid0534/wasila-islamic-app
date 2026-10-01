import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';

class HijriService {
  static const List<String> urduIslamicMonths = [
    '',
    'محرم',
    'صفر',
    'ربیع الاول',
    'ربیع الثانی',
    'جمادی الاول',
    'جمادی الثانی',
    'رجب',
    'شعبان',
    'رمضان',
    'شوال',
    'ذوالقعدہ',
    'ذوالحجہ',
  ];

  static String getTodayHijriUrdu() {
    final today = HijriCalendar.now();
    final monthName = (today.hMonth >= 1 && today.hMonth <= 12)
        ? urduIslamicMonths[today.hMonth]
        : today.longMonthName;
    return '${today.hDay} $monthName ${today.hYear}';
  }

  static String getTodayGregorianEnglish() {
    final now = DateTime.now();
    return DateFormat('dd MMM yyyy').format(now);
  }

  static String getTodayHijriFormatted() {
    HijriCalendar.setLocal('en');
    final today = HijriCalendar.now();
    return '${today.hDay} ${today.longMonthName} ${today.hYear} AH';
  }

  static String getTodayGregorianFormatted() {
    final now = DateTime.now();
    return DateFormat('EEEE, d MMMM yyyy').format(now);
  }

  static HijriCalendar getNow() {
    return HijriCalendar.now();
  }
}
