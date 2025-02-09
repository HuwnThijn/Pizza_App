import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class UpdateComboPage extends StatefulWidget {
  final String comboId;

  const UpdateComboPage({Key? key, required this.comboId}) : super(key: key);

  @override
  _UpdateComboPageState createState() => _UpdateComboPageState();
}

class _UpdateComboPageState extends State<UpdateComboPage> {
  String? selectedPizza;
  String? selectedDrink;
  String? selectedBurger;
  String? selectedChicken;
  Uint8List? webImage;
  String? fileName;
  String? existingImageUrl;
  bool isLoading = false;

  TextEditingController comboNameController = TextEditingController();
  TextEditingController comboDetailController = TextEditingController();

  Future<void> loadComboData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final comboDoc = await FirebaseFirestore.instance
          .collection('Combo')
          .doc(widget.comboId)
          .get();

      if (comboDoc.exists) {
        final comboData = comboDoc.data()!;
        setState(() {
          comboNameController.text = comboData['Name'];
          comboDetailController.text = comboData['Detail'];
          existingImageUrl = comboData['Image'];
          selectedPizza = comboData['Pizza'];
          selectedDrink = comboData['Coke'];
          selectedBurger = comboData['Burger'];
          selectedChicken = comboData['Chicken'];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "❌ Lỗi khi tải dữ liệu: $e",
            style: TextStyle(fontSize: 18),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> pickWebImage() async {
    final html.FileUploadInputElement input = html.FileUploadInputElement()
      ..accept = 'image/*';
    input.click();

    await input.onChange.first;
    if (input.files?.isNotEmpty ?? false) {
      final file = input.files![0];
      fileName = file.name;
      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;
      setState(() {
        webImage = Uint8List.fromList(reader.result as List<int>);
      });
    }
  }

  Future<String> uploadWebImage() async {
    if (webImage == null) return existingImageUrl ?? "";

    try {
      final Reference storageRef =
          FirebaseStorage.instance.ref().child('comboImages/${widget.comboId}');

      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': fileName ?? 'combo_image'});

      final UploadTask uploadTask = storageRef.putData(webImage!, metadata);
      final TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error uploading image. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
      return existingImageUrl ?? "";
    }
  }

  Future<void> updateCombo() async {
    if (comboNameController.text.isEmpty ||
        comboDetailController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "📝 Vui lòng nhập tên và mô tả combo",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
      return;
    }

    if (selectedPizza == null &&
        selectedDrink == null &&
        selectedBurger == null &&
        selectedChicken == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "🍕 Vui lòng chọn ít nhất một sản phẩm cho combo",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      String imageUrl = await uploadWebImage();

      Map<String, dynamic> updatedComboData = {
        "Name": comboNameController.text,
        "Detail": comboDetailController.text,
        "Pizza": selectedPizza,
        "Coke": selectedDrink,
        "Burger": selectedBurger,
        "Chicken": selectedChicken,
        "UpdatedAt": FieldValue.serverTimestamp(),
      };

      if (imageUrl.isNotEmpty) {
        updatedComboData["Image"] = imageUrl;
      }

      await FirebaseFirestore.instance
          .collection('Combo')
          .doc(widget.comboId)
          .update(updatedComboData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "🎉 Cập nhật combo thành công!",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "❌ Lỗi khi cập nhật combo: $e",
            style: TextStyle(fontSize: 18),
          ),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget buildDropdown(String label, String collection, String? selectedItem,
      Function(String?) onChanged) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection(collection).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final items = snapshot.data!.docs;

        return Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedItem,
                  hint: Text("Chọn ${label.toLowerCase()}"),
                  isExpanded: true,
                  items: items.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return DropdownMenuItem<String>(
                      value: doc.id,
                      child: Text(
                        data['Name'],
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget buildFormField(
      String label, TextEditingController controller, bool isMultiline) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: isMultiline ? 6 : 1,
          decoration: InputDecoration(
            hintText: "Nhập ${label.toLowerCase()}",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.blue),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    loadComboData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cập Nhật Combo"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              constraints: BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Ảnh Combo",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        Center(
                          child: GestureDetector(
                            onTap: pickWebImage,
                            child: Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: webImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.memory(
                                        webImage!,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : existingImageUrl != null
                                      ? ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                          child: Image.network(
                                            existingImageUrl!,
                                            fit: BoxFit.cover,
                                          ),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.cloud_upload_outlined,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              "Click để tải ảnh lên",
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                            ),
                          ),
                        ),
                        SizedBox(height: 24),
                        buildFormField("Tên Combo", comboNameController, false),
                        SizedBox(height: 24),
                        buildFormField("Mô tả", comboDetailController, true),
                        SizedBox(height: 24),
                        GridView.count(
                          shrinkWrap: true,
                          crossAxisCount: 2,
                          childAspectRatio: 3,
                          crossAxisSpacing: 20,
                          mainAxisSpacing: 20,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            buildDropdown("Pizza", "Pizza", selectedPizza,
                                (value) {
                              setState(() => selectedPizza = value);
                            }),
                            buildDropdown("Coke", "Coke", selectedDrink,
                                (value) {
                              setState(() => selectedDrink = value);
                            }),
                            buildDropdown("Burger", "Burger", selectedBurger,
                                (value) {
                              setState(() => selectedBurger = value);
                            }),
                            buildDropdown("Chicken", "Chicken", selectedChicken,
                                (value) {
                              setState(() => selectedChicken = value);
                            }),
                          ],
                        ),
                        SizedBox(height: 32),
                        Center(
                          child: ElevatedButton(
                            onPressed: isLoading ? null : updateCombo,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 16),
                              minimumSize: Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              isLoading ? "Đang xử lý..." : "Cập nhật Combo",
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
