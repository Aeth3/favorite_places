import 'package:favorite_places/main.dart';
import 'package:favorite_places/models/place.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PlaceDetail extends StatelessWidget {
  const PlaceDetail({super.key, required this.place});

  final Place place;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(place.title[0].toUpperCase() + place.title.substring(1)),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            Image.file(
              place.image,
              fit: BoxFit.cover,
              height: double.infinity,
              width: double.infinity,
            ),
            Container(
              margin: const EdgeInsets.all(10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Card(
                        color: colorScheme.background.withAlpha(150),
                        elevation: 10,
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12)),
                          height: 100,
                          width: 200,
                          child: Column(
                            children: [
                              Text(
                                'Location',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium!
                                    .copyWith(color: colorScheme.onBackground),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Text(
                                    'Latitude',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: colorScheme.primary),
                                  ),
                                  Text(
                                    'Longitude',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge!
                                        .copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  Expanded(
                                    child: Text(
                                      place.location.lat == 0.0
                                          ? 'None'
                                          : place.location.lat.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              overflow: TextOverflow.ellipsis,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      place.location.lng == 0.0
                                          ? 'None'
                                          : place.location.lng.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                              overflow: TextOverflow.ellipsis,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onBackground),
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Card(
                    color: colorScheme.background.withAlpha(150),
                    elevation: 10,
                    child: Container(
                        padding: const EdgeInsets.all(20),
                        width: double.infinity,
                        height: 300,
                        child: Text(
                          place.description,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: colorScheme.onBackground, height: 1.5),
                        )),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 100,
                          child: ClipOval(
                            child: FlutterMap(
                                options: MapOptions(
                                    interactionOptions:
                                        const InteractionOptions(
                                            enableScrollWheel: false),
                                    initialZoom: 17,
                                    initialCenter: LatLng(place.location.lat,
                                        place.location.lng)),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  MarkerLayer(markers: [
                                    Marker(
                                      point: LatLng(place.location.lat,
                                          place.location.lng),
                                      width: 100,
                                      height: 100,
                                      child: const Icon(Icons.location_on,
                                          color: Colors.red),
                                    )
                                  ]),
                                ]),
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        place.location.address.isEmpty
                            ? Text(
                                'No address',
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                              )
                            : Text(
                                place.location.address,
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge!
                                    .copyWith(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onBackground),
                              )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }
}
