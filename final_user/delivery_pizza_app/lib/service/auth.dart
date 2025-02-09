import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods {
  final FirebaseAuth auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await auth.currentUser;
  }

  Future SignOut() async {
    await FirebaseAuth.instance.signOut();
  }

  // Future<void> SignOut() async {
  //   try {
  //     // Xóa phiên đăng nhập Firebase
  //     await FirebaseAuth.instance.signOut();
  //
  //     // Xóa dữ liệu cục bộ trong SharedPreferences
  //     SharedPreferences prefs = await SharedPreferences.getInstance();
  //     await prefs.clear();
  //
  //     print("Đăng xuất thành công và dữ liệu cục bộ đã được xóa.");
  //   } catch (e) {
  //     print("Lỗi khi đăng xuất: $e");
  //   }
  // }

  Future DeleteUser() async {
    User? user = await FirebaseAuth.instance.currentUser;

    user?.delete();
  }
}
