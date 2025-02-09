// import 'package:flutter/material.dart';

// class DarkLight extends StatefulWidget {
//   const DarkLight({super.key});

//   @override
//   State<DarkLight> createState() => _DarkLightState();
// }

// class _DarkLightState extends State<DarkLight> {
//   @override
//   Widget build(BuildContext context) {
//     return const Placeholder();
//   }
// }

// In theme_provider.dart
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool isDarkMode = false;

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  ThemeData get themeData => isDarkMode ? ThemeData.dark() : ThemeData.light();
}
