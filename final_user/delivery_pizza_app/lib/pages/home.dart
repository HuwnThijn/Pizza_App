import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/language/lang.dart';
import 'package:delivery_pizza_app/pages/PizzaVideoWidget.dart';
import 'package:delivery_pizza_app/pages/TermPage.dart';
import 'package:delivery_pizza_app/pages/chat_bot.dart';
import 'package:delivery_pizza_app/pages/detail_pizza.dart';
import 'package:delivery_pizza_app/pages/details.dart';
import 'package:delivery_pizza_app/pages/theme_provider.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:delivery_pizza_app/pages/store.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:url_launcher/url_launcher.dart'; // gói banner động

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool pizza = false,
      coke = false,
      combo = false,
      burger = false,
      chicken = false;
  String? userName;
  Stream? foodItemStream;
  bool isMenuOpen = false; // Trạng thái mở/đóng menu
  //String currentLanguage = "VI"; // Khai báo state cho ngôn ngữ hiện tại
  //bool isDarkMode = false; // theme app

  // banner động
  final PageController _bannerController =
      PageController(); // Điều khiển banner
  int _currentBannerIndex = 0; // Chỉ mục hiện tại của banner
  Timer? _bannerTimer; // Timer để tự động chuyển banner

  // Lấy dữ liệu từ SharedPreferences khi tải trang
  ontheload() async {
    foodItemStream = await DatabaseMethods().getFoodItem("Pizza");
    userName = await SharedPreferenceHelper().getUserName();
    setState(() {});
  }

  @override
  void initState() {
    ontheload();
    _startBannerTimer(); // time chạy của banner
    super.initState();
  }

  // banner động 1
  @override
  void dispose() {
    _bannerController.dispose();
    _bannerTimer?.cancel();
    super.dispose();
  }

  // Hàm để bắt đầu timer tự động chuyển banner
  void _startBannerTimer() {
    _bannerTimer = Timer.periodic(Duration(seconds: 4), (timer) {
      if (_bannerController.hasClients) {
        _currentBannerIndex =
            (_currentBannerIndex + 1) % 3; // Giả sử có 3 banner
        _bannerController.animateToPage(
          _currentBannerIndex,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // banner động 2
  Widget _buildBanner() {
    return Stack(
      children: [
        Container(
          height: 250, // Chiều cao mới của banner
          width: double.infinity, // Banner kéo dài toàn màn hình
          child: PageView.builder(
            controller: _bannerController,
            itemCount: 3, // Số lượng banner
            onPageChanged: (index) {
              setState(() {
                _currentBannerIndex = index;
              });
            },
            itemBuilder: (context, index) {
              final imageUrl = [
                'images/pizza1.jpg',
                'images/pizza2.jpg',
                'images/pizza3.jpg'
              ][index]; // Lấy URL hình ảnh dựa trên chỉ mục
              return _buildBannerItem(imageUrl); // Hiển thị banner tương ứng
            },
          ),
        ),
        Positioned(
          bottom: 10, // Căn sát đáy của banner
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                3, (index) => _buildDot(index == _currentBannerIndex)),
          ),
        ),
      ],
    );
  }

  // banner động 3
  Widget _buildBannerItem(String imageUrl) {
    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity! < 0) {
          _bannerController.nextPage(
              duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        } else if (details.primaryVelocity! > 0) {
          _bannerController.previousPage(
              duration: Duration(milliseconds: 300), curve: Curves.easeIn);
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.asset(
          imageUrl,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  // banner động 4
  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 200),
      margin: EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 12 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  String formatExpiryDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/y').format(date);
    } catch (e) {
      return dateStr; // Trả về chuỗi gốc nếu không parse được
    }
  }

  Widget allItems() {
    return StreamBuilder(
      stream: foodItemStream,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(snapshot.data.docs.length, (index) {
                    DocumentSnapshot ds = snapshot.data.docs[index];
                    return GestureDetector(
                      onTap: () {
                        // Navigate based on collection type
                        String currentCollection = "Pizza";
                        if (pizza)
                          currentCollection = "Pizza";
                        else if (burger)
                          currentCollection = "Burger";
                        else if (coke)
                          currentCollection = "Coke";
                        else if (chicken) currentCollection = "Chicken";

                        // Navigate based on collection type
                        if (currentCollection == "Pizza") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailPizza(
                                detail: ds["Detail"],
                                name: ds["Name"],
                                price: ds["Price"],
                                image: ds["Image"],
                              ),
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Details(
                                detail: ds["Detail"],
                                name: ds["Name"],
                                price: ds["Price"],
                                image: ds["Image"],
                              ),
                            ),
                          );
                        }
                      },
                      child: Container(
                        width: 150, // Giới hạn chiều rộng để tránh tràn viền
                        margin: EdgeInsets.all(4),
                        child: Material(
                          elevation: 5.0,
                          borderRadius: BorderRadius.circular(20),
                          clipBehavior: Clip.hardEdge,
                          child: Container(
                            padding: EdgeInsets.all(14),
                            child: Column(
                              mainAxisSize: MainAxisSize
                                  .min, // Đảm bảo nội dung không tràn
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    ds["Image"],
                                    height: 150.0,
                                    width: 150.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                Text(
                                  ds["Name"],
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                  maxLines: 1, // Chỉ hiển thị tối đa 1 dòng
                                  overflow: TextOverflow
                                      .ellipsis, // Thay phần vượt quá bằng dấu "..."
                                ),
                                // Text(
                                //   ds["Detail"],
                                //   style: AppWidget.lightTextFieldStyle(),
                                // ),
                                Text(
                                  ds["Detail"],
                                  style: AppWidget.lightTextFieldStyle(),
                                  maxLines: 1, // Chỉ hiển thị tối đa 1 dòng
                                  overflow: TextOverflow
                                      .ellipsis, // Thay phần vượt quá bằng dấu "..."
                                ),
                                Text(
                                  ds["Price"] + " " + " VNĐ",
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              )
            : CircularProgressIndicator();
      },
    );
  }

  Widget showItem() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () async {
            pizza = true;
            coke = false;
            burger = false;
            //combo = false;
            chicken = false;
            foodItemStream = await DatabaseMethods().getFoodItem("Pizza");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: pizza ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_pizza.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
                //color: pizza ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            pizza = false;
            burger = true;
            coke = false;
            chicken = false;
            foodItemStream = await DatabaseMethods().getFoodItem("Burger");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: burger ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_burger.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
                //color: burger ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            pizza = false;
            burger = false;
            coke = true;
            chicken = false;
            foodItemStream = await DatabaseMethods().getFoodItem("Coke");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: coke ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_coke.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
                //color: coke ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            pizza = false;
            coke = false;
            burger = false;
            //combo = true;
            chicken = true;
            foodItemStream = await DatabaseMethods().getFoodItem("Chicken");
            setState(() {});
          },
          child: Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              decoration: BoxDecoration(
                color: chicken ? Colors.black : Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: EdgeInsets.all(8),
              child: Image.asset(
                "images/icon_chicken.png",
                width: 40.0,
                height: 40.0,
                fit: BoxFit.cover,
                //color: coupon ? Colors.white : Colors.black,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget allItemsVertically() {
    // Truy vấn collection "Combo"
    Stream<QuerySnapshot> comboStream =
        FirebaseFirestore.instance.collection("Combo").snapshots();

    return StreamBuilder(
      stream: comboStream,
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          // Lấy danh sách tài liệu từ collection "Combo"
          List<DocumentSnapshot> comboItems = snapshot.data!.docs;

          // Kiểm tra nếu danh sách comboItems rỗng
          if (comboItems.isEmpty) {
            return Center(
              child: Text("Không có sản phẩm nào trong Combo."),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: comboItems.length,
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = comboItems[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Details(
                                detail: ds["Detail"],
                                name: ds["Name"],
                                price: ds["Price"],
                                image: ds["Image"],
                              )));
                },
                child: Container(
                  margin: EdgeInsets.only(right: 20.0, bottom: 20),
                  child: Material(
                    elevation: 5.0,
                    borderRadius: BorderRadius.circular(20.0),
                    child: Container(
                      padding: EdgeInsets.all(5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(
                              ds["Image"],
                              width: 120.0,
                              height: 120.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(
                            width: 20.0,
                          ),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.only(top: 20),
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  ds["Name"],
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  ds["Detail"],
                                  style: AppWidget.lightTextFieldStyle(),
                                  maxLines: 1, // Chỉ hiển thị tối đa 1 dòng
                                  overflow: TextOverflow
                                      .ellipsis, // Thay phần vượt quá bằng dấu "..."
                                ),
                              ),
                              SizedBox(
                                height: 5.0,
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width / 2,
                                child: Text(
                                  // "\$" + ds["Price"],
                                  ds["Price"] + " " + " VNĐ",
                                  style: AppWidget.semiBoldTextFieldStyle(),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text("Lỗi khi tải dữ liệu."),
          );
        } else {
          return Center(
            child: CircularProgressIndicator(),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // _buildBanner1(), // Đặt banner ở trên _buildBody
          Expanded(
              child: _buildBody()), // Đảm bảo _buildBody chiếm hết phần còn lại
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(60), // Đặt chiều cao AppBar
      child: StatefulBuilder(
        builder: (context, setState) {
          return AppBar(
            backgroundColor: Colors.white,
            elevation: 1.0,
            automaticallyImplyLeading: false, // Ẩn nút back
            title: Row(
              children: [
                // Logo lớn hơn và cân đối
                SizedBox(
                  width: 80, // Cố định kích thước logo
                  height: 50,
                  child: Image.asset(
                    'images/logo5.png',
                    fit: BoxFit.cover, // Căn chỉnh hình ảnh trong không gian
                  ),
                ),
                Spacer(),
                Row(
                  children: [
                    // Icon danh sách chứa các nút
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          // Chỉ thay đổi trạng thái khi nhấn vào icon menu
                          isMenuOpen = !isMenuOpen;
                        });
                      },
                      child: Icon(
                        Icons.menu,
                        color: Colors.black,
                        size: 30,
                      ),
                    ),
                    if (isMenuOpen) ...[
                      Row(
                        children: [
                          // Nút đổi theme
                          Consumer<ThemeProvider>(
                            builder: (context, themeProvider, _) {
                              return IconButton(
                                icon: Icon(
                                  themeProvider.isDarkMode
                                      ? Icons.nightlight_round
                                      : Icons.wb_sunny,
                                  color: themeProvider.isDarkMode
                                      ? Colors.yellow
                                      : Colors.black,
                                ),
                                onPressed: () {
                                  themeProvider.toggleTheme();
                                },
                                iconSize: 30,
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          // Dropdown chọn ngôn ngữ
                          DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: currentLanguage,
                              items: const [
                                DropdownMenuItem(
                                  value: "VI",
                                  child: Text(
                                    "VI",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: "EN",
                                  child: Text(
                                    "EN",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                ),
                              ],
                              onChanged: (name) {
                                setState(() {
                                  currentLanguage = name ?? "VI";
                                });
                              },
                              dropdownColor: Colors.white,
                              icon: Icon(
                                Icons.language,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          SizedBox(width: 10),
                          // Nút thông báo
                          IconButton(
                            icon: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(
                                  Icons.notifications,
                                  color: Colors.black,
                                  size: 28,
                                ),
                                Positioned(
                                  right: -6, // Điều chỉnh vị trí badge
                                  top: -6,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: StreamBuilder<QuerySnapshot>(
                                      stream: FirebaseFirestore.instance
                                          .collection('notifications')
                                          .snapshots(),
                                      builder: (context, snapshot) {
                                        if (!snapshot.hasData ||
                                            snapshot.data!.docs.isEmpty) {
                                          return const SizedBox
                                              .shrink(); // Không hiện badge nếu không có thông báo
                                        }
                                        return Text(
                                          '${snapshot.data!.docs.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Thông báo'),
                                        IconButton(
                                          onPressed: () async {
                                            // Xóa tất cả thông báo trong Firebase
                                            final notifications =
                                                await FirebaseFirestore.instance
                                                    .collection('notifications')
                                                    .get();
                                            for (var doc
                                                in notifications.docs) {
                                              await FirebaseFirestore.instance
                                                  .collection('notifications')
                                                  .doc(doc.id)
                                                  .delete();
                                            }
                                            Navigator.pop(
                                                context); // Đóng hộp thoại sau khi xóa
                                          },
                                          icon: const Icon(Icons.delete_forever,
                                              color: Colors.red),
                                          //tooltip: 'Xóa tất cả',
                                        ),
                                      ],
                                    ),
                                    content: Container(
                                      width: double.maxFinite,
                                      child: StreamBuilder<QuerySnapshot>(
                                        stream: FirebaseFirestore.instance
                                            .collection('notifications')
                                            .snapshots(),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return const Center(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }
                                          if (snapshot.hasError) {
                                            return Text(
                                                'Lỗi: ${snapshot.error}');
                                          }
                                          if (!snapshot.hasData ||
                                              snapshot.data!.docs.isEmpty) {
                                            return const Text(
                                                'Không có thông báo nào.');
                                          }
                                          final notifications =
                                              snapshot.data!.docs;
                                          return ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: notifications.length,
                                            itemBuilder: (context, index) {
                                              final doc = notifications[index];
                                              final data = doc.data()
                                                  as Map<String, dynamic>;
                                              return Container(
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8.0),
                                                padding:
                                                    const EdgeInsets.all(12.0),
                                                decoration: BoxDecoration(
                                                  color: Colors.blue[50],
                                                  border: Border.all(
                                                      color: Colors.blue,
                                                      width: 1.0),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.0),
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          data['name'] ??
                                                              'Không có tên',
                                                          style:
                                                              const TextStyle(
                                                            color: Colors.red,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        GestureDetector(
                                                          onTap: () async {
                                                            // Xử lý xóa mã giảm giá trong Firebase
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'notifications')
                                                                .doc(doc.id)
                                                                .delete();
                                                          },
                                                          child: const Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      'Giảm ${data['discount']}%',
                                                      style: const TextStyle(
                                                        color: Colors.black,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    // Text(
                                                    //   'HSD: ${data['expiryDate']}',
                                                    //   style: const TextStyle(
                                                    //     color: Colors.black54,
                                                    //     fontSize: 14,
                                                    //   ),
                                                    // ),
                                                    Text(
                                                      'HSD: ${formatExpiryDate(data['expiryDate'])}',
                                                      style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Text(
                                                      'Số lượng: ${data['quantity']}',
                                                      style: const TextStyle(
                                                        color: Colors.black54,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              );
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Đóng'),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          ),
                          SizedBox(width: 10),
                          // Nút chatbot
                          IconButton(
                            icon: Icon(
                              Icons.chat, // Icon biểu tượng chat
                              color: Colors.blue, // Đổi màu icon chatbot
                              size: 28,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ChatbotScreen(), // Điều hướng đến ChatbotScreen
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBanner1() {
    return Container(
      margin: EdgeInsets.only(
          top: 0.0, left: 0.0, right: 0.0), // Gỡ margin cạnh banner
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBanner(), // Banner thay đổi
          //SizedBox(height: 20.0)
        ],
      ),
    );
  }

  Widget _buildContact() {
    return Column(
      children: [
        // Khung 1: Cần sự hỗ trợ?
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Căn chỉnh các phần tử sang hai bên
            children: [
              // "Cần sự hỗ trợ" text
              Text(
                "Cần sự hỗ trợ?",
                // style: AppWidget.headlineTextFieldStyle().copyWith(
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Số điện thoại (Click to make a call)
              GestureDetector(
                onTap: () {
                  final phoneNumber =
                      "tel:1900 1822"; // Thay thế bằng số điện thoại thực tế
                  launch(phoneNumber); // Mở ứng dụng gọi điện thoại
                },
                child: Text(
                  "1900 1822", // Số điện thoại hiển thị bên phải
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10.0,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment
                .spaceBetween, // Căn chỉnh theo 2 đầu (left and right)
            children: [
              // Text for "Điều khoản điều kiện"
              GestureDetector(
                onTap: () {
                  // Điều hướng đến TermPage khi nhấn vào "Điều khoản điều kiện"
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            TermPage()), // Chuyển đến TermPage
                  );
                },
                child: Text(
                  "Điều khoản & Điều kiện", // Thay đổi văn bản
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                    //decoration: TextDecoration.underline, // Đảm bảo văn bản có gạch dưới
                  ),
                ),
              ),
              // Image on the right side (scaled up and aligned to the right)
              Image.asset(
                'images/bocongthuong.png', // Path to your image file
                width: 60, // Enlarged image width
                height: 60, // Enlarged image height
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildthucdon() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 10), // Khoảng cách trên dưới
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề "TIN TỨC MỚI"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${lang('menusp', 'Thực đơn')} 🍕",
                  // style: AppWidget.headlineTextFieldStyle(),
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color, // Tự động đổi màu
                    // AppWidget.headlineTextFieldStyle(),
                    fontSize: 31,
                    fontWeight: FontWeight.bold, // In đậm
                  ),
                ),
              ],
            ),
          ),
          // Danh sách bài viết có thể kéo ngang
        ],
      ),
    );
  }

  Widget _buildArticles() {
    // Danh sách bài viết mẫu
    final List<Map<String, String>> articles = [
      {
        "title": "TPHCM mua Pizza ngon bổ rẻ...",
        "description": "TPHCM bán Pizza chính hãng uy tín ở...",
        "image": "images/news1.png",
      },
      {
        "title": "Tp.HCM giảm còn 100k...",
        "description": "Giảm 100k cho các đơn hàng ở...",
        "image": "images/news2.png",
      },
      {
        "title": "Mua Pizza trực tuyến tại...",
        "description": "Địa điểm mua Pizza giá tốt tháng 11, 2024 đến...",
        "image": "images/news3.png",
      },
      {
        "title": "Pizza giá tốt nhất tháng...",
        "description": "Pizza giá tốt nhất tháng 11, 2024 new hot đến...",
        "image": "images/news4.png",
      },
    ];

    return Container(
      margin: EdgeInsets.symmetric(vertical: 20.0), // Khoảng cách trên dưới
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề "TIN TỨC MỚI"
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 3.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${lang('news', 'Tin tức')} 🔗",
                  // style: AppWidget.headlineTextFieldStyle(),
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color, // Tự động đổi màu
                    // AppWidget.headlineTextFieldStyle(),
                    fontSize: 30,
                    fontWeight: FontWeight.bold, // In đậm
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    // Điều hướng đến TermPage khi nhấn vào "Điều khoản điều kiện"
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              TermPage()), // Chuyển đến TermPage
                    );
                  },
                  child: Text(
                    "XEM THÊM ➔",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Danh sách bài viết có thể kéo ngang
          Container(
            height: 260, // Chiều cao khung bài viết
            child: ListView.builder(
              scrollDirection: Axis.horizontal, // Cuộn ngang
              itemCount: articles.length, // Số lượng bài viết
              itemBuilder: (context, index) {
                final article = articles[index];
                return Container(
                  width: 200, // Chiều rộng mỗi bài viết
                  margin: EdgeInsets.only(
                      left: index == 0 ? 20.0 : 10.0, right: 10.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8.0,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh bài viết
                      ClipRRect(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(10.0)),
                        child: Image.asset(
                          article["image"] ?? "",
                          width: double.infinity,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tiêu đề bài viết
                            Text(
                              article["title"] ?? "",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 5.0),
                            // Mô tả bài viết
                            Text(
                              article["description"] ?? "",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(height: 10.0),
                            Text(
                              "XEM THÊM ➔",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thêm _buildBanner1() vào đây mà không bị ảnh hưởng bởi margin của _buildBody
          _buildBanner1(),

          // Phần còn lại của _buildBody
          Container(
            margin: EdgeInsets.only(top: 20.0, left: 20.0, right: 5.0),
            // Gỡ margin cạnh banner
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${lang('hello', 'Xin chào')}, ${userName ?? 'User'} 🥰",
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color, // Tự động đổi màu
                    // AppWidget.headlineTextFieldStyle(),
                    fontSize: 30,
                    fontWeight: FontWeight.bold, // In đậm
                  ),
                ),
                Text(
                  "${lang('mess', 'Cảm ơn bạn đã tin tưởng dịch vụ chúng tôi!')}",
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color, // Tự động đổi màu
                    //AppWidget.lightTextFieldStyle().copyWith(fontSize: 17),
                    fontSize: 17,
                  ),
                ),
                SizedBox(height: 20.0),
                _buildthucdon(),
                SizedBox(height: 20.0),
                Container(
                  margin: EdgeInsets.only(right: 20.0),
                  child: showItem(),
                ),
                SizedBox(height: 20.0),
                Container(height: 270, child: allItems()),
                SizedBox(height: 20.0),
                Text(
                  "${lang('sales', 'Ưu đãi khủng')} 🔥",
                  //style: AppWidget.headlineTextFieldStyle(),
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color, // Tự động đổi màu
                    // AppWidget.headlineTextFieldStyle(),
                    fontSize: 30,
                    fontWeight: FontWeight.bold, // In đậm
                  ),
                ),
                // SizedBox(height: 20.0),
                Container(height: 270, child: allItemsVertically()),
                SizedBox(height: 20.0),
                _buildArticles(),
                SizedBox(height: 20.0),
                Text(
                  "${lang('contact', 'Liên hệ với chúng tôi')} 📌",
                  // style: AppWidget.headlineTextFieldStyle(),
                  style: TextStyle(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.color, // Tự động đổi màu
                    // AppWidget.headlineTextFieldStyle(),
                    fontSize: 30,
                    fontWeight: FontWeight.bold, // In đậm
                  ),
                ),
                SizedBox(height: 5.0),
                _buildContact(),
                SizedBox(height: 20.0),
                // _buildPizzaVideos(),
                // SizedBox(height: 20.0),// Khoảng cách giữa các phần tử
                // GestureDetector added here
                // PizzaVideoWidget(
                //   videoUrl: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ', // Thay bằng link video của bạn
                // ),
                // SizedBox(height: 20.0),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
