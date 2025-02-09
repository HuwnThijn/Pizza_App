import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:delivery_pizza_app/pages/details.dart';
import 'package:intl/intl.dart';

class Order extends StatefulWidget {
  const Order({super.key});

  @override
  State<Order> createState() => _OrderState();
}

class _OrderState extends State<Order> {
  String? id, wallet, name, email;
  int total = 0, amount2 = 0;
  DateTime now = DateTime.now();
  Stream? foodStream;
  List<String> selectedItems = []; // Store selected product IDs
  TextEditingController couponController = new TextEditingController();

  Timer? _timer;

  void startTimer() {
    Timer(Duration(seconds: 1), () {
      amount2 = total;
      setState(() {});
    });
  }

  StreamSubscription? _subscription;

  void listenToStream(Stream stream) {
    _subscription = stream.listen((data) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel(); // Hủy StreamSubscription
    _timer?.cancel();
    super.dispose();
  }

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    name = await SharedPreferenceHelper().getUserName();
    wallet = await SharedPreferenceHelper().getUserWallet();
    email = await SharedPreferenceHelper().getUserEmail();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
    foodStream = await DatabaseMethods().getFoodCart(id!);
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    startTimer();
    // listenToStream;
    super.initState();
  }

  void calculateTotal(QuerySnapshot snapshot) {
    total = snapshot.docs
        .fold<int>(0, (sum, doc) => sum + int.parse(doc["Total"] ?? "0"));
  }

