import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EditCoupon extends StatefulWidget {
  final String couponId;
  const EditCoupon({Key? key, required this.couponId}) : super(key: key);

  @override
  State<EditCoupon> createState() => _EditCouponState();
}

class _EditCouponState extends State<EditCoupon> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  // DateTime? _expiryDate;
  DateTime? _expiryDate = DateTime.now(); // Ngày mẫu
  List<String> selectedCategories = [];
  bool applyToAll = true;

  Stream<QuerySnapshot> categoriesStream =
      FirebaseFirestore.instance.collection('categories').snapshots();

  Future<void> fetchCouponDetails() async {
    final couponDoc = await FirebaseFirestore.instance
        .collection('coupons')
        .doc(widget.couponId)
        .get();

    if (couponDoc.exists) {
      final data = couponDoc.data()!;
      _nameController.text = data['name'] ?? '';
      _discountController.text = (data['discount'] ?? '').toString();
      _quantityController.text = (data['quantity'] ?? '').toString();
      _expiryDate = DateTime.tryParse(data['expiryDate'] ?? '');
      final categories = List<String>.from(data['categories'] ?? []);
      setState(() {
        if (categories.isEmpty) {
          applyToAll = true;
        } else {
          applyToAll = false;
          selectedCategories = categories;
        }
      });
    }
  }

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && pickedDate != _expiryDate) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  Future<void> updateCoupon() async {
    if (_nameController.text.isEmpty ||
        _discountController.text.isEmpty ||
        _quantityController.text.isEmpty ||
        _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          '👀 Vui lòng điền đầy đủ thông tin',
          style: AppWidget.semiBoldTextFieldStyle(),
        ),
      ));
      return;
    }

    final discount = int.tryParse(_discountController.text);
    final quantity = int.tryParse(_quantityController.text);

    if (discount == null ||
        quantity == null ||
        discount <= 0 ||
        quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          '📢 Phần trăm giảm giá và số lượng phải lớn hơn 0',
          style: AppWidget.semiBoldTextFieldStyle(),
        ),
      ));
      return;
    }

    final categoriesToApply = applyToAll ? [] : selectedCategories;

    await FirebaseFirestore.instance
        .collection('coupons')
        .doc(widget.couponId)
        .update({
      'name': _nameController.text,
      'discount': discount,
      'quantity': quantity,
      // 'expiryDate': _expiryDate!.toIso8601String(),
      'expiryDate': DateFormat('dd/MM/yyyy').format(_expiryDate!),
      'categories': categoriesToApply,
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Text(
        "🥰 Cập nhật mã giảm giá thành công",
        style: AppWidget.semiBoldTextFieldStyle(),
      ),
    ));

    Navigator.pop(context);
  }

  // Widget _buildCategorySelector() {
  //   return StreamBuilder<QuerySnapshot>(
  //     stream: categoriesStream,
  //     builder: (context, snapshot) {
  //       if (snapshot.connectionState == ConnectionState.waiting) {
  //         return const Center(child: CircularProgressIndicator());
  //       }
  //
  //       if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
  //         return Center(
  //           child: Text(
  //             'Không có danh mục nào!',
  //             style: AppWidget.semiBoldTextFieldStyle(),
  //           ),
  //         );
  //       }
  //
  //       final categories =
  //           snapshot.data!.docs.map((doc) => doc['name'].toString()).toList();
  //
  //       return Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           borderRadius: BorderRadius.circular(15),
  //           boxShadow: [
  //             BoxShadow(
  //               color: Colors.grey.withOpacity(0.1),
  //               spreadRadius: 2,
  //               blurRadius: 5,
  //               offset: const Offset(0, 3),
  //             ),
  //           ],
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             CheckboxListTile(
  //               title: Text(
  //                 'Áp dụng cho tất cả sản phẩm',
  //                 style: AppWidget.semiBoldTextFieldStyle(),
  //               ),
  //               value: applyToAll,
  //               onChanged: (value) {
  //                 setState(() {
  //                   applyToAll = value ?? false;
  //                   if (applyToAll) {
  //                     selectedCategories.clear();
  //                   }
  //                 });
  //               },
  //             ),
  //             if (!applyToAll)
  //               Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: categories.map((category) {
  //                   return CheckboxListTile(
  //                     title: Text(
  //                       category,
  //                       style: AppWidget.semiBoldTextFieldStyle(),
  //                     ),
  //                     value: selectedCategories.contains(category),
  //                     onChanged: (value) {
  //                       setState(() {
  //                         if (value == true) {
  //                           selectedCategories.add(category);
  //                         } else {
  //                           selectedCategories.remove(category);
  //                         }
  //                       });
  //                     },
  //                   );
  //                 }).toList(),
  //               ),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  Widget _buildCategorySelector() {
    final List<String> categories = [
      'Pizza',
      'Coke',
      'Burger',
      'Combo',
      'Chicken'
    ];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: Text(
              'Áp dụng cho tất cả sản phẩm',
              style: AppWidget.semiBoldTextFieldStyle(),
            ),
            value: applyToAll,
            onChanged: (value) {
              setState(() {
                applyToAll = value ?? false;
                if (applyToAll) selectedCategories.clear();
              });
            },
          ),
          if (!applyToAll)
            Padding(
              padding: const EdgeInsets.all(16),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Chọn danh mục',
                  labelStyle: AppWidget.semiBoldTextFieldStyle(),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                value: selectedCategories.isNotEmpty
                    ? selectedCategories.first
                    : null,
                items: categories.map((category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(
                      category,
                      style: AppWidget.semiBoldTextFieldStyle(),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategories = value != null ? [value] : [];
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchCouponDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'Chỉnh sửa mã giảm giá',
          style: AppWidget.semiBoldTextFieldStyle(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Thông tin mã giảm giá',
                      style: AppWidget.semiBoldTextFieldStyle(),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _nameController,
                      style: AppWidget.semiBoldTextFieldStyle(),
                      decoration: InputDecoration(
                        labelText: 'Tên mã giảm giá',
                        labelStyle: AppWidget.semiBoldTextFieldStyle(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _discountController,
                      style: AppWidget.semiBoldTextFieldStyle(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Phần trăm giảm giá (%)',
                        labelStyle: AppWidget.semiBoldTextFieldStyle(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _quantityController,
                      style: AppWidget.semiBoldTextFieldStyle(),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Số lượng',
                        labelStyle: AppWidget.semiBoldTextFieldStyle(),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _selectExpiryDate(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          _expiryDate == null
                              ? 'Chọn hạn sử dụng'
                              : 'Hạn sử dụng: ${_expiryDate!.toLocal()}'
                                  .split(' ')[0],
                          style: AppWidget.semiBoldTextFieldStyle(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Danh mục áp dụng',
                style: AppWidget.semiBoldTextFieldStyle(),
              ),
              const SizedBox(height: 10),
              _buildCategorySelector(),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: updateCoupon,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Cập nhật mã giảm giá',
                    style: AppWidget.semiBoldTextFieldStyle()
                        .copyWith(color: Colors.white),
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
