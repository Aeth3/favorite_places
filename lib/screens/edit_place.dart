import 'dart:convert';
import 'dart:io';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/provider/user_places.dart';
import 'package:favorite_places/widgets/edit_image_input.dart';
import 'package:favorite_places/widgets/edit_location_input.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class EditPlace extends ConsumerStatefulWidget {
  const EditPlace({Key? key, required this.place}) : super(key: key);

  final Place place;
  @override
  ConsumerState<EditPlace> createState() => _EditPlaceState();
}

class _EditPlaceState extends ConsumerState<EditPlace> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  File? _editedImage;
  PlaceLocation _editedLocation = PlaceLocation(lat: 0, lng: 0, address: '');
  bool isSaving = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.place.title);
    _descriptionController =
        TextEditingController(text: widget.place.description);
    _editedLocation = widget.place.location;
  }

  void _updatePlace() async {
    final navigator = Navigator.of(context);
    final url = Uri.https(
        'places-project-b54b0-default-rtdb.asia-southeast1.firebasedatabase.app',
        'places-list/${widget.place.id}.json');
    final editedTitle = _titleController.text;
    final editedDescription = _descriptionController.text;

    setState(() {
      isSaving = true;
    });

    String convertedImage = base64Encode(_editedImage!.readAsBytesSync());

    await http.put(url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'title': editedTitle,
          'description': editedDescription,
          'image': convertedImage,
          'location': _editedLocation.toJson()
        }));

    ref.read(userPlacesNotifier.notifier).updatePlace(Place(widget.place.id,
        title: editedTitle,
        description: editedDescription,
        image: _editedImage!,
        location: _editedLocation));

    setState(() {
      isSaving = false;
    });
    navigator.pop();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              controller: _descriptionController,
              style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(
              height: 16,
            ),
            EditImageInput(
              onPickImage: (image) {
                _editedImage = image;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            EditLocationInput(
                onPickedLocation: (location) {
                  setState(() {
                    _editedLocation = location;
                  });
                },
                onLoading: (loading) {
                  setState(() {
                    isLoading = loading;
                  });
                },
                isSaving: isSaving),
            ElevatedButton.icon(
                onPressed: isLoading || isSaving ? null : _updatePlace,
                icon: isLoading || isSaving
                    ? const SizedBox(
                        height: 16, width: 16, child: CircularProgressIndicator())
                    : const Icon(Icons.add),
                label: const Text('Update')),
          ]),
        ),
      ),
    );
  }
}
