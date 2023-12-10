import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class EditMapScreen extends StatefulWidget {
  const EditMapScreen({super.key, required this.onSelectedLocation});

  final void Function(PlaceLocation location) onSelectedLocation;

  @override
  State<EditMapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<EditMapScreen> {
  bool isSending = false;
  PlaceLocation _selectedLocation =
  PlaceLocation(lat: 8.391885, lng: 124.285747, address: '');
  late List<Placemark> placemarks;
  String address = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Select a location"), actions: [
        IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: isSending
                ? const SizedBox(
                    height: 16, width: 16, child: CircularProgressIndicator())
                : const Icon(Icons.check))
      ]),
      body: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(_selectedLocation.lat, _selectedLocation.lng),
            initialZoom: 17,
            onTap: (tapPosition, point) async {
              try {
                setState(() {
                  isSending = true;
                });
                placemarks = await placemarkFromCoordinates(
                    point.latitude, point.longitude);
                if (placemarks.isNotEmpty) {
                  address =
                      "${placemarks.last.subLocality!} ${placemarks.last.locality} ${placemarks.last.country}";
                }
                setState(() {
                  _selectedLocation = PlaceLocation(
                      lat: point.latitude,
                      lng: point.longitude,
                      address: address);
                });
                setState(() {
                  isSending = false;
                });
                widget.onSelectedLocation(_selectedLocation);
              } on PlatformException {
                if (mounted) {
                  setState(() {
                    widget.onSelectedLocation(PlaceLocation(
                        lat: _selectedLocation.lat,
                        lng: _selectedLocation.lng,
                        address: ''));
                    isSending = false;
                  });
                }
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(markers: [
              Marker(
                point: LatLng(_selectedLocation.lat, _selectedLocation.lng),
                width: 100,
                height: 100,
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 50,
                ),
              )
            ]),
          ]),
    );
  }
}
