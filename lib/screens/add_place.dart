import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:favorite_places/models/place.dart';

import 'package:favorite_places/provider/user_places.dart';
import 'package:favorite_places/widgets/image_input.dart';
import 'package:favorite_places/widgets/location_input.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class AddPlace extends ConsumerStatefulWidget {
  const AddPlace({super.key});

  @override
  ConsumerState<AddPlace> createState() => _AddPlaceState();
}

class _AddPlaceState extends ConsumerState<AddPlace> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  File? enteredImage;
  PlaceLocation enteredLocation = PlaceLocation(lat: 0, lng: 0, address: '');
  var isLoading = false;
  var isSaving = false;

  void _showDialog() {
    if (Platform.isIOS) {
      showCupertinoDialog(
        context: context,
        builder: (ctx) => CupertinoAlertDialog(
          title: const Text('Unexpected Error Occured'),
          content: const Text('Please try again later.'),
          actions: [
            TextButton(
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.red)),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OKAY',
              ),
            ),
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: const Text('Unexpected Error Occured'),
          content: const Text('Please try again later.'),
          actions: [
            TextButton(
              style: const ButtonStyle(
                  foregroundColor: MaterialStatePropertyAll(Colors.red)),
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'OKAY',
              ),
            ),
          ],
        ),
      );
    }
  }

  void _savePlace() async {
    final navigator = Navigator.of(context);
    final url = Uri.https(
        'places-project-b54b0-default-rtdb.asia-southeast1.firebasedatabase.app',
        'places-list.json');
    final enteredTitle = _titleController.text;
    final enteredDescription = _descriptionController.text;
    if (enteredTitle.isEmpty || enteredImage == null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          actionsAlignment: MainAxisAlignment.center,
          title: const Text('Error'),
          content: const Text('Title or image must NOT be empty.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    } else {
      try {
        setState(() {
          isSaving = true;
        });
        String convertedImage = base64Encode(enteredImage!.readAsBytesSync());

        final response = await http
            .post(url,
                headers: {'Content-Type': 'application/json'},
                body: json.encode({
                  'title': enteredTitle,
                  'description': enteredDescription,
                  'image': convertedImage,
                  'location': enteredLocation.toJson()
                }))
            .timeout(const Duration(minutes: 1));

        final Map<String, dynamic> resData = json.decode(response.body);
        final firebaseKey = resData['name'];

        ref.read(userPlacesNotifier.notifier).addPlace(firebaseKey,
            enteredTitle, enteredDescription, enteredImage!, enteredLocation);
      } on TimeoutException {
        _showDialog();
      }

      navigator.pop();
    }
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
        title: Text(
          'Add New Place',
          style: Theme.of(context)
              .textTheme
              .titleMedium!
              .copyWith(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Title'),
              controller: _titleController,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(
              height: 16,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              controller: _descriptionController,
              style:
                  TextStyle(color: Theme.of(context).colorScheme.onBackground),
            ),
            const SizedBox(
              height: 16,
            ),
            ImageInput(
              onPickImage: (image) {
                enteredImage = image;
              },
            ),
            const SizedBox(
              height: 16,
            ),
            LocationInput(
                onPickedLocation: (location) {
                  setState(() {
                    enteredLocation = location;
                  });
                },
                onLoading: (loading) {
                  setState(() {
                    isLoading = loading;
                  });
                },
                isSaving: isSaving),
            ElevatedButton.icon(
                onPressed: isLoading || isSaving ? null : _savePlace,
                icon: isLoading || isSaving
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator())
                    : const Icon(Icons.add),
                label: const Text('Add Place')),
          ],
        ),
      ),
    );
  }
}
