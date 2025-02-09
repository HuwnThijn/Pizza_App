import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/pages/detail_pizza.dart';
import 'package:delivery_pizza_app/pages/details.dart';
import 'package:delivery_pizza_app/pages/search_page.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'dart:async'; // gói banner động

class Store extends StatefulWidget {
  const Store({super.key});

  @override
  State<Store> createState() => _StoreState();
}

class _StoreState extends State<Store> {
  bool pizza = false,
      coke = false,
      combo = false,
      burger = false,
      chicken = false;
  String? userName, id;
  Stream? foodItemStream;
  // Lấy dữ liệu từ SharedPreferences khi tải trang
  ontheload() async {
    foodItemStream = await DatabaseMethods().getFoodItem("Pizza");
    userName = await SharedPreferenceHelper().getUserName();
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // Danh sách yêu thích
  List<Map<String, dynamic>> wishlist = [];

  void toggleWishlist(Map<String, dynamic> product) {
    setState(() {
      if (wishlist.contains(product)) {
        wishlist.remove(product);
      } else {
        wishlist.add(product);
      }
    });
  }

  Widget allItems() {
    return StreamBuilder(
      stream: foodItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? GridView.builder(
                padding: EdgeInsets.all(8.0),
                shrinkWrap: true,
                physics: BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Số lượng sản phẩm trên mỗi hàng
                  crossAxisSpacing: 10.0, // Khoảng cách giữa các cột
                  mainAxisSpacing: 8.0, // Khoảng cách giữa các hàng
                  childAspectRatio:
                      0.590, // Tỉ lệ chiều rộng/chiều cao của từng item
                ),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return GestureDetector(
                    onTap: () {
                      String currentCollection = "Pizza";
                      if (pizza)
                        currentCollection = "Pizza";
                      else if (burger)
                        currentCollection = "Burger";
                      else if (coke)
                        currentCollection = "Coke";
                      else if (chicken)
                        currentCollection = "Chicken";
                      else if (combo) currentCollection = "Combo";

                      // Navigate based on collection type
                      if (currentCollection == "Pizza") {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DetailPizza(
                              detail: ds["Detail"],
                              name: ds["Name"],
                              price: ds["Price"],
                              image: ds["Image"],
                            ),
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Details(
                              detail: ds["Detail"],
                              name: ds["Name"],
                              price: ds["Price"],
                              image: ds["Image"],
                            ),
                          ),
                        );
                      }
                    },
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(20),
                      clipBehavior: Clip.hardEdge,
                      child: Container(
                        padding: EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Image.network(
                                ds["Image"],
                                height: 150.0,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 8.0), // Khoảng cách giữa các phần
                            Row(
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.local_fire_department,
                                          color: Colors.red,
                                          size: 16), // Icon mới
                                      SizedBox(width: 0.1),
                                      Text(
                                        'NON-VEG',
                                        style: TextStyle(
                                            fontSize: 8,
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 2.0),
                                Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green[50],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.eco,
                                          color: Colors.green,
                                          size: 16), // Icon mới
                                      SizedBox(width: 4),
                                      Text(
                                        'BALANCE',
                                        style: TextStyle(
                                            fontSize: 10,
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 10.0), // Khoảng cách giữa các phần
                            Text(
                              ds["Name"],
                              style: AppWidget.semiBoldTextFieldStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 6.0),
                            Text(
                              ds["Detail"],
                              style: AppWidget.lightTextFieldStyle(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10.0),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      // "\$${ds["Price"]}",
                                      "${ds["Price"]} VNĐ",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue),
                                    ),
                                  ],
                                ),
                                Spacer(),
                                //         Icons.add_circle,
                                //         color: Colors.black,
                                Row(
                                  children: [
                                    SizedBox(width: 29), // Khoảng cách bên trái
                                    GestureDetector(
                                      onTap: () async {
                                        Map<String, dynamic> addFoodToCart = {
                                          "Name": ds["Name"],
                                          "Price": ds["Price"],
                                          "Image": ds["Image"],
                                        };

                                        try {
                                          // Gọi hàm để thêm sản phẩm
                                          await DatabaseMethods()
                                              .addFoodToWishList(
                                                  addFoodToCart, id!);

                                          // Hiển thị thông báo thành công
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            backgroundColor: Colors.green,
                                            content: Text(
                                              "✔ Đã thêm vào danh mục yêu thích!",
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ));
                                        } catch (e) {
                                          // Nếu xảy ra lỗi (sản phẩm trùng lặp), hiển thị thông báo lỗi
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(SnackBar(
                                            backgroundColor: Colors.red,
                                            content: Text(
                                              "😥 Bạn đã yêu thích món này rồi !", // Lỗi được trả về từ phương thức `addFoodToWishList`
                                              style: TextStyle(fontSize: 18),
                                            ),
                                          ));
                                        }
                                      },
                                      child: Container(
                                        // padding: EdgeInsets.all(3),
                                        // decoration: BoxDecoration(
                                        //   color: Colors.grey,
                                        //   borderRadius:
                                        //   BorderRadius.circular(8),
                                        // ),
                                        child: Icon(Icons.favorite,
                                            color: Colors.red),
                                      ),
                                    ),
                                    //SizedBox(width: 0), // Khoảng cách bên phải
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              )
            //     : Center(
            //   child: CircularProgressIndicator(),
            // );
            : CircularProgressIndicator();
      },
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            pizza = true;
            coke = false;
            burger = false;
            chicken = false;
            combo = false;
            foodItemStream = await DatabaseMethods().getFoodItem("Pizza");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: pizza ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_pizza.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            pizza = false;
            burger = true;
            coke = false;
            chicken = false;
            combo = false;
            foodItemStream = await DatabaseMethods().getFoodItem("Burger");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: burger ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_burger.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
                //color: burger ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            pizza = false;
            burger = false;
            coke = true;
            chicken = false;
            combo = false;
            foodItemStream = await DatabaseMethods().getFoodItem("Coke");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: coke ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_coke.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            pizza = false;
            coke = false;
            burger = false;
            chicken = true;
            combo = false;
            foodItemStream = await DatabaseMethods().getFoodItem("Chicken");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: chicken ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_chicken.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            pizza = false;
            coke = false;
            burger = false;
            chicken = false;
            combo = true;
            foodItemStream = await DatabaseMethods().getFoodItem("Combo");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: combo ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_combo.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // _buildBanner1(), // Đặt banner ở trên _buildBody
          Expanded(
              child: _buildBody()), // Đảm bảo _buildBody chiếm hết phần còn lại
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60), // Tăng chiều cao AppBar
      child: AppBar(
        backgroundColor: Colors.white,
        //centerTitle: true, // Đảm bảo nội dung nằm giữa
        elevation: 1.0,
        automaticallyImplyLeading: false, // Ẩn nút back
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo lớn hơn và cân đối
            Image.asset(
              'images/logo5.png',
              width: 70, // Tăng kích thước logo
              height: 70,
            ),
            Spacer(),
            // Các nút bên phải trên thanh app bar
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.search),
                  color: Colors.black,
                  onPressed: () async {
                    // Điều hướng đến trang tìm kiếm và nhận kết quả
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SearchPage()),
                    );

                    if (result != null && result.isNotEmpty) {
                      // foodItemStream = await DatabaseMethods().searchFoodItem(result.toLowerCase());
                      // //setState(() {});
                    }
                  },
                  // onPressed: () async {
                  //   // Điều hướng đến trang tìm kiếm và nhận kết quả
                  //   final List<QueryDocumentSnapshot>? result = await Navigator.push(
                  //     context,
                  //     MaterialPageRoute(builder: (context) => SearchPage()),
                  //   );
                  //
                  //   if (result != null && result.isNotEmpty) {
                  //     // Tạo danh sách từ khóa tìm kiếm
                  //     List<String> keywords = result.map((doc) => doc['searchKey'].toString()).toList();
                  //
                  //     // Tìm kiếm các sản phẩm liên quan trong Firestore
                  //     foodItemStream = FirebaseFirestore.instance
                  //         .collection('Products')
                  //         .where('searchKey', whereIn: keywords)
                  //         .snapshots();
                  //
                  //     setState(() {}); // Cập nhật giao diện
                  //   }
                  // },
                  iconSize: 30,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần còn lại của _buildBody
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 3.0, right: 3.0),
            // Gỡ margin cạnh banner
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.only(left: 8.0, right: 10.0),
                  child: showItem(),
                ),
                SizedBox(height: 20.0),
                Container(height: 600, child: allItems()),
                SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