  Future<String?> showConfirmAddressDialog() async {
    // Lấy thông tin địa chỉ hiện tại từ Firestore
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(id).get();

    // Kiểm tra xem địa chỉ có null không
    String? currentAddress = userDoc.get("Address") as String?;

    if (currentAddress == null || currentAddress.isEmpty) {
      // Nếu địa chỉ null, hiện thông báo
      return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            "Thông báo",
            style: TextStyle(
                fontFamily: "BalooPaaji2", fontSize: 18, color: Colors.black),
          ),
          content: Text(
            "Bạn chưa thêm địa chỉ. Vui lòng thêm địa chỉ để tiếp tục.",
            style: TextStyle(fontFamily: "BalooPaaji2", fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('cancel'),
              child: Text(
                "Hủy",
                style: AppWidget.semiBoldTextFieldStyle()
                    .copyWith(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('new_address'),
              child: Text(
                "Đồng ý",
                style: AppWidget.semiBoldTextFieldStyle()
                    .copyWith(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    } else {
      // Nếu có địa chỉ, hiện hộp thoại xác nhận bình thường
      return showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text(
            "Xác nhận địa chỉ",
            style: TextStyle(
                fontFamily: "BalooPaaji2", fontSize: 18, color: Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Bạn có muốn đặt hàng với địa chỉ mặc định không?",
                style: TextStyle(fontFamily: "BalooPaaji2", fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                "Địa chỉ hiện tại: $currentAddress",
                style: TextStyle(
                    fontFamily: "BalooPaaji2",
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600]),
              ),
            ],
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('cancel'),
                  child: Text(
                    "Hủy",
                    style: AppWidget.semiBoldTextFieldStyle()
                        .copyWith(color: Colors.red),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('new_address'),
                  child: Text(
                    "Địa chỉ khác",
                    style: AppWidget.semiBoldTextFieldStyle()
                        .copyWith(color: Colors.blue),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('confirm'),
                  child: Text(
                    "Đồng ý",
                    style: AppWidget.semiBoldTextFieldStyle()
                        .copyWith(color: Colors.green),
                  ),
                ),
              ],
            )
          ],
        ),
      );
    }
  }

  Future<String?> showAddressDialog() async {
    final addressController = TextEditingController();
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          "Nhập địa chỉ",
          style: TextStyle(
              fontFamily: "BalooPaaji2", fontSize: 18, color: Colors.black),
        ),
        content: TextField(
          controller: addressController,
          decoration: InputDecoration(
            hintText: "Địa chỉ của bạn",
            hintStyle: TextStyle(
                fontFamily: "BalooPaaji2", fontSize: 18, color: Colors.black),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // 'No' button
            child: Text(
              "Hủy",
              style: AppWidget.semiBoldTextFieldStyle()
                  .copyWith(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (addressController.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance
                    .collection("users")
                    .doc(id)
                    .update({"Address": addressController.text.trim()});
                await SharedPreferenceHelper()
                    .saveUserAddress(addressController.text.trim());
                Navigator.pop(context, addressController.text.trim());
              }
            },
            child: Text(
              "Xác nhận",
              style: TextStyle(
                  fontFamily: "BalooPaaji2",
                  fontSize: 18,
                  color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> checkAndUpdateAddress() async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection("users").doc(id).get();

    if (!userDoc.exists ||
        userDoc.get("Address") == null ||
        userDoc.get("Address").toString().isEmpty) {
      final address = await showAddressDialog();
      return true;
    }
    return true;
  }

  Future<void> createInvoice(String status) async {
    try {
      // if (!await checkAndUpdateAddress()) {
      //   throw "Vui lòng nhập địa chỉ!";
      // }

      if (total != 0) {
        // Lấy document user hiện tại
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection("users").doc(id).get();

        // Lấy danh sách tất cả invoices để tìm số thứ tự tiếp theo
        QuerySnapshot invoiceSnapshot = await FirebaseFirestore.instance
            .collection("invoices")
            .orderBy(FieldPath.documentId, descending: true)
            .limit(1)
            .get();

        // Tạo invoiceId mới
        String newInvoiceId;
        if (invoiceSnapshot.docs.isEmpty) {
          // Nếu chưa có hóa đơn nào
          newInvoiceId = "HD01";
        } else {
          // Lấy số từ invoiceId cuối cùng và tăng lên 1
          String lastInvoiceId = invoiceSnapshot.docs.first.id;
          int currentNumber =
              int.parse(lastInvoiceId.substring(2)); // Bỏ "HD" lấy số
          String nextNumber = (currentNumber + 1)
              .toString()
              .padLeft(2, '0'); // Format số với 2 chữ số
          newInvoiceId = "HD$nextNumber";
        }

        String timestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        // Lấy items từ giỏ hàng
        QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(id)
            .collection("Cart")
            .get();

        List<Map<String, dynamic>> items = cartSnapshot.docs.map((doc) {
          return {
            "name": doc["Name"],
            "quantity": doc["Quantity"],
            "price": doc["Total"],
            "image": doc["Image"],
          };
        }).toList();

        // Tạo document với custom ID
        await FirebaseFirestore.instance
            .collection("invoices")
            .doc(newInvoiceId)
            .set({
          "customerId": "$id",
          "customerName": "$name",
          "email": "$email",
          "address": userDoc.get("Address"),
          "items": items,
          "timestamp": timestamp,
          "totalPrice": amount2.toString(),
          "status": status,
        });

        await deleteAllItems(id!);
        int amount = int.parse(wallet!) - amount2;
        await DatabaseMethods().UpdateUserWallet(id!, amount.toString());
        await SharedPreferenceHelper().saveUserWallet(amount.toString());
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "♥ Thanh toán online thành công",
            style: TextStyle(fontSize: 18),
          ),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("Giỏ hàng trống 👀", style: TextStyle(fontSize: 18)),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content:
            Text("Gặp lỗi khi thanh toán!", style: TextStyle(fontSize: 18)),
      ));
    }
  }

  Future<void> createInvoice2(String status) async {
    try {
      if (!await checkAndUpdateAddress()) {
        throw "Vui lòng nhập địa chỉ!";
      }

      if (total != 0) {
        // Lấy document user hiện tại
        DocumentSnapshot userDoc =
            await FirebaseFirestore.instance.collection("users").doc(id).get();

        // Lấy danh sách tất cả invoices để tìm số thứ tự tiếp theo
        QuerySnapshot invoiceSnapshot = await FirebaseFirestore.instance
            .collection("invoices")
            .orderBy(FieldPath.documentId, descending: true)
            .limit(1)
            .get();

        // Tạo invoiceId mới
        String newInvoiceId;
        if (invoiceSnapshot.docs.isEmpty) {
          // Nếu chưa có hóa đơn nào
          newInvoiceId = "HD01";
        } else {
          // Lấy số từ invoiceId cuối cùng và tăng lên 1
          String lastInvoiceId = invoiceSnapshot.docs.first.id;
          int currentNumber =
              int.parse(lastInvoiceId.substring(2)); // Bỏ "HD" lấy số
          String nextNumber = (currentNumber + 1)
              .toString()
              .padLeft(2, '0'); // Format số với 2 chữ số
          newInvoiceId = "HD$nextNumber";
        }

        String timestamp =
            DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

        // Lấy items từ giỏ hàng
        QuerySnapshot cartSnapshot = await FirebaseFirestore.instance
            .collection("users")
            .doc(id)
            .collection("Cart")
            .get();

        List<Map<String, dynamic>> items = cartSnapshot.docs.map((doc) {
          return {
            "name": doc["Name"],
            "quantity": doc["Quantity"],
            "price": doc["Total"],
            "image": doc["Image"],
          };
        }).toList();

        // Tạo document với custom ID
        await FirebaseFirestore.instance
            .collection("invoices")
            .doc(newInvoiceId)
            .set({
          "customerId": "$id",
          "customerName": "$name",
          "email": "$email",
          "address": userDoc.get("Address"),
          "items": items,
          "timestamp": timestamp,
          "totalPrice": amount2.toString(),
          "status": status,
        });

        await deleteAllItems(id!);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("Giỏ hàng trống 👀", style: TextStyle(fontSize: 18)),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content:
            Text("Gặp lỗi khi thanh toán!", style: TextStyle(fontSize: 18)),
      ));
    }
  }

  Future<void> deleteSelectedItems() async {
    for (var itemId in selectedItems) {
      try {
        await DatabaseMethods().deleteFoodFromCart(itemId, id!);
      } catch (e) {
        print("Lỗi khi xóa mục $itemId: $e");
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
        .collection("Cart")
        .get();

    if (foodStream.docs.isNotEmpty) {
      for (var doc in foodStream.docs) {
        await DatabaseMethods().deleteFoodFromCart(doc.id, userId);
      }
      if (mounted) {
        // Kiểm tra nếu widget vẫn còn hiển thị
        setState(() {});
      }
    } else {
      print("Không có mục nào trong giỏ hàng để xóa.");
    }
  }

  Future<void> applyCoupon() async {
    try {
      String couponCode = couponController.text.trim(); // Lấy mã từ TextField

      if (couponCode.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Vui lòng nhập mã giảm giá!",
            style: TextStyle(fontSize: 18),
          ),
        ));
        return;
      }

      // Truy vấn Firestore để tìm mã dựa trên trường 'name'
      QuerySnapshot couponQuery = await FirebaseFirestore.instance
          .collection('coupons')
          .where('name', isEqualTo: couponCode) // Tìm kiếm dựa trên tên mã
          .get();

      // Kiểm tra nếu có mã giảm giá tồn tại
      if (couponQuery.docs.isNotEmpty) {
        DocumentSnapshot couponDoc = couponQuery.docs.first;

        // Lấy thông tin mã giảm giá
        int discount = int.parse(couponDoc['discount']?.toString() ?? '0');
        int quantity = int.parse(couponDoc['quantity']?.toString() ?? '0');
        String expiryDate = couponDoc['expiryDate'] ?? '';
        DateTime expiryDateTime = DateTime.parse(expiryDate);

        // Kiểm tra ngày hết hạn
        if (expiryDateTime.isBefore(DateTime.now())) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Mã giảm giá đã hết hạn!",
              style: TextStyle(fontSize: 18),
            ),
          ));
          return;
        }

