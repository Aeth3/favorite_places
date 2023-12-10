import 'dart:async';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/edit_map_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:geocoding/geocoding.dart' as geo;
import 'package:location/location.dart';
import 'package:latlong2/latlong.dart';

class EditLocationInput extends StatefulWidget {
  const EditLocationInput(
      
      {super.key,
      required this.onPickedLocation,
      required this.onLoading,
      required this.isSaving});

  final void Function(PlaceLocation location) onPickedLocation;
  final void Function(bool loading) onLoading;
  final bool isSaving;
  @override
  State<EditLocationInput> createState() => LocationInputState();
}

class LocationInputState extends State<EditLocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  late Widget previewContent;
  var _retryAllowed = false;

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;
    Duration duration = const Duration(minutes: 1);
    List<geo.Placemark> placemarks;
    String address;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    try {
      setState(() {
        _isGettingLocation = true;
        widget.onLoading(_isGettingLocation);
      });

      locationData = await location.getLocation().timeout(duration);
      final lat = locationData.latitude;
      final lng = locationData.longitude;

      if (lat == null || lng == null) {
        return;
      } else {
        placemarks = await geo.placemarkFromCoordinates(lat, lng);
        if (placemarks.isEmpty) {
          address = 'Unknown Location';
        } else {
          address =
              "${placemarks.last.street} ${placemarks.last.administrativeArea!} ${placemarks.last.country!}";
        }

        setState(() {
          _pickedLocation = PlaceLocation(lat: lat, lng: lng, address: address);
          _isGettingLocation = false;
        });
      }
      widget.onLoading(_isGettingLocation);
      widget.onPickedLocation(_pickedLocation!);
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
          _retryAllowed = true;
          
        });
        widget.onLoading(_isGettingLocation);
      }
    } on PlatformException {
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
          _retryAllowed = true;
          
        });
        widget.onLoading(_isGettingLocation);
      }
    }
  }

  void _selectOnMap() {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => EditMapScreen(
        onSelectedLocation: (location) {
          setState(() {
            _pickedLocation = location;
            _retryAllowed = false;
          });
          widget.onPickedLocation(_pickedLocation!);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      previewContent = _pickedLocation != null
          ? FlutterMap(
              options: MapOptions(
                  initialZoom: 17,
                  initialCenter:
                      LatLng(_pickedLocation!.lat, _pickedLocation!.lng)),
              children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  MarkerLayer(markers: [
                    Marker(
                      point: LatLng(_pickedLocation!.lat, _pickedLocation!.lng),
                      width: 100,
                      height: 100,
                      child: const Icon(Icons.location_on, color: Colors.red),
                    )
                  ]),
                ])
          : Text(
              textAlign: TextAlign.center,
              'No location chosen. (Optional)',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onBackground),
            );
    });

    if (_isGettingLocation) {
      previewContent = const CircularProgressIndicator();
    } else if (_retryAllowed) {
      previewContent = Text(
        textAlign: TextAlign.center,
        'Error Occured. Try again!',
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Theme.of(context).colorScheme.onBackground),
      );
    }
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
          ),
          height: 170,
          width: double.infinity,
          child: previewContent,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          TextButton.icon(
              onPressed: _isGettingLocation || widget.isSaving
                  ? null
                  : _getCurrentLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Get Current Location')),
          TextButton.icon(
              onPressed:
                  _isGettingLocation || widget.isSaving ? null : _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select From Map')),
        ]),
      ],
    );
  }
}
