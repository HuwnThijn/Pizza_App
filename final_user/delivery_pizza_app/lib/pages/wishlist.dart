import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/pages/details.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';

class Wishlist extends StatefulWidget {
  const Wishlist({super.key});

  @override
  State<Wishlist> createState() => _WishlistState();
}

class _WishlistState extends State<Wishlist> {
  String? id;

  List<String> selectedItems = []; // Store selected product IDs

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    foodStream = await DatabaseMethods().getFoodWishList(id!);
    // Kiểm tra nếu widget vẫn còn hiển thị
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  Future<void> deleteSelectedItems() async {
    for (var itemId in selectedItems) {
      try {
        await DatabaseMethods().deleteFoodFromWishList(itemId, id!);
      } catch (e) {
        print("😥 Lỗi khi xóa mục $itemId: $e");
      }
    }

    selectedItems.clear(); // Xóa danh sách sau khi xóa xong
    setState(() {}); // Cập nhật giao diện
  }

  Future<void> deleteAllItems(String userId) async {
    // Lấy dữ liệu từ Firestore
    var foodStream = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("WishList")
        .get();

    // Kiểm tra nếu có dữ liệu
    if (foodStream.docs.isNotEmpty) {
      for (var doc in foodStream.docs) {
        await DatabaseMethods().deleteFoodFromWishList(doc.id, userId);
      }
      if (mounted) {
        // Kiểm tra nếu widget vẫn còn hiển thị
        setState(() {});
      }
    } else {
      print("📌 Không có mục nào trong danh sách để xóa!");
    }
  }

  Stream? foodStream;

  Widget foodWishList() {
    return StreamBuilder(
        stream: foodStream,
        builder: (context, AsyncSnapshot snapshot) {
          return snapshot.hasData
              ? ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: snapshot.data.docs.length,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return GestureDetector(
                      // margin: EdgeInsets.only(
                      //     left: 20.0, right: 20.0, bottom: 10.0),
                      onTap: () {
                        // Lấy dữ liệu từ DocumentSnapshot
                        Map<String, dynamic> data =
                            ds.data() as Map<String, dynamic>;

                        // Kiểm tra sự tồn tại của trường "Detail"
                        String detail = data.containsKey("Detail")
                            ? data["Detail"]
                            : "Không có mô tả";

                        // Kiểm tra sự tồn tại của trường "Price" và xử lý nếu nó null
                        String image = data["Image"] != null
                            ? data["Image"].toString()
                            : "Không có ảnh"; // Đảm bảo giá trị hợp lệ

                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => Details(
                        //       detail: detail,
                        //       name: ds["Name"],
                        //       price: ds["Price"],
                        //       // image: ds["Image"],
                        //       image: image,
                        //     ),
                        //   ),
                        // );
                      },
                      child: Material(
                        elevation: 5.0,
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10)),
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(
                                    ds["Image"],
                                    height: 90,
                                    width: 90,
                                    fit: BoxFit.cover,
                                  )),
                              SizedBox(
                                width: 20.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ds["Name"],
                                    style: AppWidget.semiBoldTextFieldStyle(),
                                  ),
                                  Text(
                                    ds["Price"] + " VNĐ",
                                    style: AppWidget.lightTextFieldStyle(),
                                  )
                                ],
                              ),
                              Spacer(),
                              GestureDetector(
                                onTap: () async {
                                  bool confirmDelete = await showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Text("Xác nhận"),
                                      content: Text(
                                          "Xóa sản phẩm này trong danh sách?"),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.of(context)
                                              .pop(false), // 'No' button
                                          child: Text("Không", style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.blueAccent),),
                                        ),
                                        TextButton(
                                          onPressed: () => Navigator.of(context)
                                              .pop(true), // 'Yes' button
                                          child: Text("Có", style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.red),),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirmDelete == true) {
                                    try {
                                      // Gọi hàm để thêm sản phẩm
                                      await DatabaseMethods()
                                          .deleteFoodFromWishList(ds.id, id!);

                                      // Hiển thị thông báo thành công
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          "✔ Xóa thành công",
                                          style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.white,),
                                        ),
                                      ));
                                    } catch (e) {
                                      // Nếu xảy ra lỗi (sản phẩm trùng lặp), hiển thị thông báo lỗi
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(SnackBar(
                                        backgroundColor: Colors.red,
                                        content: Text(
                                          "😥 Đã xảy ra lỗi khi xóa sản phẩm",
                                          // Lỗi được trả về từ phương thức `addFoodToWishList`
                                          style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.white,),
                                        ),
                                      ));
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 10),
                                  child: Icon(
                                    Icons.remove_circle,
                                    color: Colors.blueAccent,
                                    size: 40,
                                  ),
                                ),
                              ),

                            ],
                          ),
                        ),
                      ),
                    );
                  })
              : CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hàng chứa nút Back và logo
            Material(
              elevation: 2.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Nút Back
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Quay lại màn hình trước
                    },
                  ),
                  // Logo
                  Image.asset(
                    'images/logo5.png',
                    width: 70,
                    height: 70,
                  ),
                  //SizedBox(width: 48),
                  // Nút "Xóa tất cả"
                  // GestureDetector(
                  //   onTap: () async {
                  //     try {
                  //       await deleteAllItems(id!);
                  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  //         backgroundColor: Colors.green,
                  //         content: Text(
                  //           "✔ Xóa tất cả thành công!",
                  //           style: AppWidget.semiBoldTextFieldStyle(),
                  //         ),
                  //       ));
                  //     } catch (e) {
                  //       Text("😥 Gặp lỗi trong quá trình xóa!",
                  //           style: AppWidget.semiBoldTextFieldStyle(),);
                  //     }
                  //   },
                  //   child: Icon(
                  //     Icons.delete_forever,
                  //     color: Colors.red.shade400,
                  //     size: 40,
                  //   ),
                  // ), // Giữ chỗ cho cân đối

                  GestureDetector(
                    onTap: () async {
                      bool confirmDelete = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text("Xác nhận"),
                          content: Text(
                              "Xóa tất cả sản phẩm trong danh sách?"),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(false), // 'No' button
                              child: Text("Không", style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.blueAccent),),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(context)
                                  .pop(true), // 'Yes' button
                              child: Text("Có", style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.red),),
                            ),
                          ],
                        ),
                      );

                      if (confirmDelete == true) {
                        try {
                          await deleteAllItems(id!);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              "✔ Xóa tất cả thành công!",
                              style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.white),
                            ),
                          ));
                        } catch (e) {
                          Text("😥 Gặp lỗi trong quá trình xóa!",
                            style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.white));
                        }
                      }
                    },
                    child: Icon(
                      Icons.delete_forever,
                      color: Colors.red.shade400,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Danh sách yêu thích
            Container(
              height: MediaQuery.of(context).size.height / 1.21,
              child: foodWishList(),
            ),

            // Spacer(),
            //SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
