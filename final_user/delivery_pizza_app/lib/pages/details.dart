import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class Details extends StatefulWidget {
  String image, name, detail, price;

  Details(
      {required this.detail,
      required this.image,
      required this.name,
      required this.price});

  @override
  State<Details> createState() => _DetailsState();
}

class _DetailsState extends State<Details> {
  int a = 1, total = 0;
  String? id;
  String? selectedSize = '';
  String? selectedDe = '';
  String? selectedVien = '';

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    ontheload();
    total = int.parse(widget.price);
  }

  // ms thêm
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: CustomAppBar(imageUrl: widget.image),
      appBar: CustomAppBar(
        imageUrl: widget.image,
        onFavoriteTap: () async {
          Map<String, dynamic> addFoodToCart = {
            "Name": widget.name,
            "Price": total.toString(),
            "Image": widget.image,
          };

          try {
            await DatabaseMethods().addFoodToWishList(addFoodToCart, id!);

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "✔ Đã thêm vào danh mục yêu thích!",
                style: TextStyle(fontSize: 18),
              ),
            ));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                e.toString(),
                style: TextStyle(fontSize: 18),
              ),
            ));
          }
        },
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(
                    widget.image,
                    width: MediaQuery.of(context).size.width / 1.3,
                    height: 300,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.name,
                        style: AppWidget.semiBoldTextFieldStyle(),
                      ),
                    ],
                  ),
                  Spacer(),
                  GestureDetector(
                    onTap: () {
                      if (a > 1) {
                        --a;
                        total = total - int.parse(widget.price);
                      }
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.remove,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(width: 20.0),
                  Text(
                    a.toString(),
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                  SizedBox(width: 20.0),
                  GestureDetector(
                    onTap: () {
                      ++a;
                      total = total + int.parse(widget.price);
                      setState(() {});
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(
                widget.detail,
                style: AppWidget.lightTextFieldStyle(),
                maxLines: 4,
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    "Thời gian tạo sản phẩm:",
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                  SizedBox(width: 25),
                  Icon(
                    Icons.alarm,
                    color: Colors.black54,
                  ),
                  SizedBox(width: 5),
                  Text(
                    "30 phút",
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0.1, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tổng tiền: ",
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                  Text(
                    // "\$" + total.toString(),
                    total.toString() + " VNĐ",
                    style: AppWidget.boldTextFieldStyle().copyWith(
                      color: Colors.red,
                    ), // Thêm màu xanh
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  Map<String, dynamic> addFoodToCart = {
                    "Name": widget.name,
                    "Quantity": a.toString(),
                    "Total": total.toString(),
                    "Image": widget.image,
                  };

                  await DatabaseMethods().addFoodToCart(addFoodToCart, id!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      "🥰 Đã thêm vào giỏ hàng!",
                      style: TextStyle(fontSize: 18),
                    ),
                  ));
                },
                child: Container(
                  width: MediaQuery.of(context).size.width / 2,
                  padding: EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "Thêm vào giỏ hàng",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'BalooPaaji2',
                        ),
                      ),
                      SizedBox(width: 10),
                      Container(
                        padding: EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.shopping_cart_outlined,
                          color: Colors.black,
                        ),
                      ),
                    ],
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

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String imageUrl;

  final VoidCallback onFavoriteTap; // Hàm xử lý khi nhấn vào nút yêu thích

  // CustomAppBar({required this.imageUrl});
  CustomAppBar({
    required this.imageUrl,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      // Set the AppBar background color to red
      elevation: 0,
      leading: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Icon(
          Icons.arrow_back_ios_new_outlined,
          color: Colors.black, // Set the back arrow icon color to white
        ),
      ),
      title: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          'images/logo5.png',
          width: 70, // Tăng kích thước logo
          height: 70,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: onFavoriteTap, // Gọi hàm xử lý khi nhấn vào nút yêu thích
          icon: Icon(
            Icons.favorite,
            color: Colors.red,
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.0);
}
