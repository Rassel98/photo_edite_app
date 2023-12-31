import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_editing/app/modules/home/controllers/home_controller.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageEditScreen extends StatelessWidget {
  final File imageFile;
  final String name;
  final HomeController controller;
  final int indx;

  const ImageEditScreen({super.key, required this.imageFile,required this.name,required this.controller,required this.indx});


  @override
  Widget build(BuildContext context) {
    controller.editedImages = [imageFile];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit your Image'),
        centerTitle: true,
        leading: IconButton(onPressed: ()=>Get.back(), icon: const Icon(Icons.arrow_back_ios_new)),
        actions: [
          IconButton(
            icon:  const Icon(Icons.crop),
            onPressed: ()async=>controller.cropImage(name,indx),
          ),
        ],
      ),
      body: PhotoViewGallery.builder(
        itemCount: controller.editedImages.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: FileImage(controller.editedImages[index]),
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
         controller.currentIndex(index);
        },
      ),
    );
  }
}
