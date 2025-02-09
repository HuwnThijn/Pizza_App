import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'add_coupon.dart';
import 'edit_coupon.dart';

class CouponList extends StatefulWidget {
  const CouponList({Key? key}) : super(key: key);

  @override
  State<CouponList> createState() => _CouponListState();
}

class _CouponListState extends State<CouponList> {
  final Stream<QuerySnapshot> _couponsStream =
      FirebaseFirestore.instance.collection('coupons').snapshots();

  String formatExpiryDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final DateTime date = DateTime.parse(dateStr);
      return DateFormat('dd/MM/y').format(date);
    } catch (e) {
      return dateStr; // Trả về chuỗi gốc nếu không parse được
    }
  }

  void deleteCoupon(String couponId) async {
    await FirebaseFirestore.instance
        .collection('coupons')
        .doc(couponId)
        .delete();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      content: Text(
        "🥰 Xóa mã giảm giá thành công",
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ));
  }

  Widget buildCouponList(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _couponsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/empty.png', height: 120),
                const SizedBox(height: 16),
                Text(
                  '👀 Không có mã giảm giá nào',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ],
            ),
          );
        }

        final coupons = snapshot.data!.docs;

        return ListView.builder(
          itemCount: coupons.length,
          itemBuilder: (context, index) {
            final doc = coupons[index];
            final data = doc.data() as Map<String, dynamic>;
            final categories = data['categories'] as List<dynamic>? ?? [];
            final String formattedDate = formatExpiryDate(data['expiryDate']);
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300, width: 1),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Chứa thông tin chính
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data['name'] ?? '',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              color: Colors.red,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Giảm: ${data['discount']}%',
                            style: TextStyle(
                              fontSize: 20,
                              color: Colors.black,
                            ),
                          ),
                          // const SizedBox(height: 4),
                          // Text(
                          //   'Còn lại: ${data['quantity']} lần',
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),
                          // const SizedBox(height: 4),
                          Text(
                            'Hạn sử dụng: $formattedDate',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          // const SizedBox(height: 4),
                          // Text(
                          //   categories.isEmpty
                          //       ? 'Áp dụng cho tất cả sản phẩm'
                          //       : 'Sản phẩm áp dụng: ${categories.join(', ')}',
                          //   style: TextStyle(
                          //     fontSize: 14,
                          //     color: Colors.grey[600],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // Chứa các hành động: Edit, Delete
                    Column(
                      children: [
                        IconButton(
                          icon:
                              const Icon(Icons.edit, color: Colors.blueAccent),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    EditCoupon(couponId: doc.id),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận'),
                              content:
                                  const Text('Bạn muốn xóa mã giảm giá này?'),
                              actions: [
                                TextButton(
                                  child: const Text('Hủy'),
                                  onPressed: () => Navigator.pop(context),
                                ),
                                TextButton(
                                  child: const Text(
                                    'Xóa',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                  onPressed: () {
                                    deleteCoupon(doc.id);
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(color: Colors.white),
        elevation: 1,
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
        title: const Text(
          'QUẢN LÝ MÃ GIẢM GIÁ',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddCoupon(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: buildCouponList(context),
      ),
    );
  }
}
