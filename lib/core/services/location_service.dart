import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationResult {
  final double latitude;
  final double longitude;
  final String? addressDescription;
  final bool isMock;

  LocationResult({
    required this.latitude,
    required this.longitude,
    this.addressDescription,
    this.isMock = false,
  });
}

class LocationService {
  // Default coordinates from prompt specification (GCC / Field Office)
  static const double fallbackLatitude = 10.0889;
  static const double fallbackLongitude = 77.0595;

  Future<LocationResult> getCurrentLocation() async {
    // If running on desktop platforms (Windows, macOS, Linux) or Web where geolocator may not have GPS hardware
    if (kIsWeb || (!Platform.isAndroid && !Platform.isIOS)) {
      debugPrint('[LocationService] Non-mobile platform detected. Using default office coordinates.');
      return LocationResult(
        latitude: fallbackLatitude,
        longitude: fallbackLongitude,
        addressDescription: 'Main Operations HQ (10.0889, 77.0595)',
        isMock: true,
      );
    }

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('[LocationService] Location service disabled. Falling back to default.');
        return LocationResult(
          latitude: fallbackLatitude,
          longitude: fallbackLongitude,
          addressDescription: 'Default Location (GPS Disabled)',
          isMock: true,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('[LocationService] Location permission denied. Using fallback.');
          return LocationResult(
            latitude: fallbackLatitude,
            longitude: fallbackLongitude,
            addressDescription: 'Default Location (Permission Denied)',
            isMock: true,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('[LocationService] Location permission permanently denied.');
        return LocationResult(
          latitude: fallbackLatitude,
          longitude: fallbackLongitude,
          addressDescription: 'Default Location (Permission Denied Forever)',
          isMock: true,
        );
      }

      // Permissions granted, fetch high accuracy position with timeout
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return LocationResult(
        latitude: position.latitude,
        longitude: position.longitude,
        addressDescription: 'Current GPS Coordinates',
        isMock: false,
      );
    } catch (e) {
      debugPrint('[LocationService] Error fetching GPS position: $e');
      return LocationResult(
        latitude: fallbackLatitude,
        longitude: fallbackLongitude,
        addressDescription: 'Office Coordinates (Fallback)',
        isMock: true,
      );
    }
  }
}

