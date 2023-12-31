import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomeController extends GetxController {
  final RxList<XFile> selectedImages = <XFile>[].obs;
  final RxList<File> loadedImages = <File>[].obs;

  List<File> editedImages = [];
  RxInt currentIndex = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    await requestStoragePermission();
    await _loadImages();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  Future<void> pickImages() async {
    List<XFile>? result = await ImagePicker().pickMultiImage();
    if (result != null && result.isNotEmpty) {
      selectedImages.assignAll(result);
    }
  }

  Future<void> _loadImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final imagesDir = Directory('${appDir.path}/photo_edit');
    loadedImages.clear();
    if (await imagesDir.exists()) {
      List<FileSystemEntity> files = await imagesDir.list().toList();
      List<File> imageFiles = files.whereType<File>().toList();
      loadedImages.assignAll(imageFiles);
    }
  }

  Future<void> requestStoragePermission() async {
    if (await Permission.storage.isGranted) {
      return;
    }
    var status = await Permission.storage.request();
    if (status == PermissionStatus.granted) {
      print('Storage permission granted');
    } else {
      requestStoragePermission();
      print('Storage permission denied');
    }
  }

  Future<void> saveImages() async {
    final appDir = await getApplicationDocumentsDirectory();
    final appFolder = Directory('${appDir.path}/photo_edit');
    await appFolder.create(recursive: true);
    for (var i in selectedImages) {
      final savedFile = File('${appFolder.path}/${i.name}');
      savedFile.writeAsBytesSync(await i.readAsBytes());
      print(savedFile.path);
    }
    Fluttertoast.showToast(
        msg: "Image saved successfully",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0);
    _loadImages();
    Get.back();
  }

  Future<void> cropImage(String name, int index) async {
    try {
      CroppedFile? cropped = await ImageCropper().cropImage(sourcePath: selectedImages[index].path, aspectRatioPresets: [
        CropAspectRatioPreset.square,
        CropAspectRatioPreset.ratio3x2,
        CropAspectRatioPreset.original,
        CropAspectRatioPreset.ratio4x3,
        CropAspectRatioPreset.ratio16x9,
      ], uiSettings: [
        AndroidUiSettings(
            toolbarTitle: 'Cropper', toolbarColor: Colors.deepOrange, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.original, lockAspectRatio: false),
        IOSUiSettings(
          title: 'Cropper',
        ),
      ]);

      if (cropped != null) {
        // final appDir = await getApplicationDocumentsDirectory();
        // final appFolder = Directory('${appDir.path}/photo_edit');
        // await appFolder.create(recursive: true);
        // final savedFile = File('${appFolder.path}/$name');
        // savedFile.writeAsBytesSync(await cropped.readAsBytes());
        // print(savedFile.path);
        editedImages[currentIndex.value] = File(cropped.path);
        selectedImages[index] = XFile(cropped.path);
        Get.back();
      }
    } on PlatformException catch (e) {
      print("Failed to pick or crop image: $e");
    }
  }
}
