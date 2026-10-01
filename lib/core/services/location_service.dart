import 'package:adhan/adhan.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppCity {
  final String name;
  final String urduName;
  final String country;
  final double latitude;
  final double longitude;
  final CalculationMethod method;
  final bool isGps;

  const AppCity({
    required this.name,
    required this.urduName,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.method = CalculationMethod.karachi,
    this.isGps = false,
  });

  String get displayName => isGps ? '$name (GPS)' : '$name, $country';
}

class LocationService {
  static const String _keyLat = 'wasila_loc_lat';
  static const String _keyLng = 'wasila_loc_lng';
  static const String _keyName = 'wasila_loc_name';
  static const String _keyUrdu = 'wasila_loc_urdu';
  static const String _keyCountry = 'wasila_loc_country';
  static const String _keyIsGps = 'wasila_loc_is_gps';

  static const AppCity defaultCity = AppCity(
    name: 'Lahore',
    urduName: 'لاہور',
    country: 'Pakistan',
    latitude: 31.5204,
    longitude: 74.3587,
    method: CalculationMethod.karachi,
  );

  static final ValueNotifier<AppCity> activeLocation =
      ValueNotifier<AppCity>(defaultCity);

  static final List<AppCity> presetCities = [
    // --- Pakistan Major Cities ---
    const AppCity(name: 'Lahore', urduName: 'لاہور', country: 'Pakistan', latitude: 31.5204, longitude: 74.3587),
    const AppCity(name: 'Karachi', urduName: 'کراچی', country: 'Pakistan', latitude: 24.8607, longitude: 67.0011),
    const AppCity(name: 'Islamabad', urduName: 'اسلام آباد', country: 'Pakistan', latitude: 33.6844, longitude: 73.0479),
    const AppCity(name: 'Rawalpindi', urduName: 'راولپنڈی', country: 'Pakistan', latitude: 33.5651, longitude: 73.0169),
    const AppCity(name: 'Faisalabad', urduName: 'فیصل آباد', country: 'Pakistan', latitude: 31.4504, longitude: 73.1350),
    const AppCity(name: 'Multan', urduName: 'ملتان', country: 'Pakistan', latitude: 30.1575, longitude: 71.5249),
    const AppCity(name: 'Peshawar', urduName: 'پشاور', country: 'Pakistan', latitude: 34.0151, longitude: 71.5249),
    const AppCity(name: 'Quetta', urduName: 'کوئٹہ', country: 'Pakistan', latitude: 30.1798, longitude: 66.9750),
    const AppCity(name: 'Sialkot', urduName: 'سیالکوٹ', country: 'Pakistan', latitude: 32.4945, longitude: 74.5229),
    const AppCity(name: 'Gujranwala', urduName: 'گوجرانوالہ', country: 'Pakistan', latitude: 32.1877, longitude: 74.1945),
    const AppCity(name: 'Hyderabad', urduName: 'حیدرآباد', country: 'Pakistan', latitude: 25.3960, longitude: 68.3578),
    const AppCity(name: 'Bahawalpur', urduName: 'بہاولپور', country: 'Pakistan', latitude: 29.3544, longitude: 71.6911),
    const AppCity(name: 'Sargodha', urduName: 'سرگودھا', country: 'Pakistan', latitude: 32.0836, longitude: 72.6711),
    const AppCity(name: 'Abbottabad', urduName: 'ایبٹ آباد', country: 'Pakistan', latitude: 34.1688, longitude: 73.2215),
    const AppCity(name: 'Sukkur', urduName: 'سکھر', country: 'Pakistan', latitude: 27.7052, longitude: 68.8574),
    const AppCity(name: 'Larkana', urduName: 'لاڑکانہ', country: 'Pakistan', latitude: 27.5590, longitude: 68.2264),
    const AppCity(name: 'Sheikhupura', urduName: 'شیخوپورہ', country: 'Pakistan', latitude: 31.7131, longitude: 73.9783),
    const AppCity(name: 'Jhang', urduName: 'جھنگ', country: 'Pakistan', latitude: 31.2781, longitude: 72.3317),
    const AppCity(name: 'Rahim Yar Khan', urduName: 'رحیم یار خان', country: 'Pakistan', latitude: 28.4212, longitude: 70.2989),
    const AppCity(name: 'Gujrat', urduName: 'گجرات', country: 'Pakistan', latitude: 32.5742, longitude: 74.0754),
    const AppCity(name: 'Kasur', urduName: 'قصور', country: 'Pakistan', latitude: 31.1179, longitude: 74.4460),
    const AppCity(name: 'Mardan', urduName: 'مردان', country: 'Pakistan', latitude: 34.1989, longitude: 72.0404),
    const AppCity(name: 'Swat', urduName: 'سوات', country: 'Pakistan', latitude: 35.2227, longitude: 72.4258),
    const AppCity(name: 'Muzaffarabad', urduName: 'مظفرآباد', country: 'AJK', latitude: 34.3700, longitude: 73.4708),
    const AppCity(name: 'Mirpur', urduName: 'میرپور', country: 'AJK', latitude: 33.1484, longitude: 73.7519),
    const AppCity(name: 'Gilgit', urduName: 'گلگت', country: 'Gilgit-Baltistan', latitude: 35.9221, longitude: 74.3087),

    // --- Holy Cities & Middle East ---
    const AppCity(name: 'Makkah', urduName: 'مکہ مکرمہ', country: 'Saudi Arabia', latitude: 21.4225, longitude: 39.8262, method: CalculationMethod.muslim_world_league),
    const AppCity(name: 'Madinah', urduName: 'مدینہ منورہ', country: 'Saudi Arabia', latitude: 24.5247, longitude: 39.5692, method: CalculationMethod.muslim_world_league),
    const AppCity(name: 'Riyadh', urduName: 'ریاض', country: 'Saudi Arabia', latitude: 24.7136, longitude: 46.6753, method: CalculationMethod.muslim_world_league),
    const AppCity(name: 'Jeddah', urduName: 'جدہ', country: 'Saudi Arabia', latitude: 21.5433, longitude: 39.1728, method: CalculationMethod.muslim_world_league),
    const AppCity(name: 'Dubai', urduName: 'دبئی', country: 'UAE', latitude: 25.2048, longitude: 55.2708, method: CalculationMethod.dubai),
    const AppCity(name: 'Abu Dhabi', urduName: 'ابوظہبی', country: 'UAE', latitude: 24.4539, longitude: 54.3773, method: CalculationMethod.dubai),
    const AppCity(name: 'Doha', urduName: 'دوحہ', country: 'Qatar', latitude: 25.2854, longitude: 51.5310, method: CalculationMethod.qatar),
    const AppCity(name: 'Istanbul', urduName: 'استنبول', country: 'Turkey', latitude: 41.0082, longitude: 28.9784, method: CalculationMethod.turkey),

    // --- Global Cities ---
    const AppCity(name: 'London', urduName: 'لندن', country: 'UK', latitude: 51.5074, longitude: -0.1278, method: CalculationMethod.muslim_world_league),
    const AppCity(name: 'Birmingham', urduName: 'برمنگھم', country: 'UK', latitude: 52.4862, longitude: -1.8904, method: CalculationMethod.muslim_world_league),
    const AppCity(name: 'New York', urduName: 'نیویارک', country: 'USA', latitude: 40.7128, longitude: -74.0060, method: CalculationMethod.north_america),
    const AppCity(name: 'Chicago', urduName: 'شکاگو', country: 'USA', latitude: 41.8781, longitude: -87.6298, method: CalculationMethod.north_america),
    const AppCity(name: 'Toronto', urduName: 'ٹورنٹو', country: 'Canada', latitude: 43.6532, longitude: -79.3832, method: CalculationMethod.north_america),
    const AppCity(name: 'Sydney', urduName: 'سڈنی', country: 'Australia', latitude: -33.8688, longitude: 151.2093, method: CalculationMethod.muslim_world_league),
    const AppCity(name: 'Kuala Lumpur', urduName: 'کوالالمپور', country: 'Malaysia', latitude: 3.1390, longitude: 101.6869, method: CalculationMethod.singapore),
  ];

