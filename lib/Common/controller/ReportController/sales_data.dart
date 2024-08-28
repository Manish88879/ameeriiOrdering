import 'package:get/get.dart';

class SalesData {
  final DateTime year;
  final String country;
  final double sales;
  final double y;
  final double y3;
  final double y4;
  final double y5;
  SalesData(
      this.year, this.country, this.sales, this.y, this.y3, this.y4, this.y5);
}

class SalesDataChart1 {
  final Rx<DateTime> year;
  final RxDouble totalAmount;
  final RxDouble cash;
  final RxDouble online;
  final RxDouble card;
  final RxDouble storecard;

  SalesDataChart1(
    DateTime year,
    double totalAmount,
    double cash,
    double online,
    double card,
    double storecard,
  )   : year = Rx<DateTime>(year),
        totalAmount = RxDouble(totalAmount),
        cash = RxDouble(cash),
        online = RxDouble(online),
        card = RxDouble(card),
        storecard = RxDouble(storecard);
}
