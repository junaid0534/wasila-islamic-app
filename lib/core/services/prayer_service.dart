import 'package:adhan/adhan.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

class PrayerInfo {
  final String name;
  final String arabicName;
  final String urduName;
  final DateTime startTime;
  final DateTime endTime;
  final bool isCurrent;
  final bool isNext;
  final bool isPassed;

  PrayerInfo({
    required this.name,
    required this.arabicName,
    required this.urduName,
    required this.startTime,
    required this.endTime,
    this.isCurrent = false,
    this.isNext = false,
    this.isPassed = false,
  });

  String get formattedStartTime => DateFormat('hh:mm a').format(startTime);
  String get formattedEndTime => DateFormat('hh:mm a').format(endTime);
  String get timeRangeFormatted => '$formattedStartTime - $formattedEndTime';

  Duration get remainingTime {
    final now = DateTime.now();
    if (isCurrent) {
      final rem = endTime.difference(now);
      return rem.isNegative ? Duration.zero : rem;
    } else if (isNext) {
      final rem = startTime.difference(now);
      return rem.isNegative ? Duration.zero : rem;
    }
    return Duration.zero;
  }

  double get progressPercentage {
    final now = DateTime.now();
    if (now.isBefore(startTime)) return 0.0;
    if (now.isAfter(endTime)) return 1.0;
    final total = endTime.difference(startTime).inSeconds;
    if (total <= 0) return 0.0;
    final elapsed = now.difference(startTime).inSeconds;
    return (elapsed / total).clamp(0.0, 1.0);
  }
}

class SpecialTimeInfo {
  final String name;
  final String urduName;
  final DateTime startTime;
  final DateTime? endTime;
  final String subtitle;
  final bool isMakrooh;

  SpecialTimeInfo({
    required this.name,
    required this.urduName,
    required this.startTime,
    this.endTime,
    required this.subtitle,
    this.isMakrooh = false,
  });

  String get formattedStartTime => DateFormat('hh:mm a').format(startTime);
  String get formattedEndTime =>
      endTime != null ? DateFormat('hh:mm a').format(endTime!) : '';
  String get formattedRange => endTime != null
      ? '$formattedStartTime - $formattedEndTime'
      : formattedStartTime;
}

class PrayerSchedule {
  final List<PrayerInfo> prayers;
  final PrayerInfo? currentPrayer;
  final PrayerInfo? nextPrayer;
  final DateTime sunriseTime;
  final DateTime ishraqTime;
  final DateTime zawalStartTime;
  final DateTime zawalEndTime;
  final DateTime makroohAsrStartTime;
  final DateTime makroohAsrEndTime;
  final DateTime sehriEndTime;
  final String locationName;
  final bool isCurrentlyMakroohTime;
  final String? makroohWarningText;

  PrayerSchedule({
    required this.prayers,
    required this.currentPrayer,
    required this.nextPrayer,
    required this.sunriseTime,
    required this.ishraqTime,
    required this.zawalStartTime,
    required this.zawalEndTime,
    required this.makroohAsrStartTime,
    required this.makroohAsrEndTime,
    required this.sehriEndTime,
    required this.locationName,
    this.isCurrentlyMakroohTime = false,
    this.makroohWarningText,
  });

  String get formattedSunrise => DateFormat('hh:mm a').format(sunriseTime);
  String get formattedIshraq => DateFormat('hh:mm a').format(ishraqTime);
  String get formattedZawalRange =>
      '${DateFormat('hh:mm a').format(zawalStartTime)} - ${DateFormat('hh:mm a').format(zawalEndTime)}';
  String get formattedMakroohAsrRange =>
      '${DateFormat('hh:mm a').format(makroohAsrStartTime)} - ${DateFormat('hh:mm a').format(makroohAsrEndTime)}';
  String get formattedSehriEnd => DateFormat('hh:mm a').format(sehriEndTime);

  String get statusCountdownText {
    final now = DateTime.now();
    if (currentPrayer != null) {
      final rem = currentPrayer!.endTime.difference(now);
      final hours = rem.inHours;
      final minutes = rem.inMinutes.remainder(60);
      final sec = rem.inSeconds.remainder(60);
      if (hours > 0) {
        return '${currentPrayer!.name} ends in ${hours}h ${minutes}m';
      } else {
        return '${currentPrayer!.name} ends in ${minutes}m ${sec}s';
      }
    } else if (nextPrayer != null) {
      final rem = nextPrayer!.startTime.difference(now);
      final hours = rem.inHours;
      final minutes = rem.inMinutes.remainder(60);
      final sec = rem.inSeconds.remainder(60);
      if (hours > 0) {
        return '${nextPrayer!.name} in ${hours}h ${minutes}m';
      } else {
        return '${nextPrayer!.name} in ${minutes}m ${sec}s';
      }
    }
    return '';
  }

