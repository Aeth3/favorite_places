import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditImageInput extends StatefulWidget {
  const EditImageInput({super.key, required this.onPickImage});

  //Use callback function if you want to pass an object back to the parent widget
  final void Function(File image) onPickImage;

  @override
  State<EditImageInput> createState() => _ImageInputState();
}

class _ImageInputState extends State<EditImageInput> {
  File? _selectedImage;
  final imagePicker = ImagePicker();

  void _takePicture() async {
    
    final pickedImage =
        await imagePicker.pickImage(source: ImageSource.camera, maxWidth: 600);
    if (pickedImage == null) {
      return;
    } else {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
    widget.onPickImage(_selectedImage!);
  }

  void _getPicture() async {
    final pickedGalleryImage =
        await imagePicker.pickImage(source: ImageSource.gallery, maxWidth: 600);
    if (pickedGalleryImage == null) {
      return;
    } else {
      setState(() {
        _selectedImage = File(pickedGalleryImage.path);
      });
      widget.onPickImage(_selectedImage!);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content =
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
      TextButton.icon(
          onPressed: _takePicture,
          icon: const Icon(Icons.camera),
          label: const Text('Take Picture')),
      TextButton.icon(
          onPressed: _getPicture,
          icon: const Icon(Icons.image),
          label: const Text('Select From Gallery'))
    ]);
    if (_selectedImage != null) {
      content = GestureDetector(
        onTap: _takePicture,
        child: Image.file(
          _selectedImage!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
          border: Border.all(
              width: 1,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.2))),
      height: 250,
      width: double.infinity,
      alignment: Alignment.center,
      child: content,
    );
  }
}
