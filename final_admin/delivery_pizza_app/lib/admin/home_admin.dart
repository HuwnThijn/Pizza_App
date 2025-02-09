
import 'package:delivery_pizza_app/admin/admin_login.dart';
import 'package:delivery_pizza_app/admin/combo/combo_list_page.dart';
import 'package:delivery_pizza_app/admin/coupon/coupon_list.dart';
import 'package:delivery_pizza_app/admin/invoice/invoice_management.dart';
import 'package:delivery_pizza_app/admin/products_list.dart';
import 'package:delivery_pizza_app/admin/revenue_analytics.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  State<HomeAdmin> createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  // Logout dialog and action
  void _logout() async {
    bool confirmThoat = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Xác nhận"),
        content: Text("Bạn muốn đăng xuất tài khoản?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              "Không",
              style: AppWidget.semiBoldTextFieldStyle()
                  .copyWith(color: Colors.blueAccent),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              "Có",
              style: AppWidget.semiBoldTextFieldStyle()
                  .copyWith(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmThoat == true) {
      try {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminLogin()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.green,
            content: Text(
              "✔ Đăng xuất thành công",
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "😥 Đã xảy ra lỗi khi đăng xuất tài khoản",
              style: TextStyle(fontSize: 18),
            ),
          ),
        );
      }
    }
  }

  // AppBar Widget
  AppBar _buildAppBar() {
    return AppBar(
      toolbarHeight: 150, // Chiều cao của AppBar
      backgroundColor: Colors.white,
      //elevation: 9,
      centerTitle: true,
      title: Image.asset(
        'images/logo5.png',
        width: 150,
        height: 300,
      ),
      actions: [
        GestureDetector(
          onTap: _logout,
          child: Padding(
            padding: const EdgeInsets.only(right: 15),
            child: Icon(
              Icons.arrow_circle_right,
              color: Colors.blueAccent,
              size: 55,
            ),
          ),
        ),
      ],
    );
  }

  // Body Widget
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.only(top: 50, left: 200, right: 200),
      child: Column(
        children: [
          // Quản lý sản phẩm
          _buildAdminOption(
            "images/qlsp1.png",
            "Quản lý sản phẩm",
            ProductList(),
          ),
          SizedBox(height: 20),
          // Quản lý combo
          _buildAdminOption(
            "images/icon_combo.png",
            "Quản lý combo",
            ComboListPage(),
          ),
          SizedBox(height: 20),
          // Quản lý mã giảm giá
          _buildAdminOption(
            "images/magiamgia.png",
            "Quản lý mã giảm giá",
            CouponList(),
          ),
          SizedBox(height: 20),
          // Quản lý hóa đơn
          _buildAdminOption(
            "images/hoadon.png",
            "Quản lý hóa đơn",
            InvoiceManagement(),
          ),
          SizedBox(height: 20),
          // Quản lý doanh thu
          _buildAdminOption(
            "images/money.png",
            "Quản lý doanh thu",
            RevenueManagement(),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // Admin Option Widget (Reusable for all items)
  Widget _buildAdminOption(String imagePath, String title, Widget page) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      },
      child: Material(
        elevation: 10,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.orange.shade700,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center, // Căn giữa theo chiều ngang
            crossAxisAlignment: CrossAxisAlignment.center, // Căn giữa theo chiều dọc
            children: [
              Padding(
                padding: EdgeInsets.all(6),
                child: Image.asset(
                  imagePath,
                  height: 100,
                  width: 100,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }
}
