import 'package:get/get.dart';
import 'package:ameerii/Pages/CardManagement/addCard.dart';
import 'package:ameerii/Pages/CardManagement/addMoney.dart';
import 'package:ameerii/Pages/CardManagement/cardDetails.dart';
import 'package:ameerii/Pages/CardManagement/cardHome.dart';
import 'package:ameerii/Pages/CardManagement/transactionHistory.dart';
import 'package:ameerii/Pages/CardManagement/transferCard.dart';
import 'package:ameerii/Pages/QuickOrder/cart.dart';
import 'package:ameerii/Pages/QuickOrder/quickOrderHome.dart';
import 'package:ameerii/Pages/ReportManagement/reportHome.dart';
import 'package:ameerii/Pages/TableManagement/addItems.dart';
import 'package:ameerii/Pages/TableManagement/billingPage.dart';
import 'package:ameerii/Pages/TableManagement/couponPage.dart';
import 'package:ameerii/Pages/TableManagement/tableHome.dart';
import 'package:ameerii/Pages/TableManagement/yourOrders.dart';
import 'package:ameerii/Pages/loginPage.dart';
import 'package:ameerii/Pages/splashScreen.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.SPLASH,
      page: () => SplashScreen(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginPage(),
    ),
    GetPage(
      name: _Paths.CARDDETAIL,
      page: () => CardDetails(),
    ),
    GetPage(
      name: _Paths.CARDHOME,
      page: () => const CardHome(),
    ),
    GetPage(
      name: _Paths.ADDMONEY,
      page: () => AddMoney(),
    ),
    GetPage(
      name: _Paths.TXNHISTORY,
      page: () => TxnHistory(),
    ),
    GetPage(
      name: _Paths.TRANSFERCARD,
      page: () => TransferCard(),
    ),
    GetPage(
      name: _Paths.QUICKORDER,
      page: () => QuickOrderHome(),
    ),
    GetPage(name: _Paths.ADDCARD, page: () => AddCard()),
    GetPage(
      name: _Paths.CART,
      page: () => Cart(),
    ),
    GetPage(
      name: _Paths.TABLEHOME,
      page: () => TableHome(),
    ),
    GetPage(
      name: _Paths.ADDORDER,
      page: () => AddOrder(),
    ),
    GetPage(
      name: _Paths.REPORTHOME,
      page: () => ReportHome(),
    ),
    GetPage(
      name: _Paths.BILLING,
      page: () => Billing(),
    ),
    GetPage(
      name: _Paths.YOURORDERS,
      page: () => YourOrders(),
    ),
    GetPage(
      name: _Paths.COUPONPAGE,
      page: () => CouponPage(),
    ),
  ];
}
