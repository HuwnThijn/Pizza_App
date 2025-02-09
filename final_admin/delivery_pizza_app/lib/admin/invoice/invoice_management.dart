import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:delivery_pizza_app/widget_support/widget_support.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class InvoiceManagement extends StatefulWidget {
  const InvoiceManagement({Key? key}) : super(key: key);

  @override
  State<InvoiceManagement> createState() => _InvoiceManagementState();
}

class _InvoiceManagementState extends State<InvoiceManagement> {
  final Stream<QuerySnapshot> _invoicesStream = FirebaseFirestore.instance
      .collection('invoices')
      .orderBy('timestamp', descending: true)
      .snapshots();

  final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  String searchQuery = '';

  void deleteInvoice(String invoiceId) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Xác nhận'),
          content: const Text('📌 Bạn muốn xóa hóa đơn này?'),
          actions: [
            TextButton(
              child:
                  const Text('Hủy', style: TextStyle(color: Colors.blueAccent)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
              onPressed: () async {
                await FirebaseFirestore.instance
                    .collection('invoices')
                    .doc(invoiceId)
                    .delete();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('🥰 Xóa hóa đơn thành công',
                        style: TextStyle(fontSize: 18, color: Colors.white)),
                    backgroundColor: Colors.green,
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Widget buildInvoiceTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: _invoicesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  '👀 Không có hóa đơn nào',
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        final invoices = snapshot.data!.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final searchString =
              '${doc.id} ${data['customerName']} ${data['email']}'
                  .toLowerCase();
          return searchString.contains(searchQuery.toLowerCase());
        }).toList();

        return Card(
          elevation: 2,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              headingRowColor: MaterialStateProperty.all(Colors.blueAccent),
              columns: const [
                DataColumn(
                  label: Text(
                    'Mã hóa đơn',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tên khách hàng',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Email',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Tổng tiền',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Trạng thái',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Ngày tạo',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
                DataColumn(
                  label: Text(
                    'Hành động',
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
              rows: invoices.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final timestamp = data['timestamp'];
                DateTime? createdDate;

                if (timestamp is Timestamp) {
                  createdDate = timestamp.toDate();
                } else if (timestamp is String) {
                  createdDate = DateTime.tryParse(timestamp);
                }

                String formattedDate = createdDate != null
                    ? DateFormat('dd/MM/yyyy HH:mm').format(createdDate)
                    : 'Không xác định';

                return DataRow(
                  cells: [
                    DataCell(
                      SizedBox(
                        width: 120, // Cố định độ rộng của cột Mã hóa đơn
                        child: Text(doc.id),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 200, // Cố định độ rộng của cột Tên khách hàng
                        child: Text(data['customerName'] ?? ''),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 250, // Cố định độ rộng của cột Email
                        child: Text(data['email'] ?? ''),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 150, // Cố định độ rộng của cột Tổng tiền
                        child: Text(
                          currencyFormatter.format(
                            double.tryParse(data['totalPrice'].toString()) ?? 0,
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 130, // Cố định độ rộng của cột Trạng thái
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(data['status'] ?? '')
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            data['status'] ?? '',
                            style: TextStyle(
                              color: _getStatusColor(data['status'] ?? ''),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                    DataCell(
                      SizedBox(
                        width: 160, // Cố định độ rộng của cột Ngày tạo
                        child: Text(formattedDate),
                      ),
                    ),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => deleteInvoice(doc.id),
                            tooltip: 'Xóa hóa đơn',
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Đã thanh toán':
        return Colors.green;
      case 'Chưa thanh toán':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true, // Đưa tiêu đề ra giữa
        title: Text(
          'QUẢN LÝ HÓA ĐƠN',
          style: TextStyle(
            color: Colors.red,
            fontSize: 30.0,
            fontWeight: FontWeight.bold,
            fontFamily: 'BalooPaaji2',
          ),
        ),
        elevation: 0,
      ),
      // body: Container(
      //   color: Colors.grey[100],
      //   child: Padding(
      //     padding: const EdgeInsets.all(16.0),
      //     child: Column(
      //       crossAxisAlignment: CrossAxisAlignment.start,
      //       children: [
      //         Card(
      //           child: Padding(
      //             padding: const EdgeInsets.all(16.0),
      //             child: Column(
      //               crossAxisAlignment: CrossAxisAlignment.start,
      //               children: [
      //                 const Text(
      //                   'Danh sách hóa đơn',
      //                   style: TextStyle(
      //                     fontSize: 20,
      //                     fontWeight: FontWeight.bold,
      //                   ),
      //                 ),
      //                 const SizedBox(height: 16),
      //                 TextField(
      //                   decoration: InputDecoration(
      //                     hintText: 'Tìm kiếm hóa đơn...',
      //                     prefixIcon: const Icon(Icons.search),
      //                     border: OutlineInputBorder(
      //                       borderRadius: BorderRadius.circular(8),
      //                     ),
      //                     contentPadding: const EdgeInsets.symmetric(
      //                       horizontal: 16,
      //                       vertical: 12,
      //                     ),
      //                   ),
      //                   onChanged: (value) {
      //                     setState(() {
      //                       searchQuery = value;
      //                     });
      //                   },
      //                 ),
      //               ],
      //             ),
      //           ),
      //         ),
      //         const SizedBox(height: 16),
      //         Expanded(child: buildInvoiceTable()),
      //       ],
      //     ),
      //   ),
      // ),
      body: Container(
        color: Colors.grey[100],
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // const Text(
                      //   'Danh sách hóa đơn',
                      //   style: TextStyle(
                      //     fontSize: 20,
                      //     fontWeight: FontWeight.bold,
                      //   ),
                      // ),
                      const SizedBox(height: 16),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Tìm kiếm hóa đơn...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              buildInvoiceTable(), // Thêm bảng vào đây, không dùng Expanded
            ],
          ),
        ),
      ),
    );
  }
}
