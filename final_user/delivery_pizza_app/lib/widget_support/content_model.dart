class UnboardContent {
  String image;
  String title;
  String decription;
  UnboardContent(
      {required this.image, required this.title, required this.decription});
}

List<UnboardContent> contents = [
  UnboardContent(
      image: 'images/screen1.png',
      title: 'Chọn món ăn yêu thích \n                của bạn',
      decription:
          'Có nhiều loại pizza khác nhau \n      cho bạn tha hồ lựa chọn'),
  UnboardContent(
      image: 'images/screen2.png',
      title: 'Thanh toán dễ dàng',
      decription:
          '    Chấp nhận thanh toán tiền mặt,\nngân hàng và nhiều phương thức khác'),
  UnboardContent(
      image: "images/screen3.png",
      title: "Giao hàng tận nơi",
      decription: "Giao hàng nhanh chóng đến\n                    tận nơi")
];
