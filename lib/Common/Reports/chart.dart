import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../controller/ReportController/sales_data.dart'; // Import the SalesData class

void main() {
  runApp(MyChartApp());
}

class MyChartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Chart Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Flutter Chart Example'),
        ),
        body: ChartWidget(),
      ),
    );
  }
}

class ChartWidget extends StatefulWidget {
  @override
  _ChartWidgetState createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SfCartesianChart(
        title: ChartTitle(text: 'Sales Report'),
        legend: Legend(isVisible: true),
        series: getDefaultData(),
        tooltipBehavior: _tooltipBehavior,
      ),
    );
  }

  static List<LineSeries<SalesData, num>> getDefaultData() {
    final bool isDataLabelVisible = true,
        isMarkerVisible = true,
        isTooltipVisible = true;
    double? lineWidth, markerWidth, markerHeight;
    final List<SalesData> chartData = <SalesData>[
      SalesData(DateTime(2005, 1, 1), 'India', 1.5, 21, 28, 680, 760),
      SalesData(DateTime(2006, 1, 1), 'China', 2.2, 24, 44, 550, 880),
      SalesData(DateTime(2007, 1, 1), 'USA', 3.32, 36, 48, 440, 788),
      SalesData(DateTime(2008, 1, 1), 'Japan', 4.56, 38, 50, 350, 560),
      SalesData(DateTime(2009, 1, 1), 'Russia', 5.87, 54, 66, 444, 566),
      SalesData(DateTime(2010, 1, 1), 'France', 6.8, 57, 78, 780, 650),
      SalesData(DateTime(2011, 1, 1), 'Germany', 8.5, 70, 84, 450, 800),
    ];
    return <LineSeries<SalesData, num>>[
      LineSeries<SalesData, num>(
        enableTooltip: true,
        dataSource: chartData,
        xValueMapper: (SalesData sales, _) => sales.y,
        yValueMapper: (SalesData sales, _) => sales.y4,
        width: lineWidth ?? 2,
        markerSettings: MarkerSettings(
          isVisible: isMarkerVisible,
          height: markerWidth ?? 4,
          width: markerHeight ?? 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          borderColor: Colors.red,
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: isDataLabelVisible,
          labelAlignment: ChartDataLabelAlignment.auto,
        ),
      ),
      LineSeries<SalesData, num>(
        enableTooltip: isTooltipVisible,
        dataSource: chartData,
        width: lineWidth ?? 2,
        xValueMapper: (SalesData sales, _) => sales.y,
        yValueMapper: (SalesData sales, _) => sales.y3,
        markerSettings: MarkerSettings(
          isVisible: isMarkerVisible,
          height: markerWidth ?? 4,
          width: markerHeight ?? 4,
          shape: DataMarkerType.circle,
          borderWidth: 3,
          borderColor: Colors.black,
        ),
        dataLabelSettings: DataLabelSettings(
          isVisible: isDataLabelVisible,
          labelAlignment: ChartDataLabelAlignment.auto,
        ),
      ),
    ];
  }
}
