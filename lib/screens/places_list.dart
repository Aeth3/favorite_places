import 'dart:convert';
import 'dart:io';

import 'package:favorite_places/main.dart';
import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/provider/user_places.dart';
import 'package:favorite_places/screens/add_place.dart';
import 'package:favorite_places/screens/edit_place.dart';
import 'package:favorite_places/screens/places_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class PlacesList extends ConsumerStatefulWidget {
  const PlacesList({super.key});

  @override
  ConsumerState<PlacesList> createState() => _PlaceListState();
}

class _PlaceListState extends ConsumerState<PlacesList> {
  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  File fileFromBase64String(String base64String, String fileName) {
    List<int> bytes = base64.decode(base64String);

    String dir = Directory.systemTemp.path;
    String uniqueFileName =
        '${DateTime.now().millisecondsSinceEpoch}_$fileName';
    File file = File('$dir/$uniqueFileName');

    file.writeAsBytesSync(bytes);
    return file;
  }

  Future<void> _loadPlaces() async {
    final url = Uri.https(
        'places-project-b54b0-default-rtdb.asia-southeast1.firebasedatabase.app',
        'places-list.json');
    final response = await http.get(url);

    if (response.body == 'null') {
      return;
    } else if (response.statusCode >= 400) {
      throw Exception('Failed to fetch grocery items. Please try again later.');
    }

    final Map<String, dynamic> listData = json.decode(response.body);

    for (final item in listData.entries) {
      String fileName = item.value['name'] ?? 'default_name';
      String base64Image = item.value['image'] ?? '';
      if (fileName.isNotEmpty && base64Image.isNotEmpty) {
        File imageFile = fileFromBase64String(item.value['image'], fileName);
        ref.read(userPlacesNotifier.notifier).addPlace(
            item.key,
            item.value['title'],
            item.value['description'],
            imageFile,
            PlaceLocation.fromJson(item.value['location']));
      }
    }
  }

  void _addPlace(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => const AddPlace(),
    ));
  }

  void _viewDetails(context, Place place) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (context) => PlaceDetail(place: place),
    ));
  }

  void _removePlace(Place place, int index) async {
    ref.read(userPlacesNotifier.notifier).removePlace(place);
    final url = Uri.https(
        'places-project-b54b0-default-rtdb.asia-southeast1.firebasedatabase.app',
        'places-list/${place.id}.json');
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      ref.read(userPlacesNotifier.notifier).reInsertPlace(place, index);
    }
  }

  @override
  Widget build(BuildContext context) {
    final places = ref.watch(userPlacesNotifier);
    Widget content = Center(
      child: Text(
        'No places added yet',
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: Colors.white),
      ),
    );
    if (places.isNotEmpty) {
      content = ListView.builder(
        itemCount: places.length,
        itemBuilder: (context, index) => Dismissible(
          onDismissed: (direction) {
            _removePlace(places[index], index);
          },
          key: UniqueKey(),
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadiusDirectional.circular(10),
                  gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        colorScheme.background,
                        colorScheme.primary.withOpacity(0.5),
                      ])),
              child: ListTile(
                leading: CircleAvatar(
                    radius: 25,
                    backgroundImage: FileImage(places[index].image)),
                onTap: () => _viewDetails(context, places[index]),
                onLongPress: () {
                  showModalBottomSheet(
                      context: context,
                      builder: (context) {
                        return Container(
                          height: 100,
                          padding: const EdgeInsetsDirectional.symmetric(
                              vertical: 16),
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                ListTile(
                                  leading: const Icon(Icons.edit),
                                  title: const Text('Edit'),
                                  onTap: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (context) =>
                                          EditPlace(place: places[index]),
                                    ));
                                  },
                                )
                              ]),
                        );
                      });
                },
                title: Text(
                  places[index].title[0].toUpperCase() +
                      places[index].title.substring(1),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium!
                      .copyWith(color: colorScheme.onBackground),
                ),
                subtitle: places[index].location.address.isEmpty
                    ? Text('No address',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onBackground, fontSize: 11))
                    : Text(
                        places[index].location.address,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: colorScheme.onBackground, fontSize: 11),
                      ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: const Text('Your Places'),
          actions: [
            IconButton(
                onPressed: () {
                  _addPlace(context);
                },
                icon: const Icon(Icons.add))
          ],
        ),
        body: Container(
            padding: const EdgeInsets.symmetric(vertical: 8), child: content));
  }
}
