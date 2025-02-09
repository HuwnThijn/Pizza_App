import 'dart:typed_data';

import 'package:delivery_pizza_app/admin/products_list.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker_web/image_picker_web.dart';
import 'package:random_string/random_string.dart';

class AddFood extends StatefulWidget {
  const AddFood({Key? key}) : super(key: key);

  @override
  State<AddFood> createState() => _AddFoodState();
}

class _AddFoodState extends State<AddFood> {
  final List<String> items = ['Pizza', 'Coke', 'Burger', 'Chicken'];
  String? selectedCategory;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController detailController = TextEditingController();

  Uint8List? selectedImage;

  Future<void> getImage() async {
    final image = await ImagePickerWeb.getImageAsBytes();
    if (image != null) {
      setState(() {
        selectedImage = image;
      });
    }
  }

  Future<void> uploadItem() async {
    if (selectedImage == null ||
        nameController.text.isEmpty ||
        priceController.text.isEmpty ||
        detailController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "👀 Vui lòng điền đầy đủ thông tin",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
      return;
    }

    try {
      // Tạo ID ngẫu nhiên cho sản phẩm
      String generatedId = randomAlphaNumeric(10);

      // Upload hình ảnh lên Firebase Storage
      final Reference storageRef =
          FirebaseStorage.instance.ref().child("foodImages").child(generatedId);
      final UploadTask uploadTask = storageRef.putData(selectedImage!);
      final String imageUrl = await (await uploadTask).ref.getDownloadURL();

      // Tạo dữ liệu sản phẩm
      final Map<String, dynamic> foodData = {
        "Image": imageUrl,
        "Name": nameController.text,
        "Price": priceController.text,
        "Detail": detailController.text,
        if (selectedCategory == "Pizza") "PizzaId": generatedId,
        if (selectedCategory == "Coke") "CokeId": generatedId,
        if (selectedCategory == "Burger") "BurgerId": generatedId,
        if (selectedCategory == "Chicken") "ChickenId": generatedId,
      };

      // Lưu dữ liệu vào Firestore
      await DatabaseMethods().addFoodItem(foodData, selectedCategory!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "🥰 $selectedCategory đã được thêm thành công",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );

      // Điều hướng về danh sách sản phẩm
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "😥 Đã xảy ra lỗi: $e",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    }
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
          "Thêm sản phẩm",
          style: AppWidget.headlineTextFieldStyle(),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Tải lên ảnh sản phẩm",
                style: AppWidget.semiBoldTextFieldStyle(),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: getImage,
                child: Center(
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 150,
                      width: 150,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: selectedImage == null
                          ? const Icon(Icons.camera_alt_outlined,
                              color: Colors.black)
                          : Image.memory(
                              selectedImage!,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              _buildTextField(
                label: "Tên sản phẩm",
                controller: nameController,
                hintText: "Nhập tên sản phẩm",
              ),
              const SizedBox(height: 30),
              _buildTextField(
                label: "Giá sản phẩm",
                controller: priceController,
                hintText: "Nhập giá sản phẩm",
                inputType: TextInputType.number,
              ),
              const SizedBox(height: 30),
              _buildTextField(
                label: "Mô tả sản phẩm",
                controller: detailController,
                hintText: "Nhập mô tả sản phẩm",
                maxLines: 6,
              ),
              const SizedBox(height: 20),
              Text(
                "Loại sản phẩm",
                style: AppWidget.semiBoldTextFieldStyle(),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFececf8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    items: items.map((item) {
                      return DropdownMenuItem(
                        value: item,
                        child: Text(
                          item,
                          style: const TextStyle(
                              fontSize: 18, color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    dropdownColor: Colors.white,
                    hint: const Text("Chọn loại sản phẩm"),
                    iconSize: 36,
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: ElevatedButton(
                  onPressed: uploadItem,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    "Thêm",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType inputType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppWidget.semiBoldTextFieldStyle(),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: const Color(0xFFececf8),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: inputType,
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: hintText,
              hintStyle: AppWidget.lightTextFieldStyle(),
            ),
          ),
        ),
      ],
    );
  }
}
