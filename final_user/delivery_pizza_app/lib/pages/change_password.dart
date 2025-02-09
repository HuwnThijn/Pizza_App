import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends StatefulWidget {
  const ChangePassword({Key? key}) : super(key: key);

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Lấy user hiện tại
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // Xác thực lại với mật khẩu cũ
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldPasswordController.text,
        );

        // Xác thực lại user
        await user.reauthenticateWithCredential(credential);

        // Đổi mật khẩu mới
        await user.updatePassword(newPasswordController.text);

        // Hiển thị thông báo thành công
        _showSnackBar('🥰 Đổi mật khẩu thành công', Colors.green);

        // Quay lại màn hình trước
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage = '';
      switch (e.code) {
        case 'wrong-password':
          errorMessage = '😥 Mật khẩu cũ không chính xác';
          break;
        case 'weak-password':
          errorMessage =
          '😥 Mật khẩu mới quá yếu! Vui lòng chọn mật khẩu mạnh hơn';
          break;
        case 'requires-recent-login':
          errorMessage = '📢 Vui lòng đăng nhập lại để thực hiện thao tác này';
          break;
        default:
          errorMessage = '😥 Có lỗi xảy ra. Vui lòng thử lại!';
      }
      _showSnackBar(errorMessage, Colors.red);
    } catch (e) {
      _showSnackBar('😥 Có lỗi xảy ra. Vui lòng thử lại!', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Đổi Mật Khẩu',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header image
                Container(
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Image.asset(
                    "images/logo5.png",
                    height: 100,
                  ),
                ),
                const SizedBox(height: 20),

                // Old password field
                TextFormField(
                  controller: oldPasswordController,
                  obscureText: !_isOldPasswordVisible,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập mật khẩu cũ';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Mật khẩu cũ",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isOldPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isOldPasswordVisible = !_isOldPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // New password field
                TextFormField(
                  controller: newPasswordController,
                  obscureText: !_isNewPasswordVisible,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value!.length < 6) {
                      return '📢 Mật khẩu phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Mật khẩu mới",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Confirm password field
                TextFormField(
                  controller: confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  validator: (value) {
                    if (value?.isEmpty ?? true) {
                      return '📌 Vui lòng xác nhận mật khẩu mới';
                    }
                    if (value != newPasswordController.text) {
                      return '😥 Mật khẩu xác nhận không khớp';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: "Xác nhận mật khẩu mới",
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible =
                          !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide:
                      const BorderSide(color: Colors.blue, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit button
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _changePassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                      "Xác nhận",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
