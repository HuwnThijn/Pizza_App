import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future addUserDetail(Map<String, dynamic> userInfoMap, String id) async {
    return await FirebaseFirestore.instance
        .collection('users')
        .doc(id)
        .set(userInfoMap);
  }

  Future<String> getProductImage(String productId, String cate) async {
    try {
      final docSnapshot =
          await _firestore.collection(cate).doc(productId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data()?['Image'] ?? '';
      } else {
        throw Exception('Sản phẩm không tồn tại!');
      }
    } catch (e) {
      print("Lỗi khi lấy hình ảnh sản phẩm: $e");
      throw e;
    }
  }

  UpdateUserWallet(String id, String amount) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .update({"Wallet": amount});
  }

  Future addFoodItem(Map<String, dynamic> userInfoMap, String name) async {
    return await FirebaseFirestore.instance.collection(name).add(userInfoMap);
  }

  Future<Stream<QuerySnapshot>> getFoodItem(String name) async {
    return await FirebaseFirestore.instance.collection(name).snapshots();
  }

  Future<Stream> searchFoodItem(String query) async {
    return FirebaseFirestore.instance
        .collection('foodItems')
        .where('Name', isGreaterThanOrEqualTo: query)
        .where('Name', isLessThanOrEqualTo: "$query\uf8ff")
        .snapshots();
  }

  // Future addFoodToCart(Map<String, dynamic> userInfoMap, String id) async {
  //   return await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(id)
  //       .collection("Cart")
  //       .add(userInfoMap);
  // }
  Future addFoodToCart(Map<String, dynamic> foodInfoMap, String id) async {
    try {
      // Lấy thông tin từ dữ liệu đầu vào
      String foodName = foodInfoMap["Name"];
      int newQuantity = int.parse(foodInfoMap["Quantity"]);
      int foodPrice = int.parse(foodInfoMap["Total"]);

      // Truy vấn kiểm tra xem sản phẩm đã tồn tại trong giỏ hàng hay chưa
      QuerySnapshot existingFood = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .collection("Cart")
          .where("Name", isEqualTo: foodName)
          .get();

      if (existingFood.docs.isNotEmpty) {
        // Nếu sản phẩm đã tồn tại, cập nhật số lượng và giá
        DocumentSnapshot foodDoc = existingFood.docs.first;
        int existingQuantity = int.parse(foodDoc["Quantity"]);
        int existingTotalPrice = int.parse(foodDoc["Total"]); // Giá hiện tại
        int updatedQuantity = existingQuantity + newQuantity;
        int updatedTotalPrice = existingTotalPrice +
            (existingTotalPrice / existingQuantity).toInt() * (newQuantity);

        // Cập nhật số lượng và giá mới
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .collection("Cart")
            .doc(foodDoc.id)
            .update({
          "Quantity": updatedQuantity.toString(),
          "Total": updatedTotalPrice.toString(),
        });
      } else {
        // Nếu sản phẩm chưa tồn tại, thêm mới và tính giá ban đầu
        foodInfoMap["Total"] =
            (foodPrice).toString(); // Tính tổng giá cho sản phẩm mới
        await FirebaseFirestore.instance
            .collection('users')
            .doc(id)
            .collection("Cart")
            .add(foodInfoMap);
      }
    } catch (e) {
      print("Lỗi khi thêm sản phẩm vào giỏ hàng: $e");
      throw e;
    }
  }

  // Future addFoodToWishList(Map<String, dynamic> userInfoMap, String id) async {
  //   return await FirebaseFirestore.instance
  //       .collection('users')
  //       .doc(id)
  //       .collection("WishList")
  //       .add(userInfoMap);
  // }

  Future addFoodToWishList(
      Map<String, dynamic> userInfoMap, String userId) async {
    try {
      // Lấy tên sản phẩm từ dữ liệu
      String productName = userInfoMap["Name"];

      // Kiểm tra xem sản phẩm đã tồn tại trong danh sách yêu thích chưa
      var existingProduct = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection("WishList")
          .where("Name", isEqualTo: productName)
          .get();

      if (existingProduct.docs.isNotEmpty) {
        // Nếu sản phẩm đã tồn tại, hiển thị thông báo
        return Future.error("Bạn đã yêu thích món này rồi !");
      } else {
        // Nếu sản phẩm chưa tồn tại, thêm sản phẩm vào danh sách
        return await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection("WishList")
            .add(userInfoMap);
      }
    } catch (e) {
      print("Lỗi khi thêm sản phẩm vào danh sách yêu thích: $e");
      return Future.error("Đã xảy ra lỗi khi thêm sản phẩm.");
    }
  }

  Future<Stream<QuerySnapshot>> getFoodCart(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("Cart")
        .snapshots();
  }

  Future<Stream<QuerySnapshot>> getFoodWishList(String id) async {
    return await FirebaseFirestore.instance
        .collection("users")
        .doc(id)
        .collection("WishList")
        .snapshots();
  }

  // new cho order.dart
  Future<void> deleteFoodFromCart(String itemId, String userId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Cart")
        .doc(itemId)
        .delete();
  }

  Future<void> deleteFoodFromWishList(String itemId, String userId) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("WishList")
        .doc(itemId)
        .delete();
  }

  Future<void> updateFoodItem(
      String productId, Map<String, dynamic> foodData, String cate) async {
    try {
      // Truy cập vào collection 'Food' trong Firestore
      final foodRef = _firestore.collection(cate).doc(productId);

      // Cập nhật dữ liệu sản phẩm
      await foodRef.update(foodData);

      print("Sản phẩm đã được cập nhật thành công!");
    } catch (e) {
      print("Lỗi khi cập nhật sản phẩm: $e");
      throw e; // Ném lại lỗi nếu có để có thể xử lý trong UI
    }
  }

  // Hàm lấy thông tin sản phẩm theo ID (để cập nhật)
  Future<Map<String, dynamic>> getProductById(
      String productId, String cate) async {
    try {
      final docSnapshot =
          await _firestore.collection(cate).doc(productId).get();
      if (docSnapshot.exists) {
        return docSnapshot.data() as Map<String, dynamic>;
      } else {
        throw Exception('Sản phẩm không tồn tại!');
      }
    } catch (e) {
      print("Lỗi khi lấy dữ liệu sản phẩm: $e");
      throw e;
    }
  }

  Future<void> updateFoodCart(
      String docId, String userId, int quantity, int price) async {
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Cart")
        .doc(docId)
        .update({
      "Quantity": quantity.toString(),
      "Total": (quantity * price).toString(),
    });
  }

  Future<void> deleteAllItems(String userId) async {
    // Lấy Stream từ Firestore
    var snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(userId)
        .collection("Cart")
        .get(); // Thay vì sử dụng `snapshots()`, dùng `get()` để lấy dữ liệu một lần.

    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        await FirebaseFirestore.instance
            .collection("users")
            .doc(userId)
            .collection("Cart")
            .doc(doc.id)
            .delete();
      }
    }
  }

  Future<void> addPizzaItem(Map<String, dynamic> pizzaData) async {
    try {
      await _firestore.collection("Pizza").add(pizzaData);
      print("Thêm pizza thành công!");
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  Future<void> updatePizzaItem(
      String pizzaId, Map<String, dynamic> pizzaData) async {
    try {
      // Truy cập vào collection "pizzas" và cập nhật document với ID là pizzaId
      await _firestore.collection("Pizza").doc(pizzaId).update(pizzaData);
      print("Cập nhật pizza thành công!");
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  Future<void> deletePizzaItem(String pizzaId) async {
    await FirebaseFirestore.instance.collection('Pizza').doc(pizzaId).delete();
  }

  Future<void> addDrinkItem(Map<String, dynamic> drinkData) async {
    try {
      await _firestore.collection("Drink").add(drinkData);
      print("Thêm đồ uống thành công!");
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  Future<void> updateDrinkItem(
      String drinkId, Map<String, dynamic> drinkData) async {
    try {
      // Truy cập vào collection "pizzas" và cập nhật document với ID là pizzaId
      await _firestore.collection("Drink").doc(drinkId).update(drinkData);
      print("Cập nhật pizza thành công!");
    } catch (e) {
      print("Lỗi: $e");
    }
  }

  Future<void> deleteDrinkItem(String drinkId) async {
    await FirebaseFirestore.instance.collection('Drink').doc(drinkId).delete();
  }
}
