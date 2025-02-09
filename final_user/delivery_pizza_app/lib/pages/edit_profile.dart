// import 'package:flutter/material.dart';
// import 'package:delivery_pizza_app/pages/change_password.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:delivery_pizza_app/service/shared_pref.dart';
// import 'package:delivery_pizza_app/widget_support/widget_support.dart';
//
// class EditProfile extends StatelessWidget {
//   final String name;
//   final String email;
//   final String phone;
//   final String address;
//
//   const EditProfile({required this.name, required this.email, required this.phone, required this.address, Key? key})
//       : super(key: key);
//
//   Widget _buildInfoTile(IconData icon, String title, String subtitle) {
//     return Container(
//       margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//       child: Material(
//         borderRadius: BorderRadius.circular(10),
//         elevation: 2,
//         child: Container(
//           padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
//           decoration: BoxDecoration(
//               color: Colors.white, borderRadius: BorderRadius.circular(10)),
//           child: Row(
//             children: [
//               Icon(icon, color: Colors.black),
//               SizedBox(width: 20),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(title,
//                       style: TextStyle(
//                           color: Colors.black,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600)),
//                   Text(subtitle,
//                       style: TextStyle(
//                           color: Colors.red,
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600)),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.black),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Image(
//           image: AssetImage("images/logo5.png"),
//           height: 40,
//         ),
//         centerTitle: true,
//         backgroundColor: Colors.white,
//       ),
//       body: CustomScrollView(
//         slivers: [
//           SliverList(
//             delegate: SliverChildListDelegate([
//               _buildInfoTile(Icons.person, "Tên: ", name!),
//               _buildInfoTile(Icons.email, "Email: ", email!),
//               _buildInfoTile(Icons.phone, "Sđt: ", phone!),
//               GestureDetector(
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(builder: (context) => const ChangePassword()),
//                   );
//                 },
//                 child: _buildInfoTile(Icons.security, "Đổi mật khẩu", ""),
//               ),
//             ]),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:delivery_pizza_app/pages/change_password.dart';

class EditProfile extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  const EditProfile(
      {required this.name,
        required this.email,
        required this.phone,
        required this.address,
        Key? key})
      : super(key: key);

  @override
  State<EditProfile> createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  String? id, currentAddress;
  final TextEditingController _addressController = TextEditingController();

  getsharedthepref() async {
    id = await SharedPreferenceHelper().getUserId();
    currentAddress = await SharedPreferenceHelper().getUserAddress();
    setState(() {});
  }

  ontheload() async {
    await getsharedthepref();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    super.initState();
  }

  // Hàm cập nhật địa chỉ trong Firestore
  Future<void> updateAddress(String newAddress) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .update({'Address': newAddress});
      await SharedPreferenceHelper()
          .saveUserAddress(_addressController.text.trim());

      setState(() {
        currentAddress = newAddress;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.green,
        content: Text("Cập nhật địa chỉ thành công 🥰",
            style: TextStyle(fontSize: 18)),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.red,
        content: Text("Có lỗi xảy ra khi cập nhật địa chỉ!",
            style: TextStyle(fontSize: 18)),
      ));
    }
  }

  // Hiển thị hộp thoại thay đổi địa chỉ
  void _showAddressDialog() {
    _addressController.text = currentAddress ?? "Không có địa chỉ";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Thay đổi địa chỉ',
          style: TextStyle(
              fontFamily: "BalooPaaji2", fontSize: 18, color: Colors.black),
        ),
        content: TextField(
          controller: _addressController,
          decoration: const InputDecoration(
            hintText: 'Nhập địa chỉ mới',
            hintStyle: TextStyle(
                fontFamily: "BalooPaaji2", fontSize: 18, color: Colors.black),
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          // TextButton(
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Hủy',
              style: TextStyle(
                  fontFamily: "BalooPaaji2", fontSize: 18, color: Colors.red),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_addressController.text.trim().isNotEmpty) {
                updateAddress(_addressController.text.trim());

                Navigator.pop(context);
              }
            },
            child: const Text(
              'Lưu',
              style: TextStyle(
                  fontFamily: "BalooPaaji2", fontSize: 18, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        elevation: 2,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Row(
            children: [
              Icon(icon, color: Colors.black),
              const SizedBox(width: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
                    Flexible(
                      child: Text(
                        subtitle,
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        backgroundColor: Colors.blueAccent,
      ),
      body: CustomScrollView(
        slivers: [
          SliverList(
            delegate: SliverChildListDelegate([
              _buildInfoTile(Icons.person, "Tên: ", widget.name),
              _buildInfoTile(Icons.email, "Email: ", widget.email),
              _buildInfoTile(Icons.phone, "Sđt: ", widget.phone),
              GestureDetector(
                onTap: _showAddressDialog,
                child: _buildInfoTile(Icons.home, "Địa chỉ: ",
                    currentAddress ?? "Không có địa chỉ"),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const ChangePassword()),
                  );
                },
                child: _buildInfoTile(Icons.security, "Đổi mật khẩu", ""),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }
}
