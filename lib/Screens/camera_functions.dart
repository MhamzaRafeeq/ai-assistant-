import 'dart:typed_data';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';

class CameraFunctions extends StatefulWidget {
  const CameraFunctions({super.key});

  @override
  State<CameraFunctions> createState() => _CameraFunctionsState();
}

class _CameraFunctionsState extends State<CameraFunctions> {
  String firstButtonText = 'Pick From Camera';

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();

    final image = await picker.pickImage(source: ImageSource.camera);
    if (image == null) return;


    setState(() {
      firstButtonText = 'Saving in progress...';
    });
    try{
      await Gal.putImage(image.path);
      print('image is saved');
    }catch(e){
      print('error in image: $e');
    }

    setState(() {
      firstButtonText = 'Pick Image From Camera';
    });

    // ✅ Convert image to bytes
    // final Uint8List imageBytes = await recordedImage.readAsBytes();

    // ✅ Save to gallery
    // final result = await ImageGallerySaver.saveImage(
    //   imageBytes,
    //   quality: 100,
    //   name: 'camera_${DateTime.now().millisecondsSinceEpoch}',
    // );
    //
    // debugPrint('Save result: $result');
    // debugPrint('Image path: ${recordedImage.path}');

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: pickImage,
          child: Text(firstButtonText),
        ),
      ),
    );
  }
}
