import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:delivery_pizza_app/pages/home.dart';
import 'package:delivery_pizza_app/pages/order.dart';
import 'package:delivery_pizza_app/pages/profile.dart';
import 'package:delivery_pizza_app/pages/store.dart';
import 'package:delivery_pizza_app/pages/wallet.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNav extends StatefulWidget {
  const BottomNav({super.key});

  @override
  State<BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int currentTabIndex = 0;

  late List<Widget> pages;
  late Widget currentPages;
  late Home homePage;
  late Profile profile;
  late Order order;
  late Wallet wallet;
  late Store store;

  @override
  void initState() {
    homePage = Home();
    order = Order();
    store = Store();
    wallet = Wallet();
    profile = Profile();
    pages = [homePage, order, store, wallet, profile];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: CurvedNavigationBar(
          height: 65,
          backgroundColor: Colors.white,
          color: Colors.black,
          animationDuration: Duration(milliseconds: 500),
          onTap: (int index) {
            setState(() {
              currentTabIndex = index;
            });
          },
          items: [
            Icon(
              Icons.home_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.shopping_bag_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.local_pizza,
              color: Colors.white,
              size: 50,
            ),
            Icon(
              Icons.wallet_outlined,
              color: Colors.white,
            ),
            Icon(
              Icons.person_outlined,
              color: Colors.white,
            )
          ],
      ),
      body: pages[currentTabIndex],
    );
  }
}

