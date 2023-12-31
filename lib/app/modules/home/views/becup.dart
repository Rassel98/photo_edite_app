import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_editing/app/modules/home/controllers/home_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageEditScreen extends StatefulWidget {
  final File imageFile;
  final String name;
  final HomeController controller;

  const ImageEditScreen({super.key, required this.imageFile,required this.name,required this.controller});

  @override
  _ImageEditScreenState createState() => _ImageEditScreenState();
}

class _ImageEditScreenState extends State<ImageEditScreen> {
  late List<File> editedImages;
  late int currentIndex;

  @override
  void initState() {
    super.initState();
    editedImages = [widget.imageFile];
    currentIndex = 0;
  }

  Future<void> _cropImage() async {
    try{
      CroppedFile? cropped = await ImageCropper().cropImage(
          sourcePath: editedImages[currentIndex].path,
          aspectRatioPresets: [
            CropAspectRatioPreset.square,
            CropAspectRatioPreset.ratio3x2,
            CropAspectRatioPreset.original,
            CropAspectRatioPreset.ratio4x3,
            CropAspectRatioPreset.ratio16x9,
          ],
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Cropper',
                toolbarColor: Colors.deepOrange,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.original,
                lockAspectRatio: false),
            IOSUiSettings(
              title: 'Cropper',
            ),
            WebUiSettings(
              context: context,
            ),
          ]

      );

      if (cropped != null) {
        final appDir = await getApplicationDocumentsDirectory();

        final appFolder = Directory('${appDir.path}/photo_edit');
        await appFolder.create(recursive: true);
        final savedFile = File('${appFolder.path}/${widget.name}');
        savedFile.writeAsBytesSync(await cropped.readAsBytes());
        print(savedFile.path);
        setState(() {
          editedImages[currentIndex] = File(cropped.path);
        });
      }
    }on PlatformException catch (e) {
      print("Failed to pick or crop image: $e");
    }
  }
  void _rotateImage() {
    setState(() {
      File copiedImage = File(editedImages[currentIndex].path!);
      copiedImage.writeAsBytesSync(editedImages[currentIndex].readAsBytesSync().reversed.toList());
      editedImages[currentIndex] = copiedImage;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.crop),
            onPressed: _cropImage,
          ),
          IconButton(
            icon: const Icon(Icons.rotate_left),
            onPressed: _rotateImage,
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: editedImages.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(editedImages[index]),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
          );
        },
        scrollPhysics: const BouncingScrollPhysics(),
        backgroundDecoration: const BoxDecoration(
          color: Colors.black,
        ),
        pageController: PageController(),
        onPageChanged: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
