import 'package:delivery_pizza_app/pages/onboard.dart';
import 'package:delivery_pizza_app/pages/theme_provider.dart';
import 'package:delivery_pizza_app/widget_support/app_constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'package:flutter/foundation.dart';

// Trong Android Studio, Thu gọn đoạn mã (Collapse):
// Windows/Linux: Ctrl + Shift + - / ctrl + -
// macOS: Command + Shift + -

// Trong Android Studio, để format code (tự động căn chỉnh mã nguồn),
// bạn sử dụng tổ hợp phím sau:
// Windows/Linux: Ctrl + Alt + L
// MacOS: Command + Option + L

// Tìm all file trg android studio
// Windows/Linux: Ctrl + Shift + F
// macOS: Cmd + Shift + F
// Cách thủ công:
// Vào menu Edit > Find > Find in Files...

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase chỉ khởi tạo cho Web và các nền tảng khác
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  if (!kIsWeb) {
    // Chỉ khởi tạo Stripe trên Mobile/Desktop
    Stripe.publishableKey = publishableKey;
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          // title: 'Flutter Demo',
          title: 'Pizza Hut',
          theme: themeProvider.themeData,
          // Màn hình bắt đầu
          //home: Login(),
          home: Onboard(),
        );
      },
    );
  }
}
