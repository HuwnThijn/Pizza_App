import 'package:delivery_pizza_app/pages/signup.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Forgotpassword extends StatefulWidget {
  const Forgotpassword({super.key});

  @override
  State<Forgotpassword> createState() => _ForgotpasswordState();
}

class _ForgotpasswordState extends State<Forgotpassword> {
  TextEditingController emailcontroller = new TextEditingController();

  String email = "";
  final _formkey = GlobalKey<FormState>();

  resetPassword() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(
        "Email đặt lại mật khẩu đã được gửi !",
        style: TextStyle(fontSize: 18).copyWith(color: Colors.green),
      )));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
          "Email không tồn tại !",
          style: TextStyle(fontSize: 18),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Column(
          children: [
            SizedBox(
              height: 70,
            ),
            Container(
              alignment: Alignment.topCenter,
              child: Text(
                "Khôi phục mật khẩu",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              "Nhập Email của bạn",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
                child: Form(
                    key: _formkey,
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: 20,
                        left: 20
                      ),
                      child: ListView(
                        children: [
                          Container(
                            padding: EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white70, width: 2),
                                borderRadius: BorderRadius.circular(30)),
                            child: TextFormField(
                              controller: emailcontroller,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập Email!';
                                }
                                return null;
                              },
                              style: TextStyle(
                                color: Colors.white,
                              ),
                              decoration: InputDecoration(
                                  hintText: "Email",
                                  hintStyle: TextStyle(
                                      color: Colors.white, fontSize: 18),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.white70,
                                    size: 30,
                                  ),
                                  border: InputBorder.none),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formkey.currentState!.validate()) {
                                setState(() {
                                  email = emailcontroller.text;
                                });
                                resetPassword();
                              }
                            },
                            child: Container(
                              width: 140,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Center(
                                child: Text(
                                  "Gửi Email",
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Chưa có tài khoản?",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Signup()));
                                },
                                child: Text(
                                  "Đăng ký ngay!",
                                  style: TextStyle(
                                      // color: Color.fromARGB(255, 184, 166, 6),
                                      color: Colors.yellow,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ))),
            SizedBox(
              height: 50,
            ),
          ],
        ),
      ),
    );
  }
}
