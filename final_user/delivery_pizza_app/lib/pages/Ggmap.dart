import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Ggmap extends StatefulWidget {
  @override
  _GgmapState createState() => _GgmapState();
}

class _GgmapState extends State<Ggmap> {
  late GoogleMapController mapController;

  // Vị trí ban đầu của bản đồ
  final LatLng _initialPosition = const LatLng(10.7769, 106.7009); // Ví dụ: HCM City

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //automaticallyImplyLeading: true,
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Quay lại màn hình trước đó
          },
        ),
        title: Image.asset(
          'images/logo5.png', // Đường dẫn đến hình ảnh logo
          height: 40, // Chiều cao của logo
        ),
        centerTitle: true,
      ),
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: _initialPosition,
          zoom: 14.0,
        ),
        mapType: MapType.normal,
        onMapCreated: (GoogleMapController controller) {
          mapController = controller;
        },
        markers: {
          Marker(
            markerId: MarkerId("order_location"),
            position: _initialPosition,
            infoWindow: InfoWindow(
              title: "Vị trí của bạn",
              snippet: "Theo dõi đơn hàng",
            ),
          ),
        },
      ),
    );
  }
}
