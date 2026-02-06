//------------------City name----------------------
import 'package:afriqueen/services/location/location.dart';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class CityName extends StatefulWidget {
  const CityName({super.key});

  @override
  State<CityName> createState() => _CityNameState();
}

class _CityNameState extends State<CityName> {
  Future<List<Placemark>?>? _locationFuture;

  @override
  void initState() {
    super.initState();
    _locationFuture = _getLocation();
  }

  Future<List<Placemark>?> _getLocation() async {
    final Position position = await UserLocation.determinePosition();
    return await UserLocation.geoCoding(position);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Placemark>?>(
      future: _locationFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink(); // Show loading indicator
        } else if (snapshot.hasError) {
          return Text(
            'Error: ${snapshot.error}',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          );
        } else if (snapshot.hasData && snapshot.data != null) {
          final currentLocation = snapshot.data!;
          return Center(
            child: Text(
              currentLocation.first.locality!.tr,
              style: Theme.of(context).textTheme.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          );
        } else {
          return Text(
            'Location not available',
            style: Theme.of(context).textTheme.bodySmall,
            overflow: TextOverflow.ellipsis,
          ); // Handle null data
        }
      },
    );
  }
}
