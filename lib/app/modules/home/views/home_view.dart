import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_editing/app/modules/home/views/selected_image_view.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My all edited images'),
        centerTitle: true,
      ),
      body: Obx(
        () => controller.loadedImages.isEmpty
            ? const Center(
                child: Text('No images saved'),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                physics: const ClampingScrollPhysics(),
                itemCount: controller.loadedImages.length,
                itemBuilder: (context, index) {
                  final file = File(controller.loadedImages[index].path);
                  return Image.file(
                    file,
                    fit: BoxFit.cover,
                  );
                },
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Get.to(() => const SelectedImageView(), transition: Transition.leftToRight);
          await controller.pickImages();
        },
        tooltip: 'Picked Images',
        child: const Icon(Icons.add),
      ),
    );
  }
}
