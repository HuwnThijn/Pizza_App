import 'package:delivery_pizza_app/pages/detail_pizza.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'details.dart';
import 'package:delivery_pizza_app/service/database.dart';
import 'package:diacritic/diacritic.dart'; // Thư viện loại bỏ dấu khi tìm chữ

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController searchController = TextEditingController();
  List<QueryDocumentSnapshot> searchResults = [];
  bool isLoading = false;

  void searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Chuyển query về chữ thường để tìm kiếm không phân biệt hoa thường
    String lowerCaseQuery = query.toLowerCase();
    String normalizedQuery =
        removeDiacritics(lowerCaseQuery); // Chuẩn hóa chuỗi tìm kiếm

    // Danh sách các collections cần tìm kiếm
    List<String> collections = ['Pizza', 'Burger', 'Chicken', 'Combo', 'Coke'];

    List<QueryDocumentSnapshot> allResults = [];

    for (String collection in collections) {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection(collection).get();

      // Lọc kết quả theo query, so sánh không phân biệt chữ hoa chữ thường
      List<QueryDocumentSnapshot> filteredResults = snapshot.docs.where((doc) {
        String name = doc['Name'].toString().toLowerCase();
        return name.contains(lowerCaseQuery);
        // String searchKey = doc['searchKey'] ?? '';
        // return searchKey.contains(normalizedQuery); // So sánh với trường `searchKey`
      }).toList();

      allResults.addAll(filteredResults);
    }

    setState(() {
      searchResults = allResults;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: 'Vui lòng nhập tên sản phẩm ...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white, fontSize: 18),
          onChanged: (value) {
            searchProducts(value);
          },
          // onSubmitted: (value) {
          //   // Khi Enter, gửi kết quả tìm kiếm lại store.dart
          //   Navigator.pop(context, value);
          // },
          onSubmitted: (value) {
            // Khi Enter, gửi danh sách sản phẩm tìm kiếm lại store.dart
            Navigator.pop(context, searchResults);
          },
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                var product = searchResults[index];
                return ListTile(
                  leading: Image.network(product['Image'], width: 50),
                  title: Text(product['Name']),
                  // subtitle: Text("\$${product['Price']}"),
                  subtitle: Text("${product['Price']} VNĐ"),
                  onTap: () {
                    // Chuyển đến trang chi tiết sản phẩm
                    String currentCollection = product.reference.parent.id;

                    // Navigate based on collection type
                    if (currentCollection == "Pizza") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DetailPizza(
                            detail: product["Detail"],
                            name: product["Name"],
                            price: product["Price"],
                            image: product["Image"],
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Details(
                            detail: product["Detail"],
                            name: product["Name"],
                            price: product["Price"],
                            image: product["Image"],
                          ),
                        ),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
