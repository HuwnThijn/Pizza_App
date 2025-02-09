// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:delivery_pizza_app/admin/home_admin.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// class AdminLogin extends StatefulWidget {
//   const AdminLogin({super.key});
//
//   @override
//   State<AdminLogin> createState() => _AdminLoginState();
// }
//
// class _AdminLoginState extends State<AdminLogin> {
//   final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
//
//   TextEditingController usernamecontroller = new TextEditingController();
//   TextEditingController userpasswordcontroller = new TextEditingController();
//
//   bool _isPasswordVisible = false; // Biến trạng thái
//   bool _rememberMe = false; // Biến trạng thái "Nhớ mật khẩu"
//
//   @override
//   void initState() {
//     super.initState();
//     _loadSavedLogin(); // Tải thông tin đã lưu
//   }
//
//   // Hàm tải thông tin từ SharedPreferences
//   void _loadSavedLogin() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       _rememberMe = prefs.getBool('remember_me') ?? false;
//       if (_rememberMe) {
//         usernamecontroller.text = prefs.getString('username') ?? '';
//         userpasswordcontroller.text = prefs.getString('password') ?? '';
//       }
//     });
//   }
//
//   // Hàm lưu thông tin vào SharedPreferences
//   void _saveLoginDetails() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     if (_rememberMe) {
//       await prefs.setBool('remember_me', true);
//       await prefs.setString('username', usernamecontroller.text.trim());
//       await prefs.setString('password', userpasswordcontroller.text.trim());
//     } else {
//       await prefs.remove('remember_me');
//       await prefs.remove('username');
//       await prefs.remove('password');
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFFededeb),
//       body: SingleChildScrollView(
//         child: Stack(
//           children: [
//             Container(
//               margin:
//               EdgeInsets.only(top: MediaQuery.of(context).size.height / 2.5),
//               padding: EdgeInsets.only(top: 45, left: 20, right: 20),
//               height: MediaQuery.of(context).size.height,
//               width: MediaQuery.of(context).size.width,
//               decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       colors: [Color.fromARGB(255, 53, 51, 51), Colors.black],
//                       begin: Alignment.topLeft,
//                       end: Alignment.bottomRight),
//                   borderRadius: BorderRadius.vertical(
//                       top: Radius.elliptical(
//                           MediaQuery.of(context).size.width, 110))),
//             ),
//             Container(
//               margin: EdgeInsets.only(top: 60, right: 30, left: 30),
//               child: Form(
//                   key: _formkey,
//                   child: Column(
//                     children: [
//                       Image.asset(
//                         'images/logo4.png',
//                         width: 70, // Tăng kích thước logo
//                         height: 70,
//                       ),
//                       SizedBox(
//                         height: 30,
//                       ),
//                       Material(
//                         elevation: 3,
//                         borderRadius: BorderRadius.circular(20),
//                         child: Container(
//                           height: MediaQuery.of(context).size.height / 2.2,
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: BorderRadius.circular(20),
//                           ),
//                           child: Column(
//                             children: [
//                               SizedBox(
//                                 height: 50,
//                               ),
//                               Container(
//                                 padding: EdgeInsets.only(
//                                     top: 5, bottom: 5, left: 20),
//                                 margin: EdgeInsets.symmetric(horizontal: 20),
//                                 decoration: BoxDecoration(
//                                     border: Border.all(
//                                         color:
//                                         Color.fromARGB(255, 160, 160, 147)),
//                                     borderRadius: BorderRadius.circular(10)),
//                                 child: Center(
//                                   child: TextFormField(
//                                     decoration: InputDecoration(
//                                         border: InputBorder.none,
//                                         hintText: 'Tên đăng nhập admin',
//                                         hintStyle: TextStyle(
//                                             color: Color.fromARGB(
//                                                 255, 160, 160, 147))),
//                                     controller: usernamecontroller,
//                                     validator: (value) {
//                                       if (value == null || value.isEmpty) {
//                                         return '👀 Vui lòng nhập tên đăng nhập';
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(
//                                 height: 40,
//                               ),
//                               Container(
//                                 padding: EdgeInsets.only(
//                                     top: 5, bottom: 5, left: 20),
//                                 margin: EdgeInsets.symmetric(horizontal: 20),
//                                 decoration: BoxDecoration(
//                                     border: Border.all(
//                                         color:
//                                         Color.fromARGB(255, 160, 160, 147)),
//                                     borderRadius: BorderRadius.circular(10)),
//                                 // child: Center(
//                                 //   child: TextFormField(
//                                 //     decoration: InputDecoration(
//                                 //         border: InputBorder.none,
//                                 //         hintText: 'Mật khẩu',
//                                 //         hintStyle: TextStyle(
//                                 //             color: Color.fromARGB(
//                                 //                 255, 160, 160, 147))),
//                                 //     controller: userpasswordcontroller,
//                                 //     validator: (value) {
//                                 //       if (value == null) {
//                                 //         return 'Vui lòng nhập mật khẩu';
//                                 //       }
//                                 //     },
//                                 //   ),
//                                 // ),
//                                 child: Center(
//                                   child: TextFormField(
//                                     controller: userpasswordcontroller,
//                                     obscureText: !_isPasswordVisible,
//                                     decoration: InputDecoration(
//                                       border: InputBorder.none,
//                                       hintText: 'Mật khẩu',
//                                       hintStyle: TextStyle(
//                                           color: Color.fromARGB(
//                                               255, 160, 160, 147)),
//                                       suffixIcon: IconButton(
//                                         icon: Icon(
//                                           _isPasswordVisible
//                                               ? Icons.visibility
//                                               : Icons.visibility_off,
//                                           color: Color.fromARGB(
//                                               255, 160, 160, 147),
//                                         ),
//                                         onPressed: () {
//                                           setState(() {
//                                             _isPasswordVisible =
//                                             !_isPasswordVisible;
//                                           });
//                                         },
//                                       ),
//                                     ),
//                                     validator: (value) {
//                                       if (value == null) {
//                                         return '👀 Vui lòng nhập mật khẩu';
//                                       }
//                                     },
//                                   ),
//                                 ),
//                               ),
//                               GestureDetector(
//                                 onTap: () {
//                                   LoginAmin();
//                                 },
//                                 child: Container(
//                                   padding: EdgeInsets.symmetric(vertical: 12),
//                                   margin: EdgeInsets.symmetric(horizontal: 20),
//                                   width: MediaQuery.of(context).size.width,
//                                   decoration: BoxDecoration(
//                                       color: Colors.black,
//                                       borderRadius: BorderRadius.circular(10)),
//                                   child: Center(
//                                     child: Text(
//                                       "Đăng nhập",
//                                       style: TextStyle(
//                                           color: Colors.white,
//                                           fontSize: 20,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                 ),
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   )),
//             )
//           ],
//         ),
//       ),
//     );
//   }
//
//   LoginAmin() {
//     FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
//       snapshot.docs.forEach((result) {
//         if (result.data()['id'] != usernamecontroller.text.trim()) {
//           ScaffoldMessenger.of(context).showSnackBar((SnackBar(
//             backgroundColor: Colors.red,
//             content: Text(
//               "😥 Tên đăng nhập không đúng",
//               style: TextStyle(fontSize: 18).copyWith(color: Colors.white),
//             ),
//           )));
//         } else if (result.data()['password'] !=
//             userpasswordcontroller.text.trim()) {
//           ScaffoldMessenger.of(context).showSnackBar((SnackBar(
//             backgroundColor: Colors.red,
//             content: Text(
//               "❌ Mật khẩu không đúng",
//               style: TextStyle(fontSize: 18).copyWith(color: Colors.white),
//             ),
//           )));
//         } else {
//           Route route = MaterialPageRoute(builder: (context) => HomeAdmin());
//           Navigator.pushReplacement(context, route);
//           ScaffoldMessenger.of(context).showSnackBar((SnackBar(
//             backgroundColor: Colors.green,
//             content: Text(
//               "Đăng nhập thành công 🥰",
//               style: TextStyle(fontSize: 18).copyWith(color: Colors.white),
//             ),
//           )));
//         }
//       });
//     });
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/admin/home_admin.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminLogin extends StatefulWidget {
  const AdminLogin({super.key});

  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> with TickerProviderStateMixin {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  TextEditingController usernamecontroller = TextEditingController();
  TextEditingController userpasswordcontroller = TextEditingController();

  bool _isPasswordVisible = false; // Biến trạng thái mật khẩu
  bool _rememberMe = false; // Biến trạng thái "Nhớ mật khẩu"

  late AnimationController _controller;

  // Danh sách nhiều hình ảnh
  final List<String> images = [
    'images/icon_pizza.png',
    'images/icon_coke.png',
    'images/icon_burger.png',
    'images/icon_chicken.png',
    'images/icon_combo.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedLogin(); // Tải thông tin đã lưu

    // Khởi tạo AnimationController
    // _controller = AnimationController(
    //   vsync: this,
    //   duration: Duration(seconds: 10), // Điều chỉnh thời gian cho phù hợp
    // )..repeat(); // Animation lặp vô hạn
  }

  // Hàm tải thông tin từ SharedPreferences
  void _loadSavedLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('remember_me') ?? false;
      if (_rememberMe) {
        usernamecontroller.text = prefs.getString('username') ?? '';
        userpasswordcontroller.text = prefs.getString('password') ?? '';
      }
    });
  }

  // Hàm lưu thông tin vào SharedPreferences
  void _saveLoginDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (_rememberMe) {
      await prefs.setBool('remember_me', true);
      await prefs.setString('username', usernamecontroller.text.trim());
      await prefs.setString('password', userpasswordcontroller.text.trim());
    } else {
      await prefs.remove('remember_me');
      await prefs.remove('username');
      await prefs.remove('password');
    }
  }

  // @override
  // void dispose() {
  //   _controller.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFededeb),
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Phần nền gradient
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 2.3),
              padding: EdgeInsets.only(
                top: 45,
                left: 20,
                right: 20,
              ),
              height: MediaQuery.of(context).size.height,
              // width: MediaQuery.of(context).size.width,
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 53, 51, 51), Colors.black],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.vertical(
                      top: Radius.elliptical(
                          MediaQuery.of(context).size.width, 110))),
            ),
            // Form đăng nhập
            Container(
              margin: EdgeInsets.only(
                top: 60,
                right: 600,
                left: 600,
              ),
              child: Form(
                key: _formkey,
                child: Column(
                  children: [
                    Image.asset(
                      'images/logo4.png',
                      width: 70,
                      height: 70,
                    ),
                    SizedBox(height: 30),
                    Material(
                      elevation: 3,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 50),
                            // Ô nhập tên đăng nhập
                            _buildTextField(
                              'Tên đăng nhập admin',
                              usernamecontroller,
                            ),
                            SizedBox(height: 40),
                            // Ô nhập mật khẩu
                            _buildPasswordField(),
                            SizedBox(height: 20),
                            // Checkbox "Nhớ mật khẩu"
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value!;
                                    });
                                  },
                                ),
                                Text(
                                  "Nhớ mật khẩu?",
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 16),
                                ),
                              ],
                            ),
                            SizedBox(height: 20),
                            // Nút Đăng nhập
                            GestureDetector(
                              onTap: () {
                                _loginAdmin();
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: 12),
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                width: MediaQuery.of(context).size.width,
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Center(
                                  child: Text(
                                    "Đăng nhập",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                            //SizedBox(height: 20),
                            // // Phần 5 ảnh dạng hình tròn di chuyển từ phải sang trái
                            // Container(
                            //   height: 70, // Chiều cao đủ cho hình ảnh
                            //   child: AnimatedBuilder(
                            //     animation: _controller,
                            //     builder: (context, child) {
                            //       return Stack(
                            //         children: List.generate(images.length, (index) {
                            //           double startPosition =
                            //               MediaQuery.of(context).size.width /
                            //                   1.2 *
                            //                   index;
                            //           double moveX = MediaQuery.of(context)
                            //                   .size
                            //                   .width -
                            //               ((_controller.value *
                            //                           (MediaQuery.of(context)
                            //                                   .size
                            //                                   .width +
                            //                               150)) +
                            //                       startPosition) %
                            //                   (MediaQuery.of(context)
                            //                           .size
                            //                           .width +
                            //                       150);
                            //
                            //           return Positioned(
                            //             top: 10,
                            //             left: moveX,
                            //             child: ClipOval(
                            //               child: Image.asset(
                            //                 // 'images/icon_pizza.png',
                            //                 images[index], // Lấy ảnh từ danh sách
                            //                 width: 100,
                            //                 height: 50,
                            //                 fit: BoxFit.cover,
                            //               ),
                            //             ),
                            //           );
                            //         }),
                            //       );
                            //     },
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  // Widget ô nhập tên đăng nhập
  Widget _buildTextField(String hint, TextEditingController controller) {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.black)),
        validator: (value) =>
            value == null || value.isEmpty ? '👀 Vui lòng nhập $hint' : null,
      ),
    );
  }

  // Widget ô nhập mật khẩu
  Widget _buildPasswordField() {
    return Container(
      padding: EdgeInsets.only(top: 5, bottom: 5, left: 20),
      margin: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          borderRadius: BorderRadius.circular(10)),
      child: TextFormField(
        controller: userpasswordcontroller,
        obscureText: !_isPasswordVisible,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Mật khẩu',
          hintStyle: TextStyle(color: Colors.black),
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
              color: Colors.black,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? '👀 Vui lòng nhập mật khẩu' : null,
      ),
    );
  }

  // Hàm xử lý đăng nhập
  void _loginAdmin() {
    FirebaseFirestore.instance.collection("Admin").get().then((snapshot) {
      bool isValid = false;
      for (var result in snapshot.docs) {
        if (result.data()['id'] == usernamecontroller.text.trim() &&
            result.data()['password'] == userpasswordcontroller.text.trim()) {
          isValid = true;
          _saveLoginDetails(); // Lưu thông tin đăng nhập nếu nhớ mật khẩu
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => HomeAdmin()));
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text("♥ Đăng nhập thành công",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                )),
          ));
          break;
        }
      }
      if (!isValid) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("😥 Tên đăng nhập hoặc mật khẩu không đúng",
              style: TextStyle(
                color: Colors.white,
                fontSize: 17,
              )),
        ));
      }
    });
  }
}
