import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/admin/combo/add_combo.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'update_combo_page.dart';

class ComboListPage extends StatefulWidget {
  const ComboListPage({Key? key}) : super(key: key);

  @override
  _ComboListPageState createState() => _ComboListPageState();
}

class _ComboListPageState extends State<ComboListPage> {
  bool isLoading = false;

  Future<void> deleteCombo(String comboId) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Xác nhận xóa",
            style: AppWidget.boldTextFieldStyle(),
          ),
          content: Text(
            "Bạn có chắc chắn muốn xóa combo này không?",
            style: AppWidget.semiBoldTextFieldStyle(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(
                "Hủy",
                style: AppWidget.semiBoldTextFieldStyle()
                    .copyWith(color: Colors.grey[600]),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Xóa",
                style: AppWidget.semiBoldTextFieldStyle()
                    .copyWith(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );

    if (result == true) {
      setState(() => isLoading = true);
      try {
        await FirebaseFirestore.instance
            .collection('Combo')
            .doc(comboId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "✔ Xóa combo thành công",
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "❌ Lỗi khi xóa combo: $e",
              style: const TextStyle(fontSize: 16),
            ),
          ),
        );
      } finally {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "QUẢN LÝ COMBO",
          style: TextStyle(
            color: Colors.red,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'BalooPaaji2',
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                "Thêm Combo",
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF373866),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddCombo()),
                );
              },
            ),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('Combo').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final combos = snapshot.data!.docs;

                if (combos.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.category_outlined,
                            size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          "Chưa có combo nào được thêm",
                          style: AppWidget.semiBoldTextFieldStyle(),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final crossAxisCount = constraints.maxWidth > 1200
                          ? 4
                          : constraints.maxWidth > 800
                              ? 3
                              : constraints.maxWidth > 600
                                  ? 2
                                  : 1;

                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: combos.length,
                        itemBuilder: (context, index) {
                          final combo = combos[index];
                          final comboId = combo.id;
                          final comboData =
                              combo.data() as Map<String, dynamic>;
                          final comboName = comboData["Name"] ?? "Không tên";
                          final comboPrice = comboData["Price"] ?? "0";
                          final comboImage = comboData["Image"] ?? "";

                          return Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12),
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        CachedNetworkImage(
                                          imageUrl: comboImage,
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              const Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey[200],
                                            child: const Icon(
                                              Icons
                                                  .image_not_supported_outlined,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          right: 8,
                                          top: 8,
                                          child: Row(
                                            children: [
                                              MaterialButton(
                                                minWidth: 0,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: Colors.white,
                                                shape: const CircleBorder(),
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          UpdateComboPage(
                                                        comboId: comboId,
                                                      ),
                                                    ),
                                                  );
                                                },
                                                child: const Icon(
                                                  Icons.edit,
                                                  size: 40,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              MaterialButton(
                                                minWidth: 0,
                                                padding:
                                                    const EdgeInsets.all(8),
                                                color: Colors.white,
                                                shape: const CircleBorder(),
                                                onPressed: () =>
                                                    deleteCombo(comboId),
                                                child: const Icon(
                                                  Icons.delete,
                                                  size: 40,
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        comboName,
                                        style: AppWidget.boldTextFieldStyle()
                                            .copyWith(fontSize: 16),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${comboPrice}đ",
                                        style:
                                            AppWidget.semiBoldTextFieldStyle()
                                                .copyWith(
                                          color: Colors.red,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