  static Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lat = prefs.getDouble(_keyLat);
      final lng = prefs.getDouble(_keyLng);
      final name = prefs.getString(_keyName);
      final urdu = prefs.getString(_keyUrdu);
      final country = prefs.getString(_keyCountry);
      final isGps = prefs.getBool(_keyIsGps) ?? false;

      if (lat != null && lng != null && name != null) {
        activeLocation.value = AppCity(
          name: name,
          urduName: urdu ?? name,
          country: country ?? '',
          latitude: lat,
          longitude: lng,
          isGps: isGps,
        );
      }
    } catch (_) {}
  }

  static Future<void> setLocation(AppCity city) async {
    activeLocation.value = city;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble(_keyLat, city.latitude);
      await prefs.setDouble(_keyLng, city.longitude);
      await prefs.setString(_keyName, city.name);
      await prefs.setString(_keyUrdu, city.urduName);
      await prefs.setString(_keyCountry, city.country);
      await prefs.setBool(_keyIsGps, city.isGps);
    } catch (_) {}
  }

  static Future<AppCity?> detectGpsLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 8),
      );

      final gpsCity = AppCity(
        name: 'Current Location',
        urduName: 'موجودہ مقام',
        country: 'GPS',
        latitude: position.latitude,
        longitude: position.longitude,
        isGps: true,
      );

      await setLocation(gpsCity);
      return gpsCity;
    } catch (_) {
      return null;
    }
  }
}