        // Kiểm tra số lượng mã
        if (quantity <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Mã giảm giá không còn khả dụng!",
              style: TextStyle(fontSize: 18),
            ),
          ));
          return;
        }

        // Áp dụng giảm giá và cập nhật tổng tiền
        setState(() {
          total = (total * (1 - discount / 100)).toInt();
          amount2 = total; // Tính tổng mới
        });

        // Trừ quantity đi 1 trên Firestore
        await couponDoc.reference.update({'quantity': quantity - 1});

        // Thông báo áp mã thành công
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            "🥰 Áp dụng mã thành công - Giảm $discount%",
            style: TextStyle(fontSize: 18),
          ),
        ));
      } else {
        // Nếu mã giảm giá không tồn tại
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Mã giảm giá không tồn tại!",
            style: TextStyle(fontSize: 18),
          ),
        ));
      }
    } catch (e) {
      // Thông báo lỗi trong quá trình xử lý
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Đã xảy ra lỗi khi áp dụng mã giảm giá!",
          style: TextStyle(fontSize: 18),
        ),
      ));
    }
  }

  Widget foodCart() {
    return StreamBuilder(
        stream: foodStream,
        builder: (context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            calculateTotal(snapshot.data);
            return ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: snapshot.data.docs.length,
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  DocumentSnapshot ds = snapshot.data.docs[index];
                  return Container(
                    margin: EdgeInsets.only(
                        top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                    child: Material(
                      elevation: 5.0,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10)),
                        padding: EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Container(
                              height: 90,
                              width: 40,
                              decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                  child: Text(ds["Quantity"].toString())),
                            ),
                            SizedBox(
                              width: 20.0,
                            ),
                            ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  ds["Image"],
                                  height: 90,
                                  width: 90,
                                  fit: BoxFit.cover,
                                )),
                            SizedBox(
                              width: 10.0,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ds["Name"],
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                  maxLines: 1, // Chỉ hiển thị tối đa 1 dòng
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  ds["Total"] + " VND",
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                )
                              ],
                            ),
                            Spacer(),
                            GestureDetector(
                              onTap: () async {
                                bool confirmXoa = await showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: Text("Xác nhận"),
                                    content:
                                        Text("Xóa sản phẩm này trong giỏ?"),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(false), // 'No' button
                                        child: Text(
                                          "Không",
                                          style:
                                              AppWidget.semiBoldTextFieldStyle()
                                                  .copyWith(
                                                      color: Colors.blueAccent),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(true), // 'Yes' button
                                        child: Text(
                                          "Có",
                                          style:
                                              AppWidget.semiBoldTextFieldStyle()
                                                  .copyWith(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                                if (confirmXoa == true) {
                                  try {
                                    // Gọi hàm để thêm sản phẩm
                                    await DatabaseMethods()
                                        .deleteFoodFromCart(ds.id, id!);

                                    // Hiển thị thông báo thành công
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      backgroundColor: Colors.green,
                                      content: Text(
                                        "✔ Xóa sản phẩm thành công",
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ));
                                    setState(() {});
                                  } catch (e) {
                                    // Nếu xảy ra lỗi (sản phẩm trùng lặp), hiển thị thông báo lỗi
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      backgroundColor: Colors.red,
                                      content: Text(
                                        "Đã xảy ra lỗi khi xóa sản phẩm!", // Lỗi được trả về từ phương thức `addFoodToWishList`
                                        style: TextStyle(fontSize: 18),
                                      ),
                                    ));
                                  }
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    right: 10, bottom: 10),
                                child: Icon(
                                  Icons.remove_circle,
                                  color: Colors.blueAccent,
                                  size: 40,
                                ),
                              ),
                            ),
                            // GestureDetector(
                            //   onTap: () async {
                            //     try {
                            //       // Gọi hàm để thêm sản phẩm
                            //       await DatabaseMethods()
                            //           .deleteFoodFromCart(ds.id, id!);
                            //
                            //       // Hiển thị thông báo thành công
                            //       ScaffoldMessenger.of(context)
                            //           .showSnackBar(SnackBar(
                            //         backgroundColor: Colors.green,
                            //         content: Text(
                            //           "✔ Xóa sản phẩm thành công",
                            //           style: TextStyle(fontSize: 18),
                            //         ),
                            //       ));
                            //       setState(() {});
                            //     } catch (e) {
                            //       // Nếu xảy ra lỗi (sản phẩm trùng lặp), hiển thị thông báo lỗi
                            //       ScaffoldMessenger.of(context)
                            //           .showSnackBar(SnackBar(
                            //         backgroundColor: Colors.red,
                            //         content: Text(
                            //           "Đã xảy ra lỗi khi xóa sản phẩm!", // Lỗi được trả về từ phương thức `addFoodToWishList`
                            //           style: TextStyle(fontSize: 18),
                            //         ),
                            //       ));
                            //     }
                            //   },
                            //   child: Padding(
                            //     padding: const EdgeInsets.only(
                            //         right: 10, bottom: 10),
                            //     child: Icon(
                            //       Icons.remove_circle,
                            //       color: Colors.blueAccent,
                            //       size: 40,
                            //     ),
                            //   ),
                            // )
                          ],
                        ),
                      ),
                    ),
                  );
                });
          }
          return CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: EdgeInsets.only(top: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Material(
                elevation: 2.0,
                child: Container(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Container(
                      margin: EdgeInsets.only(right: 20, left: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                'images/logo5.png',
                                width: 70, // Tăng kích thước logo
                                height: 70,
                              ),
                            ),
                          ),

                          GestureDetector(
                            onTap: () async {
                              bool confirmXoa = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text("Xác nhận"),
                                  content:
                                      Text("Xóa tất cả sản phẩm trong giỏ?"),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pop(false), // 'No' button
                                      child: Text(
                                        "Không",
                                        style:
                                            AppWidget.semiBoldTextFieldStyle()
                                                .copyWith(
                                                    color: Colors.blueAccent),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context)
                                          .pop(true), // 'Yes' button
                                      child: Text(
                                        "Có",
                                        style:
                                            AppWidget.semiBoldTextFieldStyle()
                                                .copyWith(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmXoa == true) {
                                try {
                                  // Gọi hàm để thêm sản phẩm
                                  await deleteAllItems(id!);

                                  // Hiển thị thông báo thành công
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Colors.green,
                                    content: Text(
                                      "Xóa tất cả sản phẩm thành công 🥰",
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ));
                                  setState(() {});
                                } catch (e) {
                                  // Nếu xảy ra lỗi (sản phẩm trùng lặp), hiển thị thông báo lỗi
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                    backgroundColor: Colors.red,
                                    content: Text(
                                      "Đã xảy ra lỗi khi xóa sản phẩm!", // Lỗi được trả về từ phương thức `addFoodToWishList`
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ));
                                }
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Icon(
                                Icons.delete_forever,
                                color: Colors.red.shade400,
                                size: 40,
                              ),
                            ),
                          ),

                          // GestureDetector(
                          //   onTap: () async {
                          //     try {
                          //       // Gọi hàm để thêm sản phẩm
                          //       await deleteAllItems(id!);
                          //
                          //       // Hiển thị thông báo thành công
                          //       ScaffoldMessenger.of(context)
                          //           .showSnackBar(SnackBar(
                          //         backgroundColor: Colors.green,
                          //         content: Text(
                          //           "Xóa tất cả sản phẩm thành công 🥰",
                          //           style: TextStyle(fontSize: 18),
                          //         ),
                          //       ));
                          //       setState(() {});
                          //     } catch (e) {
                          //       // Nếu xảy ra lỗi (sản phẩm trùng lặp), hiển thị thông báo lỗi
                          //       ScaffoldMessenger.of(context)
                          //           .showSnackBar(SnackBar(
                          //         backgroundColor: Colors.red,
                          //         content: Text(
                          //           "Đã xảy ra lỗi khi xóa sản phẩm!", // Lỗi được trả về từ phương thức `addFoodToWishList`
                          //           style: TextStyle(fontSize: 18),
                          //         ),
                          //       ));
                          //     }
                          //   },
                          //   child: Padding(
                          //     padding: const EdgeInsets.only(right: 10),
                          //     child: Icon(
                          //       Icons.delete_forever,
                          //       color: Colors.red.shade400,
                          //       size: 40,
                          //     ),
                          //   ),
                          // )
                        ],
                      ),
                    ))),
            SizedBox(
              height: 0.5,
            ),
            Container(
                height: MediaQuery.of(context).size.height / 2,
                child: foodCart()),
            Spacer(),
            //Divider(),
            Padding(
                padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 10.0, right: 10.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      controller: couponController,
                                      decoration: InputDecoration(
                                        hintText: "Mã giảm giá",
                                        hintStyle:
                                            AppWidget.boldTextFieldStyle(),
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (total != 0) {
                                        applyCoupon();
                                      } // Gọi hàm áp dụng mã giảm giá
                                      else {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                          backgroundColor: Colors.red,
                                          content: Text(
                                              "Không thể áp mã do giỏ hàng đang trống!",
                                              style: TextStyle(fontSize: 18)),
                                        ));
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                    ),
                                    child: Text(
                                      "Áp dụng",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Tổng:",
                                    style: AppWidget.boldTextFieldStyle(),
                                  ),
                                  Text(
                                    total.toString() + " VND",
                                    style: AppWidget.semiBoldTextFieldStyle(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            SizedBox(
              height: 1.0,
            ),
            Row(
              children: [
                GestureDetector(
                  onTap: () async {
                    String? result = await showConfirmAddressDialog();

                    if (result == 'confirm') {
                      // Người dùng chọn đồng ý với địa chỉ mặc định
                      if (total != 0) {
                        await createInvoice2("Chưa thanh toán");
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.green,
                          content: Text(
                            "Đặt hàng thành công 🥰",
                            style: TextStyle(fontSize: 18),
                          ),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "Giỏ hàng trống 👀",
                            style: TextStyle(fontSize: 18),
                          ),
                        ));
                      }
                    } else if (result == 'new_address') {
                      // Người dùng muốn nhập địa chỉ mới
                      String? newAddress = await showAddressDialog();
                      if (newAddress != null && newAddress.isNotEmpty) {
                        // Tiếp tục với địa chỉ mới
                        if (total != 0) {
                          await createInvoice2("Chưa thanh toán");
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.green,
                            content: Text(
                              "Đặt hàng thành công 🥰",
                              style: TextStyle(fontSize: 18),
                            ),
                          ));
                        }
                      }
                    }
                    // Nếu result == 'cancel' hoặc null, không làm gì cả
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    width: MediaQuery.of(context).size.width / 2.3,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    margin:
                        EdgeInsets.only(left: 15.0, right: 5.0, bottom: 20.0),
                    child: Center(
                        child: Text(
                      "Đặt hàng",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    String? result = await showConfirmAddressDialog();

                    if (result == 'confirm') {
                      // Người dùng chọn đồng ý với địa chỉ mặc định
                      if (total != 0 && amount2 <= int.parse(wallet!)) {
                        await createInvoice("Đã thanh toán");
                      } else if (amount2 > int.parse(wallet!)) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "Số dư không đủ 👀",
                            style: TextStyle(fontSize: 18),
                          ),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          backgroundColor: Colors.red,
                          content: Text(
                            "Giỏ hàng trống 👀",
                            style: TextStyle(fontSize: 18),
                          ),
                        ));
                      }
                    } else if (result == 'new_address') {
                      // Người dùng muốn nhập địa chỉ mới
                      String? newAddress = await showAddressDialog();
                      if (newAddress != null && newAddress.isNotEmpty) {
                        // Tiếp tục với địa chỉ mới
                        if (total != 0 && amount2 <= int.parse(wallet!)) {
                          await createInvoice("Đã thanh toán");
                        } else if (amount2 > int.parse(wallet!)) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Số dư không đủ 👀",
                              style: TextStyle(fontSize: 18),
                            ),
                          ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: Colors.red,
                            content: Text(
                              "Giỏ hàng trống 👀",
                              style: TextStyle(fontSize: 18),
                            ),
                          ));
                        }
                      }
                    }
                    // Nếu result == 'cancel' hoặc null, không làm gì cả
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    width: MediaQuery.of(context).size.width / 2.3,
                    decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(10)),
                    margin:
                        EdgeInsets.only(left: 5.0, right: 10.0, bottom: 20.0),
                    child: Center(
                        child: Text(
                      "Thanh toán",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold),
                    )),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
