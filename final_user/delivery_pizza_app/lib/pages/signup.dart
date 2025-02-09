import 'package:delivery_pizza_app/pages/bottomnav.dart';
import 'package:delivery_pizza_app/pages/login.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';

class Signup extends StatefulWidget {
  const Signup({super.key});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  String email = "", password = "", confirmPassword = "", name = "", phone = "";
  bool isPasswordVisible = false;

  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController confirmPassController = TextEditingController();

  final _formkey = GlobalKey<FormState>();

  registration() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            '🥰 Đăng kí thành công',
            style: AppWidget.semiBoldTextFieldStyle(),
          ))));
      String Id = randomAlphaNumeric(10);
      Map<String, dynamic> addUserInfo = {
        "Name": nameController.text,
        "Email": emailController.text,
        "Phone": phoneController.text,
        "Wallet": "0",
        "Id": Id,
        "Address": ""
      };

      await DatabaseMethods().addUserDetail(addUserInfo, Id);
      await SharedPreferenceHelper().saveUserId(Id);
      await SharedPreferenceHelper().saveUserName(nameController.text);
      await SharedPreferenceHelper().saveUserEmail(emailController.text);
      await SharedPreferenceHelper().saveUserPhone(phoneController.text);
      await SharedPreferenceHelper().saveUserAddress("");
      await SharedPreferenceHelper().saveUserWallet('0');

      // Redirect to login page after successful registration
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => Login()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Mật khẩu yếu!",
            style: TextStyle(fontSize: 18),
          ),
        )));
      } else if (e.code == 'email-already-in-use') {
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "Email đã tồn tại!",
            style: TextStyle(fontSize: 18),
          ),
        )));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Logo and background
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue, Colors.blue],
                ),
              ),
              child: Center(
                child: Image.asset(
                  'images/logo4.png',
                  width: 70,
                  height: 70,
                ),
              ),
            ),
            // Signup Form
            Container(
              margin: EdgeInsets.only(top: 20, left: 20, right: 20),
              child: Material(
                elevation: 5,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: EdgeInsets.all(20),
                  child: Form(
                    key: _formkey,
                    child: Column(
                      children: [
                        Text(
                          "Đăng kí",
                          style: AppWidget.headlineTextFieldStyle()
                              .copyWith(color: Colors.blue),
                        ),
                        SizedBox(height: 20),
                        // Email field
                        TextFormField(
                            controller: emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập email!';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Email',
                              hintStyle: AppWidget.semiBoldTextFieldStyle(),
                              prefixIcon: Icon(Icons.email_outlined),
                            )),
                        SizedBox(height: 20),
                        // Name field
                        TextFormField(
                            controller: nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập tên!';
                              }
                              return null;
                            },
                            decoration: InputDecoration(
                              hintText: 'Họ tên',
                              hintStyle: AppWidget.semiBoldTextFieldStyle(),
                              prefixIcon: Icon(Icons.person_outlined),
                            )),
                        SizedBox(height: 20),
                        // Phone field with 10-digit validation
                        TextFormField(
                            controller: phoneController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng nhập số điện thoại!';
                              } else if (!RegExp(r'^[0-9]{10}$')
                                  .hasMatch(value)) {
                                return 'Số điện thoại phải có 10 chữ số!';
                              }
                              return null;
                            },
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              hintText: 'Số điện thoại',
                              hintStyle: AppWidget.semiBoldTextFieldStyle(),
                              prefixIcon: Icon(Icons.phone_outlined),
                            )),
                        SizedBox(height: 20),
                        // Password field
                        TextFormField(
                          controller: passController,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Vui lòng nhập mật khẩu!';
                            } else if (value.length < 6) {
                              return 'Mật khẩu yếu! (ít nhất 6 ký tự)';
                            } else if (!RegExp(
                                r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{6,}$')
                                .hasMatch(value)) {
                              return 'Mật khẩu phải có ít nhất 1 chữ hoa, chữ thường, số và ký tự đặc biệt!';
                            }
                            return null;
                          },
                          obscureText: !isPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Mật khẩu',
                            hintStyle: AppWidget.semiBoldTextFieldStyle(),
                            prefixIcon: Icon(Icons.password_outlined),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),

                        SizedBox(height: 20),
                        // Confirm Password field
                        TextFormField(
                            controller: confirmPassController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vui lòng xác nhận mật khẩu!';
                              }
                              if (value != passController.text) {
                                return 'Mật khẩu không khớp!';
                              }
                              return null;
                            },
                            obscureText: !isPasswordVisible,
                            decoration: InputDecoration(
                              hintText: 'Xác nhận mật khẩu',
                              hintStyle: AppWidget.semiBoldTextFieldStyle(),
                              prefixIcon: Icon(Icons.password_outlined),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                            )),
                        SizedBox(height: 20),

                        // Signup Button
                        GestureDetector(
                          onTap: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = emailController.text;
                                name = nameController.text;
                                phone = phoneController.text;
                                password = passController.text;
                                confirmPassword = confirmPassController.text;
                              });
                              registration();
                            }
                          },
                          child: Material(
                            elevation: 5,
                            borderRadius: BorderRadius.circular(15),
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 8),
                              width: 200,
                              decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: BorderRadius.circular(15)),
                              child: Center(
                                child: Text(
                                  "Đăng kí",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: "BalooPaaji2",
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Login
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Login()));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Đã có tài khoản? ",
                              style: AppWidget.semiBoldTextFieldStyle(),
                              children: [
                                TextSpan(
                                  text: "Đăng nhập ngay!",
                                  style: AppWidget.semiBoldTextFieldStyle()
                                      .copyWith(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
