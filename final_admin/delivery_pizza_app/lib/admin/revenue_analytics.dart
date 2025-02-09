import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

class RevenueManagement extends StatefulWidget {
  const RevenueManagement({super.key});

  @override
  State<RevenueManagement> createState() => _RevenueManagementState();
}

class _RevenueManagementState extends State<RevenueManagement> {
  String selectedPeriod = 'Tháng';
  List<FlSpot> revenueSpots = [];
  double maxY = 0;
  double totalRevenue = 0;
  int totalOrders = 0;
  double averageOrderValue = 0;
  List<String> dateLabels = [];

  final currencyFormatter = NumberFormat.currency(
    locale: 'vi_VN',
    symbol: '₫',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    loadRevenueData();
  }

  Future<void> loadRevenueData() async {
    QuerySnapshot invoiceSnapshot = await FirebaseFirestore.instance
        .collection('invoices')
        .where('status', isEqualTo: 'Đã thanh toán')
        .orderBy('timestamp', descending: false)
        .get();

    Map<String, double> revenueMap = {};
    dateLabels = [];
    totalRevenue = 0;
    totalOrders = invoiceSnapshot.docs.length;

    for (var doc in invoiceSnapshot.docs) {
      String timestamp = doc['timestamp'];
      double revenue = double.parse(doc['totalPrice']);
      DateTime date = DateTime.parse(timestamp);

      String key = '';
      String label = '';
      switch (selectedPeriod) {
        case 'Ngày':
          key = DateFormat('yyyy-MM-dd').format(date);
          label = DateFormat('dd/MM').format(date);
          break;
        case 'Tuần':
          key = '${date.year}-W${(date.day + date.weekday - 1) ~/ 7 + 1}';
          label = 'Tuần ${(date.day + date.weekday - 1) ~/ 7 + 1}';
          break;
        case 'Tháng':
          key = DateFormat('yyyy-MM').format(date);
          label = DateFormat('MM/yyyy').format(date);
          break;
      }

      if (!revenueMap.containsKey(key)) {
        dateLabels.add(label);
      }
      revenueMap[key] = (revenueMap[key] ?? 0) + revenue;
      totalRevenue += revenue;
    }

    averageOrderValue = totalOrders > 0 ? totalRevenue / totalOrders : 0;

    revenueSpots = revenueMap.entries
        .mapIndexed((index, entry) => FlSpot(index.toDouble(), entry.value))
        .toList();

    // Set a minimum value for maxY to avoid the zero interval error
    maxY = revenueMap.isEmpty
        ? 1000
        : revenueMap.values.reduce((max, value) => max > value ? max : value);
    if (maxY <= 0) maxY = 1000; // Ensure maxY is always positive

    setState(() {});
  }

