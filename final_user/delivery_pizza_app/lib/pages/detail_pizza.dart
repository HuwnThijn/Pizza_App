import 'package:delivery_pizza_app/pages/details.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:delivery_pizza_app/service/shared_pref.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DetailPizza extends StatefulWidget {
  String image, name, detail, price;

  DetailPizza({
    required this.detail,
    required this.image,
    required this.name,
    required this.price,
  });

  @override
  State<DetailPizza> createState() => _DetailPizzaState();
}

class _DetailPizzaState extends State<DetailPizza> {
  int a = 1;
  int total = 0;
  String? id;

  // Selected options
  Map<String, dynamic>? selectedSize;
  Map<String, dynamic>? selectedDe;
  Map<String, dynamic>? selectedVien;

  // Lists to store options from Firebase
  List<Map<String, dynamic>> sizes = [];
  List<Map<String, dynamic>> deOptions = [];
  List<Map<String, dynamic>> vienOptions = [];

  getthesharedpref() async {
    id = await SharedPreferenceHelper().getUserId();
    setState(() {});
  }

  // Fetch options from Firebase
  Future<void> fetchOptions() async {
    // Fetch sizes
    QuerySnapshot sizeSnapshot =
        await FirebaseFirestore.instance.collection('SizeBanh').get();
    sizes = sizeSnapshot.docs
        .map((doc) => {
              'Mota': doc['Mota'],
              'price': doc['price'],
            })
        .toList();

    // Fetch de options
    QuerySnapshot deSnapshot =
        await FirebaseFirestore.instance.collection('DeBanh').get();
    deOptions = deSnapshot.docs
        .map((doc) => {
              'Mota': doc['Mota'],
              'price': doc['price'],
            })
        .toList();

    // Fetch vien options
    QuerySnapshot vienSnapshot =
        await FirebaseFirestore.instance.collection('VienBanh').get();
    vienOptions = vienSnapshot.docs
        .map((doc) => {
              'Mota': doc['Mota'],
              'price': doc['price'],
            })
        .toList();

    setState(() {});
  }

