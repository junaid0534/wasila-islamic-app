import 'dart:math';

class QiblaCoordinate {
  static const double kaabaLatitude = 21.422487;
  static const double kaabaLongitude = 39.826206;
}

class QiblaInfo {
  final double qiblaAngle; // Angle from True North (0° - 360°)
  final double distanceKm; // Distance to Kaaba in km
  final String directionText; // e.g., 'WSW' or 'مغرب-جنوب'
  final String cityName;

  const QiblaInfo({
    required this.qiblaAngle,
    required this.distanceKm,
    required this.directionText,
    required this.cityName,
  });
}

class QiblaService {
  /// Calculate precise Qibla bearing angle using Great-Circle Spherical Trigonometry
  static double calculateQiblaAngle(double latitude, double longitude) {
    final double phi1 = latitude * (pi / 180.0);
    final double phi2 = QiblaCoordinate.kaabaLatitude * (pi / 180.0);
    final double deltaLambda = (QiblaCoordinate.kaabaLongitude - longitude) * (pi / 180.0);

    final double y = sin(deltaLambda) * cos(phi2);
    final double x = cos(phi1) * sin(phi2) - sin(phi1) * cos(phi2) * cos(deltaLambda);

    double bearing = atan2(y, x) * (180.0 / pi);
    bearing = (bearing + 360.0) % 360.0;
    return double.parse(bearing.toStringAsFixed(1));
  }

  /// Calculate distance in km to Kaaba using the Haversine formula
  static double calculateDistanceToKaaba(double latitude, double longitude) {
    const double earthRadiusKm = 6371.0;
    final double phi1 = latitude * (pi / 180.0);
    final double phi2 = QiblaCoordinate.kaabaLatitude * (pi / 180.0);
    final double deltaPhi = (QiblaCoordinate.kaabaLatitude - latitude) * (pi / 180.0);
    final double deltaLambda = (QiblaCoordinate.kaabaLongitude - longitude) * (pi / 180.0);

    final double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return double.parse((earthRadiusKm * c).toStringAsFixed(0));
  }

  /// Convert degree angle to cardinal direction text
  static String getDirectionText(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return 'N (شمال)';
    if (degrees >= 22.5 && degrees < 67.5) return 'NE (شمال-مشرق)';
    if (degrees >= 67.5 && degrees < 112.5) return 'E (مشرق)';
    if (degrees >= 112.5 && degrees < 157.5) return 'SE (جنوب-مشرق)';
    if (degrees >= 157.5 && degrees < 202.5) return 'S (جنوب)';
    if (degrees >= 202.5 && degrees < 247.5) return 'SW (جنوب-مغرب)';
    if (degrees >= 247.5 && degrees < 292.5) return 'W (مغرب - قبلہ رخ)';
    if (degrees >= 292.5 && degrees < 337.5) return 'NW (شمال-مغرب)';
    return 'WSW (قبلہ رخ)';
  }

  /// Get full Qibla information for a location
  static QiblaInfo getQiblaInfo({
    required double latitude,
    required double longitude,
    String cityName = 'Pakistan',
  }) {
    final angle = calculateQiblaAngle(latitude, longitude);
    final distance = calculateDistanceToKaaba(latitude, longitude);
    final direction = getDirectionText(angle);

    return QiblaInfo(
      qiblaAngle: angle,
      distanceKm: distance,
      directionText: direction,
      cityName: cityName,
    );
  }
}
