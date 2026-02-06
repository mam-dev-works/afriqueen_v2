import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class DistanceCalculator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for coordinates to avoid repeated geocoding calls
  static final Map<String, Position> _coordinateCache = {};
  
  /// Get current user's location (latitude/longitude)
  static Future<Position?> getCurrentUserLocation() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;
      
      // Try to get from Firestore first (if stored)
      final userDoc = await _firestore
          .collection('user')
          .where('id', isEqualTo: user.uid)
          .limit(1)
          .get();
      
      if (userDoc.docs.isNotEmpty) {
        final data = userDoc.docs.first.data();
        if (data['latitude'] != null && data['longitude'] != null) {
          return Position(
            latitude: (data['latitude'] as num).toDouble(),
            longitude: (data['longitude'] as num).toDouble(),
            timestamp: DateTime.now(),
            accuracy: 0,
            altitude: 0,
            altitudeAccuracy: 0,
            heading: 0,
            headingAccuracy: 0,
            speed: 0,
            speedAccuracy: 0,
          );
        }
      }
      
      // If not in Firestore, get from device GPS
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Error getting current user location: $e');
      return null;
    }
  }
  
  /// Get coordinates for a city/country (with caching)
  static Future<Position?> getCoordinatesForLocation(String city, String country) async {
    if (city.isEmpty && country.isEmpty) return null;
    
    final cacheKey = '$city,$country';
    
    // Check cache first
    if (_coordinateCache.containsKey(cacheKey)) {
      return _coordinateCache[cacheKey];
    }
    
    try {
      List<Location> locations;
      
      // Try city + country first
      if (city.isNotEmpty && country.isNotEmpty) {
        try {
          locations = await locationFromAddress('$city, $country');
        } catch (e) {
          // If that fails, try just city
          if (city.isNotEmpty) {
            locations = await locationFromAddress(city);
          } else {
            locations = await locationFromAddress(country);
          }
        }
      } else if (city.isNotEmpty) {
        locations = await locationFromAddress(city);
      } else if (country.isNotEmpty) {
        locations = await locationFromAddress(country);
      } else {
        return null;
      }
      
      if (locations.isEmpty) return null;
      
      final location = locations.first;
      final position = Position(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );
      
      // Cache the result
      _coordinateCache[cacheKey] = position;
      
      return position;
    } catch (e) {
      debugPrint('Error getting coordinates for $city, $country: $e');
      return null;
    }
  }
  
  /// Calculate distance in kilometers between two positions
  static double calculateDistanceInKm(Position position1, Position position2) {
    return Geolocator.distanceBetween(
      position1.latitude,
      position1.longitude,
      position2.latitude,
      position2.longitude,
    ) / 1000; // Convert meters to kilometers
  }
  
  /// Calculate distance between current user and another user's location
  /// Returns distance in kilometers, or null if calculation fails
  static Future<double?> calculateDistanceToUser(String userCity, String userCountry) async {
    try {
      final currentUserLocation = await getCurrentUserLocation();
      if (currentUserLocation == null) return null;
      
      final userLocation = await getCoordinatesForLocation(userCity, userCountry);
      if (userLocation == null) return null;
      
      return calculateDistanceInKm(currentUserLocation, userLocation);
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      return null;
    }
  }
  
  /// Format distance for display (e.g., "2.5 km" or "1250 km")
  static String formatDistance(double? distanceInKm) {
    if (distanceInKm == null) return 'N/A';
    
    if (distanceInKm < 1) {
      // Show in meters if less than 1 km
      return '${(distanceInKm * 1000).round()} m';
    } else if (distanceInKm < 10) {
      // Show one decimal for distances < 10 km
      return '${distanceInKm.toStringAsFixed(1)} km';
    } else {
      // Show rounded for distances >= 10 km
      return '${distanceInKm.round()} km';
    }
  }
  
  /// Clear the coordinate cache (useful for testing or memory management)
  static void clearCache() {
    _coordinateCache.clear();
  }
}

