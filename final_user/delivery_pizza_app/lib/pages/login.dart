import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:delivery_pizza_app/pages/bottomnav.dart';
import 'package:delivery_pizza_app/pages/forgotpassword.dart';
import 'package:delivery_pizza_app/pages/signup.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String email = "", password = "";
  bool isPasswordVisible = false; // Trạng thái hiển thị mật khẩu
  bool isRememberMeChecked = false; // Trạng thái nhớ mật khẩu

  final _formkey = GlobalKey<FormState>();
  TextEditingController useremailcontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials(); // Tải thông tin đã lưu
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      email = prefs.getString('saved_email') ?? "";
      password = prefs.getString('saved_password') ?? "";
      isRememberMeChecked = prefs.getBool('remember_me') ?? false;

      // Nếu đã chọn nhớ mật khẩu, tự động điền thông tin
      if (isRememberMeChecked) {
        useremailcontroller.text = email;
        userpasswordcontroller.text = password;
      }
    });
  }

  Future<void> _saveCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isRememberMeChecked) {
      // Lưu email và mật khẩu nếu chọn "Nhớ mật khẩu"
      await prefs.setString('saved_email', email);
      await prefs.setString('saved_password', password);
      await prefs.setBool('remember_me', true);
    } else {
      // Xóa thông tin nếu bỏ chọn
      await prefs.remove('saved_email');
      await prefs.remove('saved_password');
      await prefs.setBool('remember_me', false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  userLogin() async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      // Lưu thông tin nếu đăng nhập thành công
      await _saveCredentials();

      Navigator.push(
          context, MaterialPageRoute(builder: (context) => BottomNav()));
      ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            '🥰 Đăng nhập thành công',
            style: AppWidget.semiBoldTextFieldStyle(),
          ))));
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = '😥 Không tìm thấy người dùng!';
      } else if (e.code == 'wrong-password') {
        errorMessage = '😥 Tên đăng nhập hoặc mật khẩu sai';
      } else {
        // errorMessage = 'Lỗi: ${e.message}';
        ScaffoldMessenger.of(context).showSnackBar((SnackBar(
          backgroundColor: Colors.red,
          content: Text(
            "😥 Đăng nhập thất bại!",
            style: AppWidget.semiBoldTextFieldStyle(),
          ),
        )));
      }
      // ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      //   content: Text(
      //     errorMessage,
      //     style: TextStyle(fontSize: 18, color: Colors.black),
      //   ),
      // ));
    }
  }

  // Future<void> userLogin(BuildContext context, String email, String password) async {
  //   try {
  //     // Đăng nhập với Firebase
  //     UserCredential userCredential = await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(email: email, password: password);
  //
  //     // Xóa dữ liệu cũ trong SharedPreferences để làm mới thông tin
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.clear();
  //
  //     // Lưu thông tin tài khoản mới vào SharedPreferences (nếu cần)
  //     await prefs.setString('userEmail', email);
  //
  //     // Chuyển sang màn hình chính (BottomNav)
  //     Navigator.push(
  //         context, MaterialPageRoute(builder: (context) => BottomNav()));
  //
  //     // Hiển thị thông báo thành công
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.green,
  //         content: Text(
  //           '🥰 Đăng nhập thành công',
  //           style: AppWidget.semiBoldTextFieldStyle(),
  //         ),
  //       ),
  //     );
  //
  //     print("Đăng nhập thành công: ${userCredential.user?.email}");
  //   } on FirebaseAuthException catch (e) {
  //     // Xử lý lỗi
  //     String errorMessage = '';
  //     if (e.code == 'user-not-found') {
  //       errorMessage = '😥 Không tìm thấy người dùng!';
  //     } else if (e.code == 'wrong-password') {
  //       errorMessage = '😥 Tên đăng nhập hoặc mật khẩu sai!';
  //     } else {
  //       errorMessage = '😥 Lỗi: ${e.message}';
  //     }
  //
  //     // Hiển thị thông báo lỗi
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         backgroundColor: Colors.red,
  //         content: Text(
  //           errorMessage,
  //           style: AppWidget.semiBoldTextFieldStyle(),
  //         ),
  //       ),
  //     );
  //
  //     print("Đăng nhập thất bại: $e");
  //   }
  // }

  // userLogin() async {
  //   try {
  //     // Đăng nhập với Firebase
  //     await FirebaseAuth.instance
  //         .signInWithEmailAndPassword(email: email, password: password);
  //
  //     // Lưu thông tin đăng nhập nếu thành công
  //     //await _saveCredentials();
  //
  //     // Lấy thông tin người dùng từ Firebase
  //     User? user = FirebaseAuth.instance.currentUser;
  //     if (user != null) {
  //       // Lấy tên người dùng (nếu có)
  //       String userName = user.displayName ?? 'Người dùng';
  //
  //       // Chuyển sang màn hình BottomNav với tên người dùng đã đăng nhập
  //       Navigator.pushReplacement(
  //           context, MaterialPageRoute(builder: (context) => BottomNav()));
  //
  //       // Hiển thị thông báo thành công
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         backgroundColor: Colors.green,
  //         content: Text(
  //           '🥰 Đăng nhập thành công',
  //           style: AppWidget.semiBoldTextFieldStyle(),
  //         ),
  //       ));
  //     } else {
  //       // Xử lý nếu người dùng không tồn tại (lý do khác)
  //       ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //         backgroundColor: Colors.red,
  //         content: Text(
  //           "😥 Lỗi: Không tìm thấy người dùng!",
  //           style: AppWidget.semiBoldTextFieldStyle(),
  //         ),
  //       ));
  //     }
  //   } on FirebaseAuthException catch (e) {
  //     // Xử lý lỗi đăng nhập
  //     String errorMessage = '';
  //     if (e.code == 'user-not-found') {
  //       errorMessage = '😥 Không tìm thấy người dùng!';
  //     } else if (e.code == 'wrong-password') {
  //       errorMessage = '😥 Tên đăng nhập hoặc mật khẩu sai';
  //     } else {
  //       errorMessage = '😥 Đăng nhập thất bại!';
  //     }
  //     // Hiển thị thông báo lỗi
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //       backgroundColor: Colors.red,
  //       content: Text(
  //         errorMessage,
  //         style: AppWidget.semiBoldTextFieldStyle(),
  //       ),
  //     ));
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Nền cam và logo
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 5,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    // Color(0xFFff5c30),
                    // Color(0xFFe74c1a),
                    Colors.blue,
                    Colors.blue,
                  ],
                ),
              ),
              child: Center(
                child: Image.asset(
                  'images/logo4.png',
                  width: 70, // Tăng kích thước logo
                  height: 70,
                ),
              ),
            ),
            // Form đăng nhập
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
                          "Đăng nhập",
                          style: AppWidget.headlineTextFieldStyle()
                              .copyWith(color: Colors.blue),
                        ),
                        SizedBox(height: 20),
                        // Ô nhập Email
                        TextFormField(
                          controller: useremailcontroller,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '👀 Vui lòng nhập Email!';
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            hintText: 'Email',
                            hintStyle: AppWidget.semiBoldTextFieldStyle(),
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Ô nhập mật khẩu
                        TextFormField(
                          controller: userpasswordcontroller,
                          obscureText: !isPasswordVisible,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return '👀 Vui lòng nhập mật khẩu!';
                            }
                            return null;
                          },
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
                        // Nhớ mật khẩu và Quên mật khẩu
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: isRememberMeChecked,
                                  onChanged: (value) {
                                    setState(() {
                                      isRememberMeChecked = value!;
                                    });
                                  },
                                ),
                                Text(
                                  "Nhớ mật khẩu?",
                                  style: AppWidget.lightTextFieldStyle(),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            Forgotpassword()));
                              },
                              child: Text(
                                "Quên mật khẩu?",
                                style: AppWidget.lightTextFieldStyle(),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 20),
                        // Nút đăng nhập
                        GestureDetector(
                          onTap: () {
                            if (_formkey.currentState!.validate()) {
                              setState(() {
                                email = useremailcontroller.text;
                                password = userpasswordcontroller.text;
                              });
                            }
                            userLogin();
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 8),
                            width: 200,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: Text(
                                "Đăng nhập",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        // Đăng ký
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Signup()));
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Chưa có tài khoản? ",
                              style: AppWidget.semiBoldTextFieldStyle(),
                              children: [
                                TextSpan(
                                  text: "Đăng ký ngay!",
                                  style: AppWidget.semiBoldTextFieldStyle()
                                      .copyWith(color: Colors.red),
                                ),
                              ],
                            ),
                          ),
                        ),
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
