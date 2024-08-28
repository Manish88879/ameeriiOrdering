import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/ReportController/models/pie_data.dart';
import 'package:ameerii/Common/controller/ReportController/reportController.dart';
import 'package:ameerii/Common/controller/TableController/tableController.dart';
import 'package:ameerii/Common/getMenuItems.dart';
import 'package:ameerii/Components/navDrawer.dart';
import 'package:intl/intl.dart';

class ReportHome extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();
  final TableController tableController = Get.put(TableController());
  final ChartController chartController = Get.put(ChartController());
  String selectedDate = '';
  DateTimeRange? selectedDateRange;

  Future<bool> _onWillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Are you sure?'),
            content: Text('Do you want to exit the app?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.align_horizontal_left_outlined, // Custom icon
                  color: Colors.white,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
              );
            },
          ),
          backgroundColor: CommonValue.textcolor,
          title: Text(
            'Reports',
            style: TextStyle(color: Colors.white),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: NavDrawer(),
        body: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          thickness: 8.0,
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.0, vertical: 3.0),
              child: Column(
                children: [
                  Card(
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.92,
                      height: 270.0,
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Obx(() {
                        return SfCartesianChart(
                          title: ChartTitle(text: 'Sales Report'),
                          legend: Legend(isVisible: true),
                          series: chartController
                              .series.value, // Use the observable series
                          primaryXAxis: DateTimeAxis(
                            dateFormat: DateFormat.yMd(),
                            intervalType: DateTimeIntervalType.days,
                            title: AxisTitle(text: 'Date'),
                          ),
                          primaryYAxis: NumericAxis(
                            title: AxisTitle(text: 'Total Amount'),
                          ),
                          tooltipBehavior: chartController.tooltipBehavior,
                        );
                      }),
                    ),
                  ),
                  Card(
                      child: Container(
                          width: MediaQuery.of(context).size.width * 0.92,
                          height: 260.0,
                          child: Obx(() {
                            return SfCircularChart(
                              title: ChartTitle(text: 'Daily Sales Report'),
                              legend: Legend(isVisible: true),
                              series: <PieSeries<PieData, String>>[
                                PieSeries<PieData, String>(
                                  explode: true,
                                  explodeIndex: 0,
                                  dataSource: chartController.pieData.value,
                                  xValueMapper: (PieData data, _) => data.xData,
                                  yValueMapper: (PieData data, _) => data.yData,
                                  dataLabelMapper: (PieData data, _) =>
                                      data.text,
                                  dataLabelSettings:
                                      DataLabelSettings(isVisible: true),
                                ),
                              ],
                              tooltipBehavior: chartController.tooltipBehavior,
                            );
                          }))),
                  Card(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          vertical: 20.0, horizontal: 20.0),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 16.0),
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.document_scanner_sharp),
                                    SizedBox(
                                      width: 9.0,
                                    ),
                                    Text(
                                      "Daily Sales Report",
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTimeRange? picked =
                                        await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null &&
                                        picked != selectedDateRange) {
                                      //print("DateTime: $picked");
                                      chartController.Print_Report_DSR(
                                          picked.start.toString().split(' ')[0],
                                          picked.end.toString().split(' ')[0]);
                                      // setState(() {
                                      //   selectedDateRange = picked;
                                      // });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CommonValue
                                          .phyloText, // Default color
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 5.0),
                                    child: const Text(
                                      'Export', // Default text
                                      style: TextStyle(
                                          color: Colors.white), // Default style
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 16.0),
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.wallet),
                                    SizedBox(
                                      width: 9.0,
                                    ),
                                    Text(
                                      "Wallet Report",
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTimeRange? picked =
                                        await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null &&
                                        picked != selectedDateRange) {
                                      //print("DateTime: $picked");
                                      chartController.Print_Report_Wallet(
                                          picked.start.toString().split(' ')[0],
                                          picked.end.toString().split(' ')[0]);
                                      // setState(() {
                                      //   selectedDateRange = picked;
                                      // });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CommonValue
                                          .phyloText, // Default color
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 5.0),
                                    child: const Text(
                                      'Export', // Default text
                                      style: TextStyle(
                                          color: Colors.white), // Default style
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12.0, vertical: 16.0),
                            margin: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.shopping_cart),
                                    SizedBox(
                                      width: 9.0,
                                    ),
                                    Text(
                                      "Item Sale Report",
                                      style: TextStyle(
                                          fontSize: 15.0,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    final DateTimeRange? picked =
                                        await showDateRangePicker(
                                      context: context,
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime(2101),
                                    );
                                    if (picked != null &&
                                        picked != selectedDateRange) {
                                      //print("DateTime: $picked");
                                      chartController.Print_Report_ItemSale(
                                          picked.start.toString().split(' ')[0],
                                          picked.end.toString().split(' ')[0]);
                                      // setState(() {
                                      //   selectedDateRange = picked;
                                      // });
                                    }
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: CommonValue
                                          .phyloText, // Default color
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0, vertical: 5.0),
                                    child: const Text(
                                      'Export', // Default text
                                      style: TextStyle(
                                          color: Colors.white), // Default style
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SalesDataG {
  SalesDataG(this.year, this.sales);
  final String year;
  final double sales;
}

class _PieData {
  _PieData(this.xData, this.yData, [this.text]);
  final String xData;
  final num yData;
  String? text;
}
