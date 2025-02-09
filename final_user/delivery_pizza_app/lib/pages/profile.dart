import 'dart:io';
import 'package:delivery_pizza_app/pages/Ggmap.dart';
import 'package:delivery_pizza_app/pages/edit_profile.dart';
import 'package:delivery_pizza_app/pages/order_history.dart';
import 'package:delivery_pizza_app/pages/wishlist.dart';
import 'package:delivery_pizza_app/service/auth.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:random_string/random_string.dart';
import 'package:delivery_pizza_app/pages/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  double _rating = 0.0;
  String? profile, name, email, phone, address;
  final ImagePicker _picker = ImagePicker();
  File? selectedImage;

  // final List<Map<String, dynamic>> wishlist;
  // Profile({required this.wishlist});

  Future<void> getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImage = File(image.path);
      setState(() {
        uploadItem();
      });
    } else {
      // Xử lý khi người dùng không chọn ảnh
      print("📌 Người dùng chưa chọn ảnh!");
    }
  }

  uploadItem() async {
    if (selectedImage != null) {
      String addId = randomAlphaNumeric(10);

      Reference firebaseStorageRef =
          FirebaseStorage.instance.ref().child("blogImages").child(addId);
      final UploadTask task = firebaseStorageRef.putFile(selectedImage!);

      var downLoadUrl = await (await task).ref.getDownloadURL();

      await SharedPreferenceHelper().saveUserProfile(downLoadUrl);

      // Kiểm tra xem widget còn mounted hay không trước khi gọi setState()
      if (mounted) {
        setState(() {});
      }
    }
  }

  getthesharepref() async {
    profile = await SharedPreferenceHelper().getUserProfile();
    name = await SharedPreferenceHelper().getUserName();
    email = await SharedPreferenceHelper().getUserEmail();
    phone = await SharedPreferenceHelper().getUserPhone();
    address = await SharedPreferenceHelper().getUserAddress();

    setState(() {});
  }

  ontheload() async {
    await getthesharepref();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  // ms thêm
  @override
  void dispose() {
    super.dispose();
  }

  // Hàm mở liên kết URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url); // Chuyển chuỗi URL thành đối tượng Uri
    try {
      if (await canLaunchUrl(uri)) {
        // Kiểm tra khả năng mở URL
        await launchUrl(uri); // Mở URL
      } else {
        throw '😥 Không thể mở liên kết: $url'; // Ném lỗi nếu không mở được
      }
    } catch (e) {
      print(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('😥 Không thể mở liên kết, vui lòng thử lại!')),
      );
    }
  }

  // Phương thức gửi email
  Future<void> sendEmail(double rating) async {
    // Cấu hình thông tin đăng nhập vào Gmail và sử dụng mật khẩu ứng dụng
    final smtpServer = gmail('thinhyone@gmail.com', 'mrqr czhh fcus buct');

    // Tạo đối tượng email
    final message = Message()
      ..from = Address(email!, name!)
      ..recipients.add('hthin217@gmail.com') // Địa chỉ admin
      //..recipients.add('nhattan.9a7@gmail.com') // Địa chỉ admin
      ..subject = 'Đánh giá dịch vụ'
      ..text = 'Đánh giá của khách hàng: $rating sao';

    try {
      // Gửi email
      final sendReport = await send(message, smtpServer);
      print('🥰 Đã gửi email thành công: ${sendReport.toString()}');
    } catch (e) {
      print('😥 Lỗi khi gửi email: $e');
    }
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nội dung bên trái: Icon và Text
          Row(
            children: [
              Icon(
                icon,
                size: 25,
                color: Colors.black,
              ),
              SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContact(IconData icon, String title, String subtitle) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nội dung bên trái: Icon và Text
          Row(
            children: [
              Icon(
                icon,
                size: 25,
                color: Colors.black,
              ),
              SizedBox(width: 20),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          // Nội dung bên phải: Biểu tượng Facebook và Google
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.facebook, size: 40, color: Colors.blue),
                onPressed: () {
                  _launchURL(
                      'https://www.facebook.com/PizzaHutVN'); // Mở link Facebook
                },
              ),
              IconButton(
                icon: Icon(Icons.play_circle, size: 40, color: Colors.red),
                onPressed: () {
                  _launchURL('https://youtube.com'); // Mở link Google
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingTile(
      String title, double rating, Function(double) onRatingChanged) {
    return Container(
      padding: EdgeInsets.all(20),
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề đánh giá dịch vụ
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          // RatingBar
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: true,
            itemCount: 5,
            itemBuilder: (context, _) => Icon(
              Icons.star,
              color: Colors.amber,
            ),
            onRatingUpdate: onRatingChanged,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: name == null
          ? Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  automaticallyImplyLeading: false, // Ẩn nút Back
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.vertical(
                          bottom: Radius.elliptical(
                              MediaQuery.of(context).size.width, 105),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 30),
                          // Material(
                          //   elevation: 10,
                          //   borderRadius: BorderRadius.circular(60),
                          //   child: ClipRRect(
                          //     borderRadius: BorderRadius.circular(60),
                          //     child: selectedImage == null
                          //         ? GestureDetector(
                          //             onTap: () {
                          //               getImage();
                          //             },
                          //             child: profile == null
                          //                 ? Image.asset(
                          //                     "images/logo4.png",
                          //                     height: 120,
                          //                     width: 120,
                          //                     fit: BoxFit.cover,
                          //                   )
                          //                 : Image.network(
                          //                     profile!,
                          //                     height: 120,
                          //                     width: 120,
                          //                     fit: BoxFit.cover,
                          //                   ),
                          //           )
                          //         : Image.file(
                          //             selectedImage!,
                          //             height: 120,
                          //             width: 120,
                          //             fit: BoxFit.cover,
                          //           ),
                          //   ),
                          // ),
                          Material(
                            elevation: 10,
                            borderRadius: BorderRadius.circular(60),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: GestureDetector(
                                onTap: () async {
                                  await getImage(); // Gọi hàm để lấy ảnh
                                  if (selectedImage != null) {
                                    // Hiển thị thông báo thành công
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          "✔ Cập nhật ảnh thành công!",
                                          style: TextStyle(color: Colors.white),
                                        ),
                                        backgroundColor: Colors.green,
                                        duration: Duration(seconds: 3),
                                      ),
                                    );
                                  }
                                },
                                child: selectedImage == null
                                    ? (profile == null
                                        ? Image.asset(
                                            "images/logo4.png",
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          )
                                        : Image.network(
                                            profile!,
                                            height: 120,
                                            width: 120,
                                            fit: BoxFit.cover,
                                          ))
                                    : Image.file(
                                        selectedImage!,
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            name!,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                fontFamily: "BalooPaaji2"),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    // Sửa lại phần GestureDetector cho "Thông tin cá nhân"
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => EditProfile(
                                    name: name!,
                                    email: email!,
                                    phone: phone!,
                                    address: address!,
                                  )),
                        );
                      },
                      child: _buildInfoTile(
                          Icons.contact_mail_outlined, "Thông tin cá nhân", ""),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => Wishlist()));
                      },
                      child: _buildInfoTile(
                          Icons.favorite, "Danh sách sản phẩm yêu thích", ""),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => Ggmap()));
                      },
                      child: _buildInfoTile(
                          Icons.local_shipping, "Theo dõi đơn hàng", ""),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => OrderHistory()),
                        );
                      },
                      child:
                          _buildInfoTile(Icons.history, "Lịch sử đơn hàng", ""),
                    ),
                    _buildRatingTile(
                      "Đánh giá dịch vụ",
                      _rating,
                      (rating) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Xác nhận"),
                              content: Text("Bạn muốn gửi đánh giá?"),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context)
                                        .pop(); // Đóng dialog, không thực hiện gì cả
                                  },
                                  child: Text("Không",
                                      style: AppWidget.semiBoldTextFieldStyle()
                                          .copyWith(color: Colors.red)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Thực hiện cập nhật rating và gửi email
                                    setState(() {
                                      _rating = rating;
                                    });

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        backgroundColor: Colors.green,
                                        content: Text(
                                          "Cảm ơn bạn gửi đánh giá cho chúng tôi 🥰",
                                          style:
                                              AppWidget.semiBoldTextFieldStyle()
                                                  .copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    );

                                    sendEmail(
                                        rating); // Gọi hàm sendEmail sau khi xác nhận

                                    Navigator.of(context).pop(); // Đóng dialog
                                  },
                                  child: Text("Có",
                                      style: AppWidget.semiBoldTextFieldStyle()
                                          .copyWith(color: Colors.blueAccent)),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    ),

                    GestureDetector(
                      onTap: () async {
                        bool confirmDelete = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Xác nhận"),
                            content: Text("Bạn muốn xóa tài khoản?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pop(false), // 'No' button
                                child: Text(
                                  "Không",
                                  style: AppWidget.semiBoldTextFieldStyle()
                                      .copyWith(color: Colors.blueAccent),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pop(true), // 'Yes' button
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
                          await AuthMethods()
                              .DeleteUser(); // Replace with actual delete account method
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                backgroundColor: Colors.green,
                                content: Text(
                                  "✔ Xóa tài khoản thành công",
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                )),
                          );
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                        }
                      },
                      child: _buildInfoTile(Icons.delete, "Xóa tài khoản", ""),
                    ),
                    GestureDetector(
                      onTap: () async {
                        bool confirmXoa = await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Xác nhận"),
                            content: Text("Bạn muốn đăng xuất tài khoản?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pop(false), // 'No' button
                                child: Text(
                                  "Không",
                                  style: AppWidget.semiBoldTextFieldStyle()
                                      .copyWith(color: Colors.blueAccent),
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.of(context)
                                    .pop(true), // 'Yes' button
                                child: Text(
                                  "Có",
                                  style: AppWidget.semiBoldTextFieldStyle()
                                      .copyWith(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmXoa == true) {
                          // Đăng xuất Firebase
                          await AuthMethods().SignOut();

                          // Quay lại màn hình đăng nhập
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (context) => Login()),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: Colors.green,
                              content: Text(
                                '🥰 Đăng xuất thành công',
                                style: AppWidget.semiBoldTextFieldStyle(),
                              ),
                            ),
                          );
                        }
                      },
                      child: _buildInfoTile(Icons.logout, "Đăng xuất", ""),
                    ),
                    _buildContact(Icons.connect_without_contact,
                        "Liên hệ với Pizza Hut", ""),
                  ]),
                ),
              ],
            ),
    );
  }
}
