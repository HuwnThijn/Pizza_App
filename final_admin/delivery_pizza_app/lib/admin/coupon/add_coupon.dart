import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddCoupon extends StatefulWidget {
  const AddCoupon({Key? key}) : super(key: key);

  @override
  State<AddCoupon> createState() => _AddCouponState();
}

class _AddCouponState extends State<AddCoupon> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  // DateTime? _expiryDate;
  DateTime? _expiryDate = DateTime.now(); // Ngày mẫu
  List<String> selectedCategories = [];
  bool applyToAll = true;

  Future<void> _selectExpiryDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
              surface: Colors.white,
            ),
            dialogBackgroundColor: Colors.white,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null && pickedDate != _expiryDate) {
      setState(() {
        _expiryDate = pickedDate;
      });
    }
  }

  Future<void> addCoupon() async {
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

    await FirebaseFirestore.instance.collection('coupons').add({
      'name': _nameController.text,
      'discount': discount,
      'quantity': quantity,
      'expiryDate': _expiryDate!.toIso8601String(),
      //'expiryDate': DateFormat('dd/MM/yyyy').format(_expiryDate!),
      'categories': categoriesToApply,
    });

    await FirebaseFirestore.instance.collection('notifications').add({
      'name': _nameController.text,
      'discount': discount,
      'quantity': quantity,
      'expiryDate': _expiryDate!.toIso8601String(),
      //'expiryDate': DateFormat('dd/MM/yyyy').format(_expiryDate!),
      'createdAt': DateTime.now().toIso8601String(),
    });

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Text(
        "🥰 Thêm mã giảm giá thành công",
        style: AppWidget.semiBoldTextFieldStyle(),
      ),
    ));

    Navigator.pop(context);
  }

  Widget _buildInputField(
    TextEditingController controller,
    String label,
    TextInputType keyboardType,
  ) {
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
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: AppWidget.semiBoldTextFieldStyle(),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppWidget.semiBoldTextFieldStyle(),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true, // Đưa tiêu đề ra giữa
        title: Text(
          'Thêm mã giảm giá',
          style: AppWidget.semiBoldTextFieldStyle(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thông tin mã giảm giá',
              style: AppWidget.semiBoldTextFieldStyle(),
            ),
            const SizedBox(height: 20),
            _buildInputField(
              _nameController,
              'Tên mã giảm giá',
              TextInputType.text,
            ),
            _buildInputField(
              _discountController,
              'Phần trăm giảm giá (%)',
              TextInputType.number,
            ),
            _buildInputField(
              _quantityController,
              'Số lượng',
              TextInputType.number,
            ),
            Container(
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
              child: ListTile(
                title: Text(
                  _expiryDate == null
                      ? 'Chọn hạn sử dụng'
                      : 'Hạn sử dụng: ${_expiryDate!.toLocal().toString().split(' ')[0]}',
                  style: AppWidget.semiBoldTextFieldStyle(),
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _selectExpiryDate(context),
              ),
            ),
            Text(
              'Danh mục áp dụng',
              style: AppWidget.semiBoldTextFieldStyle(),
            ),
            const SizedBox(height: 20),
            _buildCategorySelector(),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addCoupon,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Thêm mã giảm giá',
                  style: AppWidget.semiBoldTextFieldStyle()
                      .copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
