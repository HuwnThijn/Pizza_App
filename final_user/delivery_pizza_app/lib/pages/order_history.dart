import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';

class OrderHistory extends StatefulWidget {
  const OrderHistory({super.key});

  @override
  State<OrderHistory> createState() => _OrderHistoryState();
}

class _OrderHistoryState extends State<OrderHistory> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? _userId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      _userId = await SharedPreferenceHelper().getUserId();
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print("😥 Lỗi khởi tạo dữ liệu: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Stream<QuerySnapshot>? _getOrderStream() {
    if (_userId == null) return null;

    return _firestore
        .collection("invoices")
        .where("customerId", isEqualTo: _userId)
        .orderBy("timestamp", descending: true)
        .snapshots();
  }

  Future<void> _deleteOrder(String orderId) async {
    try {
      await _firestore.collection("invoices").doc(orderId).delete();
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Đơn hàng đã bị xóa")),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       "✔ Đơn hàng đã bị xóa!",
      //       style: AppWidget.semiBoldTextFieldStyle()
      //           .copyWith(color: Colors.white), // Đổi màu chữ thành xanh
      //     ),
      //     backgroundColor: Colors.green, // Màu nền có thể tùy chỉnh
      //   ),
      // );
    } catch (e) {
      print("😥 Lỗi khi xóa đơn hàng: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Không thể xóa đơn hàng")),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "😥 Không thể xóa đơn hàng!",
            style: TextStyle(color: Colors.white), // Đổi màu chữ thành xanh
          ),
          backgroundColor: Colors.red, // Màu nền có thể tùy chỉnh
        ),
      );
    }
  }

  Future<void> _deleteAllOrders() async {
    try {
      final querySnapshot = await _firestore
          .collection("invoices")
          .where("customerId", isEqualTo: _userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete(); // Xóa từng đơn hàng
      }

      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Đã xóa tất cả đơn hàng")),
      // );
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //     content: Text(
      //       "✔ Đã xóa tất cả đơn hàng",
      //       style: AppWidget.semiBoldTextFieldStyle()
      //           .copyWith(color: Colors.white), // Đổi màu chữ thành xanh
      //     ),
      //     backgroundColor: Colors.green, // Màu nền có thể tùy chỉnh
      //   ),
      // );
    } catch (e) {
      print("😥 Lỗi khi xóa tất cả đơn hàng: $e");
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text("Không thể xóa tất cả đơn hàng")),
      // );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "😥 Không thể xóa tất cả đơn hàng",
            style: AppWidget.semiBoldTextFieldStyle()
                .copyWith(color: Colors.white), // Đổi màu chữ thành xanh
          ),
          backgroundColor: Colors.red, // Màu nền có thể tùy chỉnh
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   elevation: 2,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () {
      //       Navigator.pop(context);
      //     },
      //   ),
      //   title: const Image(
      //     image: AssetImage("images/logo5.png"),
      //     height: 40,
      //   ),
      //   centerTitle: true,
      //   backgroundColor: Colors.white,
      // ),

      appBar: AppBar(
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Image(
          image: AssetImage("images/logo5.png"),
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            // icon: const Icon(Icons.delete_forever),
            icon: Icon(
              Icons.delete_forever,
              color: Colors.red, // Đổi màu nút thành đỏ
              size: 40, // Tăng kích thước của nút
            ),

            onPressed: () async {
              bool confirmDelete = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text("Xác nhận"),
                  content: Text("Xóa tất cả đơn hàng?"),
                  actions: [
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(false), // 'No' button
                      child: Text(
                        "Không",
                        style: AppWidget.semiBoldTextFieldStyle()
                            .copyWith(color: Colors.blueAccent),
                      ),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.of(context).pop(true), // 'Yes' button
                      child: Text(
                        "Có",
                        style: AppWidget.semiBoldTextFieldStyle()
                            .copyWith(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                try {
                  // Gọi hàm để xóa
                  await _deleteAllOrders();

                  // Hiển thị thông báo thành công
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      "✔ Xóa tất cả đơn hàng thành công",
                      style: AppWidget.semiBoldTextFieldStyle().copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ));
                } catch (e) {
                  // Nếu xảy ra lỗi (sản phẩm trùng lặp), hiển thị thông báo lỗi
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.red,
                    content: Text(
                      "😥 Đã xảy ra lỗi khi xóa tất cả đơn hàng",
                      // Lỗi được trả về từ phương thức `addFoodToWishList`
                      style: AppWidget.semiBoldTextFieldStyle().copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ));
                }
              }
            },
          ),
        ],
      ),

      body: Container(
        padding: const EdgeInsets.only(top: 60.0),
        child: Column(
          children: [
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_userId == null)
              const Expanded(
                child: Center(
                    child: Text('😥 Không tìm thấy thông tin người dùng')),
              )
            else
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _getOrderStream(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('😥 Đã xảy ra lỗi: ${snapshot.error}'),
                      );
                    }

                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text('📌 Chưa có đơn hàng nào',
                            style: AppWidget.semiBoldTextFieldStyle()
                                .copyWith(color: Colors.black)),
                      );
                    }

                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;

                        return Container(
                          margin: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ExpansionTile(
                            title: Row(
                              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Đơn hàng #${index + 1}",
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.clear,
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                  // onPressed: () async {
                                  //   // Xử lý hành động xóa ở đây
                                  //   await _deleteOrder(
                                  //       snapshot.data!.docs[index].id);
                                  // },
                                  onPressed: () async {
                                    bool confirmDelete = await showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Xác nhận"),
                                        content: Text(
                                            "Xóa đơn hàng này?"),
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
                                        // Gọi hàm để xóa
                                        await _deleteOrder(
                                            snapshot.data!.docs[index].id);

                                        // Hiển thị thông báo thành công
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: Colors.green,
                                          content: Text(
                                            "✔ Xóa đơn hàng thành công",
                                            style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.white,),
                                          ),
                                        ));
                                      } catch (e) {
                                        // Nếu xảy ra lỗi (sản phẩm trùng lặp), hiển thị thông báo lỗi
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                            "😥 Đã xảy ra lỗi khi xóa đơn hàng này",
                                            // Lỗi được trả về từ phương thức `addFoodToWishList`
                                            style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.white,),
                                          ),
                                        ));
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Ngày: ${data["timestamp"]}"),
                                Text("Địa chỉ: ${data["address"]}"),
                                Text("Tổng tiền: ${data["totalPrice"]} VND"),
                                Text("Trạng thái: ${data["status"]}"),
                              ],
                            ),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Các món:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    if (data["items"] != null)
                                      ...(data["items"] as List)
                                          .map((item) => ListTile(
                                                leading: Image.network(
                                                  item["image"] ?? '',
                                                  width: 50,
                                                  height: 50,
                                                  fit: BoxFit.cover,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return const Icon(
                                                        Icons.error);
                                                  },
                                                ),
                                                title: Text(item["name"] ?? ''),
                                                subtitle: Text(
                                                    "Số lượng: ${item["quantity"] ?? 0}"),
                                                trailing: Text(
                                                    "${item["price"] ?? 0} VND"),
                                              ))
                                          .toList(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );

                    // return ListView.builder(
                    //   itemCount: snapshot.data!.docs.length,
                    //   itemBuilder: (context, index) {
                    //     final data = snapshot.data!.docs[index].data()
                    //         as Map<String, dynamic>;
                    //
                    //     return Container(
                    //       margin: const EdgeInsets.all(10),
                    //       decoration: BoxDecoration(
                    //         border: Border.all(color: Colors.grey),
                    //         borderRadius: BorderRadius.circular(10),
                    //       ),
                    //       child: ExpansionTile(
                    //         title: Text(
                    //           "Đơn hàng #${index + 1}",
                    //           style:
                    //               const TextStyle(fontWeight: FontWeight.bold),
                    //         ),
                    //         subtitle: Column(
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text("Ngày: ${data["timestamp"]}"),
                    //             Text("Địa chỉ: ${data["address"]}"),
                    //             Text("Tổng tiền: ${data["totalPrice"]} VND"),
                    //             Text("Trạng thái: ${data["status"]}"),
                    //           ],
                    //         ),
                    //         children: [
                    //           Container(
                    //             padding: const EdgeInsets.all(10),
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: [
                    //                 const Text(
                    //                   "Các món:",
                    //                   style: TextStyle(
                    //                       fontWeight: FontWeight.bold),
                    //                 ),
                    //                 if (data["items"] != null)
                    //                   ...(data["items"] as List)
                    //                       .map((item) => ListTile(
                    //                             leading: Image.network(
                    //                               item["image"] ?? '',
                    //                               width: 50,
                    //                               height: 50,
                    //                               fit: BoxFit.cover,
                    //                               errorBuilder: (context, error,
                    //                                   stackTrace) {
                    //                                 return const Icon(
                    //                                     Icons.error);
                    //                               },
                    //                             ),
                    //                             title: Text(item["name"] ?? ''),
                    //                             subtitle: Text(
                    //                                 "Số lượng: ${item["quantity"] ?? 0}"),
                    //                             trailing: Text(
                    //                                 "${item["price"] ?? 0} VND"),
                    //                           ))
                    //                       .toList(),
                    //               ],
                    //             ),
                    //           )
                    //         ],
                    //       ),
                    //     );
                    //   },
                    // );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