  String formatCompactCurrency(double value) {
    if (value >= 1000000000) {
      return '${(value / 1000000000).toStringAsFixed(1)}B';
    } else if (value >= 1000000) {
      return '${(value / 1000000).toStringAsFixed(1)}M';
    } else if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(1)}K';
    }
    return value.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    final double interval = maxY > 5 ? maxY / 5 : 1;
    final double bottomInterval = revenueSpots.isEmpty ? 1 : 1;
    return Scaffold(
      // appBar: AppBar(
      //   toolbarHeight: 120, // Chiều cao của AppBarr
      //   elevation: 2.0,
      //   centerTitle: true, // Đưa tiêu đề ra giữa
      //   title: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       const Text(
      //         'Quản lý doanh thu',
      //         style: TextStyle(
      //           fontSize: 24,
      //           fontWeight: FontWeight.bold,
      //         ),
      //       ),
      //       DropdownButton<String>(
      //         value: selectedPeriod,
      //         items: ['Ngày', 'Tuần', 'Tháng'].map((String value) {
      //           return DropdownMenuItem<String>(
      //             value: value,
      //             child: Text(value),
      //           );
      //         }).toList(),
      //         onChanged: (String? newValue) {
      //           if (newValue != null) {
      //             setState(() {
      //               selectedPeriod = newValue;
      //               loadRevenueData();
      //             });
      //           }
      //         },
      //       ),
      //     ],
      //   ),
      // ),
      appBar: AppBar(
        toolbarHeight: 100, // Chiều cao của AppBar
        elevation: 2.0,
        titleSpacing: 0, // Xóa khoảng cách mặc định của title
        centerTitle: true, // Căn giữa title theo chiều ngang
        title: Stack(
          children: [
            const Center(
              // Căn giữa văn bản "Quản lý doanh thu"
              child: Text(
                'QUẢN LÝ DOANH THU',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
            Positioned(
              // Đặt DropdownButton ở góc phải
              right: 0,
              top: 0,
              bottom: 0,
              child: DropdownButton<String>(
                value: selectedPeriod,
                items: ['Ngày', 'Tuần', 'Tháng'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: const TextStyle(
                        fontSize: 23, // Tăng kích thước chữ
                        fontWeight: FontWeight.bold, // Chữ in đậm
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedPeriod = newValue;
                      loadRevenueData();
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),

      body: Container(
        padding: const EdgeInsets.only(top: 1.0),
        child: Column(
          children: [
            // Material(
            //   elevation: 2.0,
            //   child: Container(
            //     padding: const EdgeInsets.only(bottom: 10.0),
            //     child: Container(
            //       margin: const EdgeInsets.symmetric(horizontal: 20),
            //       child: Row(
            //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //         children: [
            //           const Text(
            //             'Quản lý doanh thu',
            //             style: TextStyle(
            //               fontSize: 24,
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //           DropdownButton<String>(
            //             value: selectedPeriod,
            //             items: ['Ngày', 'Tuần', 'Tháng'].map((String value) {
            //               return DropdownMenuItem<String>(
            //                 value: value,
            //                 child: Text(value),
            //               );
            //             }).toList(),
            //             onChanged: (String? newValue) {
            //               if (newValue != null) {
            //                 setState(() {
            //                   selectedPeriod = newValue;
            //                   loadRevenueData();
            //                 });
            //               }
            //             },
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildSummaryCard(
                    'Tổng doanh thu',
                    currencyFormatter.format(totalRevenue),
                    Colors.blue,
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryCard(
                    'Tổng đơn hàng',
                    NumberFormat('#,###').format(totalOrders),
                    Colors.green,
                  ),
                  const SizedBox(height: 10),
                  _buildSummaryCard(
                    'Trung bình/đơn',
                    currencyFormatter.format(averageOrderValue),
                    Colors.orange,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(20),
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: true,
                      horizontalInterval: interval,
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 60,
                          interval: interval,
                          getTitlesWidget: (value, meta) {
                            return Text(
                              formatCompactCurrency(value),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: bottomInterval,
                          getTitlesWidget: (value, meta) {
                            if (value >= 0 && value < dateLabels.length) {
                              return Transform.rotate(
                                angle: 0, // Góc xoay -30 độ
                                child: Container(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    dateLabels[value.toInt()],
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              );
                            }
                            return const SizedBox();
                          },
                        ),
                      ),
                      rightTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(
                      show: true,
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    minX: 0,
                    maxX: revenueSpots.length.toDouble() - 1,
                    minY: 0,
                    maxY: maxY * 1.2,
                    lineBarsData: [
                      LineChartBarData(
                        spots: revenueSpots,
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        isStrokeCapRound: true,
                        dotData: FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, barData, index) {
                            return FlDotCirclePainter(
                              radius: 4,
                              color: Colors.white,
                              strokeWidth: 2,
                              strokeColor: Colors.blue,
                            );
                          },
                        ),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, Color color) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 4,
        child: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) f) {
    var index = 0;
    return map((e) => f(index++, e));
  }
}