  String get statusUrduSubtitle {
    if (isCurrentlyMakroohTime && makroohWarningText != null) {
      return makroohWarningText!;
    }
    if (currentPrayer != null) {
      return '${currentPrayer!.urduName} کا وقت ختم ہونے میں';
    } else if (nextPrayer != null) {
      return '${nextPrayer!.urduName} کا وقت شروع ہونے میں';
    }
    return '';
  }
}

class PrayerService {
  // Default coordinates (Lahore / Pakistan)
  static const double defaultLat = 31.5204;
  static const double defaultLng = 74.3587;
  static const String defaultCity = 'Lahore, Pakistan';

  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 5),
      );
    } catch (_) {
      return null;
    }
  }

  static PrayerSchedule calculatePrayerTimes({
    double lat = defaultLat,
    double lng = defaultLng,
    String cityName = defaultCity,
    CalculationMethod method = CalculationMethod.karachi,
    Madhab madhab = Madhab.hanafi,
  }) {
    final myCoordinates = Coordinates(lat, lng);
    final params = method.getParameters();
    params.madhab = madhab;

    final now = DateTime.now();

    // 1. Calculate for Today, Yesterday & Tomorrow to handle Midnight boundary accurately
    final todayComponents = DateComponents.from(now);
    final todayPT = PrayerTimes(myCoordinates, todayComponents, params);

    final yesterdayComponents =
        DateComponents.from(now.subtract(const Duration(days: 1)));
    final yesterdayPT =
        PrayerTimes(myCoordinates, yesterdayComponents, params);

    final tomorrowComponents =
        DateComponents.from(now.add(const Duration(days: 1)));
    final tomorrowPT = PrayerTimes(myCoordinates, tomorrowComponents, params);

    // 2. Special Prohibited (Makrooh) & Sunnah Times Calculation
    // Zawal / Nisf-un-Nahar (15 mins before Dhuhr until Dhuhr start)
    final zawalStart = todayPT.dhuhr.subtract(const Duration(minutes: 15));
    final zawalEnd = todayPT.dhuhr;

    // Makrooh time before Maghrib (18 mins before Sunset / Maghrib)
    final makroohAsrStart =
        todayPT.maghrib.subtract(const Duration(minutes: 18));
    final makroohAsrEnd = todayPT.maghrib;

    // Sunrise Makrooh time (Sunrise until 15 mins after sunrise)
    final sunriseStart = todayPT.sunrise;
    final ishraqTime = todayPT.sunrise.add(const Duration(minutes: 15));

    // Sehri / Tahajjud End
    final sehriEndTime = todayPT.fajr;

    // Check if right now is Makrooh / Prohibited prayer time
    bool isMakrooh = false;
    String? makroohText;

    if (now.isAfter(zawalStart) && now.isBefore(zawalEnd)) {
      isMakrooh = true;
      makroohText = 'مکروہ وقت: زوالِ آفتاب (نماز ممنوع ہے)';
    } else if (now.isAfter(sunriseStart) && now.isBefore(ishraqTime)) {
      isMakrooh = true;
      makroohText = 'مکروہ وقت: طلوعِ آفتاب (نماز ممنوع ہے)';
    } else if (now.isAfter(makroohAsrStart) && now.isBefore(makroohAsrEnd)) {
      isMakrooh = true;
      makroohText = 'مکروہ وقت: غروبِ آفتاب (قضا/نفل مکروہ ہے)';
    }

    // 3. Exact Start & End Times for 5 Prayers for the active day view
    // Fajr: Today Fajr -> Today Sunrise
    final fajrStart = todayPT.fajr;
    final fajrEnd = todayPT.sunrise;

    // Dhuhr: Today Dhuhr -> Today Asr
    final dhuhrStart = todayPT.dhuhr;
    final dhuhrEnd = todayPT.asr;

    // Asr: Today Asr -> Today Maghrib
    final asrStart = todayPT.asr;
    final asrEnd = todayPT.maghrib;

    // Maghrib: Today Maghrib -> Today Isha
    final maghribStart = todayPT.maghrib;
    final maghribEnd = todayPT.isha;

    // Isha handling with Midnight Transition:
    // If now is between 00:00:00 and today's Fajr (e.g. 00:32 AM):
    // Active Isha started yesterday evening (yesterdayPT.isha) and ends at today's Fajr (todayPT.fajr)!
    // Today's evening Isha starts at todayPT.isha and ends at tomorrowPT.fajr.
    final bool isMidnightPreFajr = now.isBefore(todayPT.fajr);

    final ishaDisplayStart =
        isMidnightPreFajr ? yesterdayPT.isha : todayPT.isha;
    final ishaDisplayEnd =
        isMidnightPreFajr ? todayPT.fajr : tomorrowPT.fajr;

    // Check which prayer is currently active right now
    final bool isCurrentFajr =
        now.isAfter(fajrStart) && now.isBefore(fajrEnd);
    final bool isCurrentDhuhr =
        now.isAfter(dhuhrStart) && now.isBefore(dhuhrEnd);
    final bool isCurrentAsr = now.isAfter(asrStart) && now.isBefore(asrEnd);
    final bool isCurrentMaghrib =
        now.isAfter(maghribStart) && now.isBefore(maghribEnd);
    final bool isCurrentIsha = isMidnightPreFajr ||
        (now.isAfter(todayPT.isha) &&
            now.isBefore(DateTime(now.year, now.month, now.day, 23, 59, 59, 999)));

    final List<PrayerInfo> prayerList = [
      PrayerInfo(
        name: 'Fajr',
        arabicName: 'الفجر',
        urduName: 'فجر',
        startTime: fajrStart,
        endTime: fajrEnd,
        isCurrent: isCurrentFajr,
        isPassed: now.isAfter(fajrEnd),
      ),
      PrayerInfo(
        name: 'Dhuhr',
        arabicName: 'الظهر',
        urduName: 'ظہر',
        startTime: dhuhrStart,
        endTime: dhuhrEnd,
        isCurrent: isCurrentDhuhr,
        isPassed: now.isAfter(dhuhrEnd),
      ),
      PrayerInfo(
        name: 'Asr',
        arabicName: 'العصر',
        urduName: 'عصر',
        startTime: asrStart,
        endTime: asrEnd,
        isCurrent: isCurrentAsr,
        isPassed: now.isAfter(asrEnd),
      ),
      PrayerInfo(
        name: 'Maghrib',
        arabicName: 'المغرب',
        urduName: 'مغرب',
        startTime: maghribStart,
        endTime: maghribEnd,
        isCurrent: isCurrentMaghrib,
        isPassed: now.isAfter(maghribEnd),
      ),
      PrayerInfo(
        name: 'Isha',
        arabicName: 'العشاء',
        urduName: 'عشاء',
        startTime: ishaDisplayStart,
        endTime: ishaDisplayEnd,
        isCurrent: isCurrentIsha,
        isPassed: !isMidnightPreFajr && now.isBefore(todayPT.isha),
      ),
    ];

    // Determine current active prayer
    PrayerInfo? current;
    for (final p in prayerList) {
      if (p.isCurrent) {
        current = p;
        break;
      }
    }

    // Determine next upcoming prayer
    PrayerInfo next;
    if (isMidnightPreFajr) {
      // At midnight before Fajr, next is Fajr today!
      next = prayerList[0]; // Fajr
    } else {
      PrayerInfo? found;
      for (final p in prayerList) {
        if (now.isBefore(p.startTime)) {
          found = p;
          break;
        }
      }
      // If all today's prayers passed (late night after Isha start), next is tomorrow's Fajr
      next = found ??
          PrayerInfo(
            name: 'Fajr',
            arabicName: 'الفجر',
            urduName: 'فجر',
            startTime: tomorrowPT.fajr,
            endTime: tomorrowPT.sunrise,
            isNext: true,
          );
    }

    final nextIdx = prayerList.indexWhere((p) => p.name == next.name);
    if (nextIdx >= 0) {
      prayerList[nextIdx] = PrayerInfo(
        name: prayerList[nextIdx].name,
        arabicName: prayerList[nextIdx].arabicName,
        urduName: prayerList[nextIdx].urduName,
        startTime: prayerList[nextIdx].startTime,
        endTime: prayerList[nextIdx].endTime,
        isCurrent: prayerList[nextIdx].isCurrent,
        isNext: true,
        isPassed: prayerList[nextIdx].isPassed,
      );
    }

    return PrayerSchedule(
      prayers: prayerList,
      currentPrayer: current,
      nextPrayer: next,
      sunriseTime: todayPT.sunrise,
      ishraqTime: ishraqTime,
      zawalStartTime: zawalStart,
      zawalEndTime: zawalEnd,
      makroohAsrStartTime: makroohAsrStart,
      makroohAsrEndTime: makroohAsrEnd,
      sehriEndTime: sehriEndTime,
      locationName: cityName,
      isCurrentlyMakroohTime: isMakrooh,
      makroohWarningText: makroohText,
    );
  }
}
