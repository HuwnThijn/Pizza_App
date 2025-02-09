import 'package:flutter/foundation.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';

class UpdateProduct extends StatefulWidget {
  final String productId;
  final String selectedCategory;

  const UpdateProduct({
    Key? key,
    required this.productId,
    required this.selectedCategory,
  }) : super(key: key);

  @override
  State<UpdateProduct> createState() => _UpdateProductState();
}

class _UpdateProductState extends State<UpdateProduct> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  Uint8List? selectedImageBytes;
  String? imageUrl;
  bool isLoading = false;

  Future<void> pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          selectedImageBytes = bytes;
        });
      }
    } catch (e) {
      showErrorMessage("Lỗi khi chọn ảnh: $e");
    }
  }

  void showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.green,
        content: Text(
          message,
          style: const TextStyle(fontSize: 16),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> updateProduct() async {
    if (nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        detailController.text.isEmpty) {
      showErrorMessage("📢 Vui lòng điền đầy đủ thông tin");
      return;
    }

    setState(() => isLoading = true);

    try {
      String finalImageUrl =
          imageUrl ?? ''; // Keep existing image URL by default

      // Upload new image if selected
      if (selectedImageBytes != null) {
        final Reference storageRef = FirebaseStorage.instance
            .ref()
            .child("foodImages")
            .child(
                "${widget.productId}_${DateTime.now().millisecondsSinceEpoch}");

        final UploadTask uploadTask = storageRef.putData(
          selectedImageBytes!,
          SettableMetadata(contentType: 'image/jpeg'),
        );

        final TaskSnapshot snapshot = await uploadTask;
        finalImageUrl = await snapshot.ref.getDownloadURL();
      }

      final Map<String, dynamic> foodData = {
        "Image": finalImageUrl,
        "Name": nameController.text.trim(),
        "Price": priceController.text.trim(),
        "Detail": detailController.text.trim(),
      };

      await DatabaseMethods()
          .updateFoodItem(widget.productId, foodData, widget.selectedCategory);

      showSuccessMessage("🥰 Cập nhật sản phẩm thành công");
      Navigator.pop(context);
    } catch (e) {
      showErrorMessage("😥 Đã xảy ra lỗi khi cập nhật: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> getProductData() async {
    setState(() => isLoading = true);
    try {
      final productData = await DatabaseMethods()
          .getProductById(widget.productId, widget.selectedCategory);

      setState(() {
        nameController.text = productData['Name'] ?? '';
        priceController.text = productData['Price'] ?? '';
        detailController.text = productData['Detail'] ?? '';
        imageUrl = productData['Image'];
      });
    } catch (e) {
      showErrorMessage("😥 Lỗi khi tải dữ liệu sản phẩm: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getProductData();
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    detailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back_ios_new_outlined,
            color: Color(0xFF373866),
          ),
        ),
        centerTitle: true,
        title: Text(
          "Cập nhật sản phẩm",
          style: AppWidget.headlineTextFieldStyle(),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        "Tải lên ảnh sản phẩm",
                        style: AppWidget.semiBoldTextFieldStyle(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: GestureDetector(
                        onTap: pickImage,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: selectedImageBytes != null
                                ? Image.memory(
                                    selectedImageBytes!,
                                    fit: BoxFit.cover,
                                  )
                                : imageUrl != null && imageUrl!.isNotEmpty
                                    ? Image.network(
                                        imageUrl!,
                                        fit: BoxFit.cover,
                                        loadingBuilder:
                                            (context, child, progress) {
                                          if (progress == null) return child;
                                          return const Center(
                                              child:
                                                  CircularProgressIndicator());
                                        },
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return const Icon(
                                            Icons.error_outline,
                                            size: 40,
                                            color: Colors.red,
                                          );
                                        },
                                      )
                                    : const Icon(
                                        Icons.add_photo_alternate_outlined,
                                        size: 40,
                                        color: Colors.grey,
                                      ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: "Tên sản phẩm",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: "Giá sản phẩm",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: detailController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: "Mô tả sản phẩm",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: updateProduct,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          backgroundColor: const Color(0xFF373866),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Cập nhật sản phẩm",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
