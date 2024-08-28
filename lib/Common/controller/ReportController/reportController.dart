import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mosambee_aar/flutter_mosambee_aar.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ameerii/Common/APIUrls.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/ReportController/sales_data.dart';
import 'models/pie_data.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChartController extends GetxController {
  late TooltipBehavior tooltipBehavior;
  RxList<SalesDataChart1> salesDataList = <SalesDataChart1>[].obs;
  RxList<PieData> pieData = <PieData>[].obs;
  var selectedDate = ''.obs;
  RxList<AreaSeries<SalesDataChart1, DateTime>> series =
      <AreaSeries<SalesDataChart1, DateTime>>[].obs;
  late String? userId;

  @override
  void onInit() async {
    tooltipBehavior = TooltipBehavior(enable: true);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    userId = prefs.getString('userId');
    super.onInit();
    fetchSalesData().then((data) {
      salesDataList.value = data;
      series.value =
          getDefaultData(); // Update the series with the default data
      updatePieChart(
          salesDataList.length - 1); // Initial Pie Data for latest transaction
    });
  }

  void updateSelectedDate(DateTime date) {
    selectedDate.value = DateFormat('yyyy-MM-dd').format(date);
  }

  Future<List<SalesDataChart1>> fetchSalesData() async {
    final response = await http.get(Uri.parse('${APIUrls.data_report}$userId'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body)['transactions'];
      return data.map((item) {
        return SalesDataChart1(
          DateTime.parse(item['transaction_date']),
          double.tryParse(item['total_amount'].toString()) ?? 0,
          double.tryParse(item['cash'].toString()) ?? 0,
          double.tryParse(item['online'].toString()) ?? 0,
          double.tryParse(item['card'].toString()) ?? 0,
          double.tryParse(item['storecard'].toString()) ?? 0,
        );
      }).toList();
    } else {
      throw Exception('Failed to load data');
    }
  }

  RxList<AreaSeries<SalesDataChart1, DateTime>> getDefaultData() {
    return <AreaSeries<SalesDataChart1, DateTime>>[
      AreaSeries<SalesDataChart1, DateTime>(
        enableTooltip: true,
        dataSource: salesDataList,
        xValueMapper: (SalesDataChart1 sales, _) => sales.year.value,
        yValueMapper: (SalesDataChart1 sales, _) => sales.totalAmount.value,
        color: Color.fromARGB(60, 127, 80, 244),
        borderColor: CommonValue.phyloText,
        markerSettings: MarkerSettings(
          isVisible: true,
          height: 3,
          width: 3,
          shape: DataMarkerType.circle,
          borderWidth: 2,
          borderColor: CommonValue.phyloText,
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: true,
          labelAlignment: ChartDataLabelAlignment.bottom,
        ),
        onPointTap: (ChartPointDetails details) {
          print('Change Pie Chart ------------------- ');
          updatePieChart(details.pointIndex!);
        },
      ),
    ].obs;
  }

  void updatePieChart(int index) {
    if (index >= 0 && index < salesDataList.length) {
      final selectedData = salesDataList[index];
      pieData.value = [
        PieData('Cash', selectedData.cash.value, '${selectedData.cash.value}'),
        PieData('Card', selectedData.card.value, '${selectedData.card.value}'),
        PieData('Store Card', selectedData.storecard.value,
            '${selectedData.storecard.value}'),
        PieData('Online', selectedData.online.value,
            '${selectedData.online.value}'),
      ];
    }
  }

  List<PieData> getPieData() {
    if (salesDataList.isNotEmpty) {
      final latestData = salesDataList.last;
      return [
        PieData('Cash', latestData.cash.value, '${latestData.cash.value}%'),
        PieData('Card', latestData.card.value, '${latestData.card.value}%'),
        PieData('Store Card', latestData.storecard.value,
            '${latestData.storecard.value}%'),
        PieData(
            'Online', latestData.online.value, '${latestData.online.value}%'),
      ];
    }
    return [];
  }

  //*************** DSR REPORT PRINT CODE ***************

  Future<String?> Print_Report_DSR(String startdate, String enddate) async {
    final Uri uri = Uri.parse(
        '${APIUrls.dsr_report_print}$userId&sdate=$startdate&edate=$enddate');
    //print("Start:$startdate  End: $enddate");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        printDSR(response.body, startdate, enddate);
      } else {
        throw Exception('Failed to fetch report: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> printDSR(
      String response, String startdate, String enddate) async {
    try {
      final responseData = await jsonDecode(response);

      var textsizesmall = 25;
      var textsizemedium = 35;

      final SharedPreferences prefs = await SharedPreferences.getInstance();

      FlutterMosambeeAar.initialise(
          APIUrls.mosambeeusername, APIUrls.mosambeepassword);
      FlutterMosambeeAar.setInternalUi(false);
      FlutterMosambeeAar.openPrinter();
      int? state = await FlutterMosambeeAar.getPrinterState();
      // if (kDebugMode) {
      //   print('state: $state');
      // }
      FlutterMosambeeAar.setPrintGray(2000);
      ByteData bytes = await rootBundle.load('images/logo.png');
      var buffer = bytes.buffer;
      var base64Image = base64.encode(Uint8List.view(buffer));

      // if (kDebugMode) {
      //   print("img_pan : $base64Image");
      // }
      FlutterMosambeeAar.printImage(
          base64Image, FlutterMosambeeAar.PRINTLINE_CENTER);
      FlutterMosambeeAar.printText3(prefs.getString('print_line1')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line2')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line3')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line4')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line5')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line6')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line7')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line8')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line9')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line10')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(
          "", FlutterMosambeeAar.PRINTLINE_LEFT, textsizemedium);
      String str2 = "[ DSR Report ]";
      FlutterMosambeeAar.setLineSpace(10);
      FlutterMosambeeAar.printText3(
          str2, FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
      FlutterMosambeeAar.setLineSpace(5);
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      FlutterMosambeeAar.printList("From", "", startdate, textsizesmall, false);
      FlutterMosambeeAar.printList("To", "", enddate, textsizesmall, false);
      FlutterMosambeeAar.printList(
          "Printed On", "", formattedDate, textsizesmall, false);
      FlutterMosambeeAar.printText1(
          "------------------------------------------------------");
      for (var keydata in responseData['data']) {
        if (keydata["heading"]) {
          FlutterMosambeeAar.printList(
              keydata["key"], "", keydata["value"], textsizesmall, true);
        } else {
          FlutterMosambeeAar.printList(
              keydata["key"], "", keydata["value"], textsizesmall, false);
        }
      }
      FlutterMosambeeAar.printText1(
          "------------------------------------------------------");
      FlutterMosambeeAar.printText3("", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

      if (state != null && state == 4) {
        FlutterMosambeeAar.closePrinter();
        return;
      }
      FlutterMosambeeAar.beginPrint();
    } catch (e) {
      Get.snackbar('Print Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  //*************** DSR REPORT PRINT CODE ***************

  Future<String?> Print_Report_Wallet(String startdate, String enddate) async {
    final Uri uri = Uri.parse(
        '${APIUrls.wallet_report_print}$userId&sdate=$startdate&edate=$enddate');
    //print("Start:$startdate  End: $enddate");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        printWallet(response.body, startdate, enddate);
      } else {
        throw Exception('Failed to fetch report: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> printWallet(
      String response, String startdate, String enddate) async {
    try {
      final responseData = await jsonDecode(response);

      var textsizesmall = 25;
      var textsizemedium = 35;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      FlutterMosambeeAar.initialise(
          APIUrls.mosambeeusername, APIUrls.mosambeepassword);
      FlutterMosambeeAar.setInternalUi(false);
      FlutterMosambeeAar.openPrinter();
      int? state = await FlutterMosambeeAar.getPrinterState();
      // if (kDebugMode) {
      //   print('state: $state');
      // }
      FlutterMosambeeAar.setPrintGray(2000);
      ByteData bytes = await rootBundle.load('images/logo.png');
      var buffer = bytes.buffer;
      var base64Image = base64.encode(Uint8List.view(buffer));

      // if (kDebugMode) {
      //   print("img_pan : $base64Image");
      // }
      FlutterMosambeeAar.printImage(
          base64Image, FlutterMosambeeAar.PRINTLINE_CENTER);
      FlutterMosambeeAar.printText3(prefs.getString('print_line1')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line2')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line3')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line4')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line5')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line6')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line7')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line8')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line9')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line10')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(
          "", FlutterMosambeeAar.PRINTLINE_LEFT, textsizemedium);
      String str2 = "[ Wallet Report ]";
      FlutterMosambeeAar.setLineSpace(10);
      FlutterMosambeeAar.printText3(
          str2, FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
      FlutterMosambeeAar.setLineSpace(5);
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      FlutterMosambeeAar.printList("From", "", startdate, textsizesmall, false);
      FlutterMosambeeAar.printList("To", "", enddate, textsizesmall, false);
      FlutterMosambeeAar.printList(
          "Printed On", "", formattedDate, textsizesmall, false);
      FlutterMosambeeAar.printText1(
          "------------------------------------------------------");
      for (var keydata in responseData['data']) {
        if (keydata["heading"]) {
          FlutterMosambeeAar.printList(
              keydata["key"], "", keydata["value"], textsizesmall, true);
        } else {
          FlutterMosambeeAar.printList(
              keydata["key"], "", keydata["value"], textsizesmall, false);
        }
      }
      FlutterMosambeeAar.printText1(
          "------------------------------------------------------");
      FlutterMosambeeAar.printText3("", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

      if (state != null && state == 4) {
        FlutterMosambeeAar.closePrinter();
        return;
      }
      FlutterMosambeeAar.beginPrint();
    } catch (e) {
      Get.snackbar('Print Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  //*************** ITEM SALE REPORT PRINT CODE ***************

  Future<String?> Print_Report_ItemSale(
      String startdate, String enddate) async {
    final Uri uri = Uri.parse(
        '${APIUrls.itemsale_report_print}$userId&sdate=$startdate&edate=$enddate');
    //print("Start:$startdate  End: $enddate");
    final response = await http.get(uri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == true) {
        printItemSale(response.body, startdate, enddate);
      } else {
        throw Exception('Failed to fetch report: ${data['message']}');
      }
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  }

  Future<void> printItemSale(
      String response, String startdate, String enddate) async {
    try {
      final responseData = await jsonDecode(response);

      var textsizesmall = 25;
      var textsizemedium = 35;
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      FlutterMosambeeAar.initialise(
          APIUrls.mosambeeusername, APIUrls.mosambeepassword);
      FlutterMosambeeAar.setInternalUi(false);
      FlutterMosambeeAar.openPrinter();
      int? state = await FlutterMosambeeAar.getPrinterState();
      // if (kDebugMode) {
      //   print('state: $state');
      // }
      FlutterMosambeeAar.setPrintGray(2000);
      ByteData bytes = await rootBundle.load('images/logo.png');
      var buffer = bytes.buffer;
      var base64Image = base64.encode(Uint8List.view(buffer));

      // if (kDebugMode) {
      //   print("img_pan : $base64Image");
      // }
      FlutterMosambeeAar.printImage(
          base64Image, FlutterMosambeeAar.PRINTLINE_CENTER);
      FlutterMosambeeAar.printText3(prefs.getString('print_line1')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line2')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line3')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line4')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line5')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line6')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line7')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line8')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line9')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(prefs.getString('print_line10')!,
          FlutterMosambeeAar.PRINTLINE_CENTER, textsizesmall);
      FlutterMosambeeAar.printText3(
          "", FlutterMosambeeAar.PRINTLINE_LEFT, textsizemedium);
      String str2 = "[ Item Sale Report ]";
      FlutterMosambeeAar.setLineSpace(10);
      FlutterMosambeeAar.printText3(
          str2, FlutterMosambeeAar.PRINTLINE_CENTER, textsizemedium);
      FlutterMosambeeAar.setLineSpace(5);
      DateTime now = DateTime.now();
      String formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(now);
      FlutterMosambeeAar.printList("From", "", startdate, textsizesmall, false);
      FlutterMosambeeAar.printList("To", "", enddate, textsizesmall, false);
      FlutterMosambeeAar.printList(
          "Printed On", "", formattedDate, textsizesmall, false);
      FlutterMosambeeAar.printText1(
          "------------------------------------------------------");
      FlutterMosambeeAar.printList(
          "Product", "", "Quantity", textsizesmall, true);
      FlutterMosambeeAar.printText1(
          "------------------------------------------------------");
      for (var keydata in responseData['data']) {
        FlutterMosambeeAar.printList(
            keydata["key"], "", keydata["value"], textsizesmall, false);
      }
      FlutterMosambeeAar.printText1(
          "------------------------------------------------------");
      FlutterMosambeeAar.printText3("", FlutterMosambeeAar.PRINTLINE_LEFT, 100);

      if (state != null && state == 4) {
        FlutterMosambeeAar.closePrinter();
        return;
      }
      FlutterMosambeeAar.beginPrint();
    } catch (e) {
      Get.snackbar('Print Error', '$e',
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }
}
