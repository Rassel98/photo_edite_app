import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import 'edit_image_view.dart';

class SelectedImageView extends GetView {
  const SelectedImageView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Images'),
        leading: IconButton(onPressed: () => Get.back(), icon: const Icon(Icons.arrow_back_ios_new)),
      ),
      body: Obx(
        () => controller.selectedImages.isEmpty
            ? const Center(
                child: Text('No images selected'),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                ),
                itemCount: controller.selectedImages.length,
                itemBuilder: (context, index) {
                  final file = File(controller.selectedImages[index].path);
                  final imageName = controller.selectedImages[index].name;
                  return GestureDetector(
                    onTap: () => Get.to(
                        () => ImageEditScreen(
                              imageFile: file,
                              name: imageName,
                              controller: controller,
                              indx: index,
                            ),
                        transition: Transition.leftToRight),
                    child: Image.file(
                      file,
                      fit: BoxFit.cover,
                    ),
                  );
                },
              ),
      ),
      floatingActionButton: TextButton(
          onPressed: () {
            controller.saveImages();
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.pink,
          ),
          child: const Text("Save all edited image")),
    );
  }
}
