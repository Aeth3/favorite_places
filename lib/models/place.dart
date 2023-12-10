import 'dart:io';

import 'package:uuid/uuid.dart';

const uuid = Uuid();

class PlaceLocation {
  PlaceLocation({required this.lat, required this.lng, required this.address});

  final double lat;
  final double lng;
  late final String address;

  factory PlaceLocation.fromJson(Map<String, dynamic> json) {
    return PlaceLocation(
        lat: json['lat'] ?? 0.0,
        lng: json['lng'] ?? 0.0,
        address: json['address'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'lat': lat, 'lng': lng, 'address': address};
  }
}

class Place {
  Place(this.id,
      {required this.title,
      required this.description,
      required this.image,
      required this.location});
  final String id;
  final String title;
  final String description;
  final File image;
  final PlaceLocation location;
}

// class Place {
//   Place(
//       {required this.title,
//       required this.description,
//       required this.image,
//       required this.location
//       String? id,}) : id = id ?? uuid.v4();
//   final String id;
//   final String title;
//   final String description;
//   final File image;
//   final PlaceLocation location;
// }
