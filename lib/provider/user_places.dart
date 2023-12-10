import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserPlaceNotifier extends StateNotifier<List<Place>> {
  UserPlaceNotifier() : super(const []);

  void addPlace(String firebaseKey, String title, String description,
      File image, PlaceLocation location) {
    final newPlace = Place(firebaseKey,
        title: title,
        description: description,
        image: image,
        location: location);
    state = [newPlace, ...state];
  }

  void removePlace(Place place) {
    state = state.where((element) => element != place).toList();
  }

  void reInsertPlace(Place place, int index) {
    state = [...state]..insert(index, place);
  }

  void updatePlace(Place place) {
    state = state.map((p) => p.id == place.id ? place : p).toList();
  }
}

final userPlacesNotifier =
    StateNotifierProvider<UserPlaceNotifier, List<Place>>(
        (ref) => UserPlaceNotifier());
