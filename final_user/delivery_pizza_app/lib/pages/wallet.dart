import 'dart:convert';

import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/app_constant.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> {
  String? wallet, id;
  final oCcy = NumberFormat("#,##0", "vi_VN");
  int? add;
  TextEditingController amountcontroller = new TextEditingController();

  getthesharedpref() async {
    wallet = await SharedPreferenceHelper().getUserWallet();
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  ontheload() async {
    await getthesharedpref();
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

  Map<String, dynamic>? paymentIntent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Ẩn nút Back
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          // title: Text(
          //   "Ví",
          //   style: AppWidget.headlineTextFieldStyle()
          //       .copyWith(color: Colors.black),
          // ),
          // Logo lớn hơn và cân đối
          title: Image.asset(
            'images/logo5.png',
            width: 70, // Tăng kích thước logo
            height: 70,
          ),
        ),
        body: wallet == null
            ? CircularProgressIndicator()
            : Container(
                //margin: EdgeInsets.only(top: 50),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Material(
                    //   color: Colors.yellow,
                    //   elevation: 2,
                    //   child: Container(
                    //     padding: EdgeInsets.only(bottom: 10),
                    //     child: Center(
                    //       child: Text(
                    //         "Ví",
                    //         style: AppWidget.headlineTextFieldStyle()
                    //             .copyWith(color: Colors.black),
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: 20,
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: Color.fromARGB(255, 242, 242, 242)),
                      child: Row(
                        children: [
                          Image.asset(
                            "images/wallet.png",
                            height: 60,
                            width: 60,
                            fit: BoxFit.cover,
                          ),
                          SizedBox(
                            width: 40,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Ví của bạn",
                                style: AppWidget.lightTextFieldStyle(),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              Text(
                                // "\$" + wallet!,
                                // wallet! + " " + "\VNĐ",
                                wallet! + " " + "₫",
                                style: AppWidget.boldTextFieldStyle(),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          // Padding(
                          //   padding: const EdgeInsets.only(left: 20),
                          //   child: Text(
                          //     "Nạp tiền",
                          //     style: AppWidget.semiBoldTextFieldStyle(),
                          //   ),
                          // ),
                          // SizedBox(
                          //   height: 10,
                          // ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            makePayment('100000');
                          },
                          child: Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: Colors.black),
                            //   borderRadius: BorderRadius.circular(5),
                            //   //color: Colors.black,
                            // ),
                            child: Text(
                              // "\$" + "100",
                              "${oCcy.format(100000)} ₫",
                              style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.black),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            makePayment('500000');
                          },
                          child: Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: Colors.black),
                            //   borderRadius: BorderRadius.circular(5),
                            //   //color: Colors.black,
                            // ),
                            child: Text(
                              "${oCcy.format(500000)} ₫",
                              style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.blueAccent),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            makePayment('1000000');
                          },
                          child: Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: Colors.black),
                            //   borderRadius: BorderRadius.circular(5),
                            //   //color: Colors.black,
                            // ),
                            child: Text(
                              "${oCcy.format(1000000)} ₫",
                              style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.red),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            makePayment('2000000');
                          },
                          child: Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: Colors.black),
                            //   borderRadius: BorderRadius.circular(5),
                            //   //color: Colors.black,
                            // ),
                            child: Text(
                              "${oCcy.format(2000000)} ₫",
                              style: AppWidget.semiBoldTextFieldStyle().copyWith(color: Colors.green),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    GestureDetector(
                      onTap: () {
                        openEdit();
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 150),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                            // color: Color(0xFF008080),
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            "Nạp tiền",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'BalooPaaji2'),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ));
  }

  Future<void> makePayment(String amount) async {
    // try {
    //   paymentIntent = await createPaymentIntent(amount, 'VND');
    //   await Stripe.instance
    //       .initPaymentSheet(
    //           paymentSheetParameters: SetupPaymentSheetParameters(
    //               paymentIntentClientSecret: paymentIntent!['client_secret'],
    //               style: ThemeMode.dark,
    //               merchantDisplayName: 'Hung_Thinh'))
    //       .then((value) {});
    //
    //   displayPaymentSheet(amount);
    // } catch (e, s) {
    //   print('exception: $e$s');
    // }
    try {
      paymentIntent = await createPaymentIntent(amount, 'VND');
      print('Payment Intent: $paymentIntent');

      if (paymentIntent == null) {
        throw Exception("Failed to create payment intent.");
      }

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          style: ThemeMode.dark,
          merchantDisplayName: 'Hung_Thinh',
        ),
      );
      displayPaymentSheet(amount);
    } catch (e, stackTrace) {
      print('Error during payment process: $e');
      // Hiển thị lỗi
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          content: Text('Lỗi trong quá trình thanh toán: $e'),
        ),
      );
    }

  }

  displayPaymentSheet(String amount) async {
    // try {
    //   await Stripe.instance.presentPaymentSheet().then((value) async {
    //     add = int.parse(wallet!) + int.parse(amount);
    //     await SharedPreferenceHelper().saveUserWallet(add.toString());
    //     await DatabaseMethods().UpdateUserWallet(id!, add.toString());
    //     showDialog(
    //         context: context,
    //         builder: (_) => AlertDialog(
    //               content: Column(
    //                 children: [
    //                   Icon(
    //                     Icons.check_circle,
    //                     color: Colors.green,
    //                   ),
    //                   Text("Thanh toán thành công!")
    //                 ],
    //               ),
    //             ));
    //     await getthesharedpref();
    //     paymentIntent = null;
    //   }).onError((error, stackTrace) {
    //     print('Lỗi: ---> $error $stackTrace');
    //   });
    // } on StripeException catch (e) {
    //   print('Lỗi: ---> $e');
    //   showDialog(
    //       context: context,
    //       builder: (_) => const AlertDialog(
    //             content: Text('Giao dịch bị hủy'),
    //           ));
    // } catch (e) {
    //   print('$e');
    // }
    try {
      await Stripe.instance.presentPaymentSheet();
      add = int.parse(wallet!) + int.parse(amount);
      await SharedPreferenceHelper().saveUserWallet(add.toString());
      await DatabaseMethods().UpdateUserWallet(id!, add.toString());
      showDialog(
        context: context,
        // builder: (_) => AlertDialog(
        //   content: Row(
        //     mainAxisSize: MainAxisSize.min,
        //     children: [
        //       Icon(Icons.check_circle, color: Colors.green, size: 40),
        //       Text("Thanh toán thành công!", textAlign: TextAlign.center),
        //     ],
        //   ),
        // ),
        builder: (_) => AlertDialog(
          backgroundColor: Colors.transparent, // Loại bỏ nền trắng mặc định
          contentPadding: EdgeInsets.zero, // Loại bỏ padding mặc định
          content: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10), // Khoảng cách bên trong
              decoration: BoxDecoration(
                color: Colors.green, // Màu nền xanh
                borderRadius: BorderRadius.circular(8), // Bo góc
              ),
              child: Text(
                'Nạp tiền thành công 🥰',
                style: TextStyle(
                  color: Colors.white, // Màu chữ trắng
                  fontSize: 16, // Kích thước chữ
                  fontWeight: FontWeight.bold, // In đậm
                ),
                textAlign: TextAlign.center, // Canh giữa
              ),
            ),
          ),
        ),
      );
      //print("Thanh toán thành công!");
      await getthesharedpref();
      paymentIntent = null;
      //return add;
    } on StripeException catch (e) {
      print('Lỗi: ---> $e');
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: Colors.transparent, // Loại bỏ nền trắng mặc định
          contentPadding: EdgeInsets.zero, // Loại bỏ padding mặc định
          content: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10), // Khoảng cách bên trong
              decoration: BoxDecoration(
                color: Colors.red, // Màu nền đỏ
                borderRadius: BorderRadius.circular(8), // Bo góc
              ),
              child: Text(
                'Giao dịch đã bị hủy 😥',
                style: TextStyle(
                  color: Colors.white, // Màu chữ trắng
                  fontSize: 16, // Kích thước chữ
                  fontWeight: FontWeight.bold, // In đậm
                ),
                textAlign: TextAlign.center, // Canh giữa
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      print('Lỗi không xác định: $e');
    }
  }

  createPaymentIntent(String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded'
        },
        body: body,
      );
      print('Payment intent body: ---> ${response.body.toString()}');
      return jsonDecode(response.body);
    } catch (err) {
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    final calculatedAmount = (int.parse(amount));

    return calculatedAmount.toString();
  }

  Future openEdit() => showDialog(
      context: context,
      builder: (context) => AlertDialog(
            content: SingleChildScrollView(
              child: Container(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Icon(Icons.cancel),
                        ),
                        SizedBox(
                          width: 60,
                        ),
                        Center(
                          child: Text(
                            "Nạp tiền",
                            style: TextStyle(
                                color: Color(0xFF008080),
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Text("Số tiền: "),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.black38,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: TextField(
                        controller: amountcontroller,
                        decoration: InputDecoration(
                            border: InputBorder.none, hintText: 'Nhập số tiền'),
                        autofillHints: null, // Tắt Autofill
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          makePayment(amountcontroller.text);
                        },
                        child: Container(
                          width: 100,
                          padding: EdgeInsets.all(5),
                          decoration: BoxDecoration(
                              color: Color(0xFF008080),
                              borderRadius: BorderRadius.circular(10)),
                          child: Center(
                            child: Text(
                              "Nạp tiền",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          ));
}