  // Calculate total price
  void calculateTotal() {
    int basePrice = int.parse(widget.price);
    int sizePrice =
        selectedSize != null ? int.parse(selectedSize!['price']) : 0;
    int dePrice = selectedDe != null ? int.parse(selectedDe!['price']) : 0;
    int vienPrice =
        selectedVien != null ? int.parse(selectedVien!['price']) : 0;

    total = (basePrice + sizePrice + dePrice + vienPrice) * a;
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    getthesharedpref();
    fetchOptions();
    total = int.parse(widget.price);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        imageUrl: widget.image,
        onFavoriteTap: () async {
          Map<String, dynamic> addFoodToCart = {
            "Name": widget.name,
            "Price": total.toString(),
            "Image": widget.image,
          };

          try {
            await DatabaseMethods().addFoodToWishList(addFoodToCart, id!);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green,
              content: Text(
                "✔ Đã thêm vào danh mục yêu thích!",
                style: TextStyle(fontSize: 18),
              ),
            ));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.red,
              content: Text(
                e.toString(),
                style: TextStyle(fontSize: 18),
              ),
            ));
          }
        },
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image section
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            widget.image,
                            width: constraints.maxWidth / 1.3,
                            height: 300,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      SizedBox(height: 15),

                      // Quantity control section
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.name,
                              style: AppWidget.semiBoldTextFieldStyle(),
                            ),
                          ),
                          _buildQuantityControl(),
                        ],
                      ),
                      SizedBox(height: 15),

                      // Detail section
                      Text(
                        widget.detail,
                        style: AppWidget.lightTextFieldStyle(),
                        maxLines: 4,
                      ),
                      SizedBox(height: 20),

                      // Time section
                      _buildTimeSection(),
                      SizedBox(height: 15),

                      // Options section
                      _buildOptionsSection(),
                      SizedBox(height: 15),

                      // Total and cart button section
                      //_buildTotalAndCartSection(context),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: EdgeInsets.symmetric(vertical: 1, horizontal: 1),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 0.1, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Tổng tiền:",
                    style: AppWidget.semiBoldTextFieldStyle(),
                  ),
                  Text(
                    "$total VNĐ",
                    style: AppWidget.boldTextFieldStyle()
                        .copyWith(color: Colors.red),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedSize == null ||
                      selectedDe == null ||
                      selectedVien == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: Colors.red,
                      content: Text(
                        "Vui lòng chọn đầy đủ thông tin",
                        style: TextStyle(fontSize: 18),
                      ),
                    ));
                    return;
                  }

                  Map<String, dynamic> addFoodToCart = {
                    "Name": widget.name,
                    "Quantity": a.toString(),
                    "Total": total.toString(),
                    "Image": widget.image,
                    "Size": selectedSize!['Mota'],
                    "De": selectedDe!['Mota'],
                    "Vien": selectedVien!['Mota'],
                  };

                  await DatabaseMethods().addFoodToCart(addFoodToCart, id!);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    backgroundColor: Colors.green,
                    content: Text(
                      "🥰 Đã thêm vào giỏ hàng!",
                      style: TextStyle(fontSize: 18),
                    ),
                  ));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Thêm vào giỏ hàng",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'BalooPaaji2',
                      ),
                    ),
                    SizedBox(width: 10),
                    Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.shopping_cart_outlined,
                        color: Colors.black,
                        size: 20,
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

  Widget _buildQuantityControl() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildControlButton(Icons.remove, () {
          if (a > 1) {
            setState(() {
              --a;
              calculateTotal();
            });
          }
        }),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Text(
            a.toString(),
            style: AppWidget.semiBoldTextFieldStyle(),
          ),
        ),
        _buildControlButton(Icons.add, () {
          setState(() {
            ++a;
            calculateTotal();
          });
        }),
      ],
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _buildTimeSection() {
    return Row(
      children: [
        Text(
          "Thời gian tạo sản phẩm:",
          style: AppWidget.semiBoldTextFieldStyle(),
        ),
        SizedBox(width: 25),
        Icon(Icons.alarm, color: Colors.black54),
        SizedBox(width: 5),
        Text(
          "30 phút",
          style: AppWidget.semiBoldTextFieldStyle(),
        ),
      ],
    );
  }

  Widget _buildOptionsSection() {
    return Column(
      children: [
        _buildOptionRow("Size", sizes, selectedSize, (value) {
          setState(() {
            selectedSize = value;
            calculateTotal();
          });
        }),
        SizedBox(height: 10),
        _buildOptionRow("Đế", deOptions, selectedDe, (value) {
          setState(() {
            selectedDe = value;
            calculateTotal();
          });
        }),
        SizedBox(height: 10),
        _buildOptionRow("Viền", vienOptions, selectedVien, (value) {
          setState(() {
            selectedVien = value;
            calculateTotal();
          });
        }),
      ],
    );
  }

  Widget _buildOptionRow(
    String label,
    List<Map<String, dynamic>> options,
    Map<String, dynamic>? selectedValue,
    Function(Map<String, dynamic>?) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppWidget.semiBoldTextFieldStyle()),
        DropdownButton<Map<String, dynamic>>(
          value: selectedValue,
          hint: Text("Chọn $label"),
          onChanged: onChanged,
          items: options.map<DropdownMenuItem<Map<String, dynamic>>>(
            (Map<String, dynamic> value) {
              return DropdownMenuItem<Map<String, dynamic>>(
                value: value,
                child: Text("${value['Mota']} - ${value['price']} VNĐ "),
              );
            },
          ).toList(),
        ),
      ],
    );
  }

  // Widget _buildTotalAndCartSection(BuildContext context) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //     children: [
  //       Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           Text(
  //             "Tổng tiền:",
  //             style: AppWidget.semiBoldTextFieldStyle(),
  //           ),
  //           Text(
  //             "$total VNĐ",
  //             style: AppWidget.boldTextFieldStyle().copyWith(color: Colors.red),
  //           ),
  //         ],
  //       ),
  //       ElevatedButton(
  //         onPressed: () async {
  //           if (selectedSize == null ||
  //               selectedDe == null ||
  //               selectedVien == null) {
  //             ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //               backgroundColor: Colors.red,
  //               content: Text(
  //                 "Vui lòng chọn đầy đủ thông tin",
  //                 style: TextStyle(fontSize: 18),
  //               ),
  //             ));
  //             return;
  //           }
  //
  //           Map<String, dynamic> addFoodToCart = {
  //             "Name": widget.name,
  //             "Quantity": a.toString(),
  //             "Total": total.toString(),
  //             "Image": widget.image,
  //             "Size": selectedSize!['Mota'],
  //             "De": selectedDe!['Mota'],
  //             "Vien": selectedVien!['Mota'],
  //           };
  //
  //           await DatabaseMethods().addFoodToCart(addFoodToCart, id!);
  //           ScaffoldMessenger.of(context).showSnackBar(SnackBar(
  //             backgroundColor: Colors.green,
  //             content: Text(
  //               "🥰 Đã thêm vào giỏ hàng!",
  //               style: TextStyle(fontSize: 18),
  //             ),
  //           ));
  //         },
  //         style: ElevatedButton.styleFrom(
  //           backgroundColor: Colors.black,
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(10),
  //           ),
  //           padding: EdgeInsets.symmetric(
  //             horizontal: 20,
  //             vertical: 15,
  //           ),
  //         ),
  //         child: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               "Thêm vào giỏ hàng",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 16,
  //                 fontFamily: 'BalooPaaji2',
  //               ),
  //             ),
  //             SizedBox(width: 10),
  //             Container(
  //               padding: EdgeInsets.all(3),
  //               decoration: BoxDecoration(
  //                 color: Colors.grey,
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Icon(
  //                 Icons.shopping_cart_outlined,
  //                 color: Colors.black,
  //                 size: 20,
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ],
  //   );
  // }
}
