import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/TableController/tableController.dart';
import 'package:ameerii/Common/getMenuItems.dart';
import 'package:ameerii/Components/navDrawer.dart';
import 'package:ameerii/Routes/app_pages.dart';

class TableHome extends StatelessWidget {
  TableHome({super.key});

  final TableController tableController = Get.put(TableController());

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
    Future<void> _refresh() async {
      // Simulate a network call or any other refresh logic
      await Future.delayed(Duration(seconds: 2));
      // After the refresh is complete, you can update the UI or perform any other necessary actions
      tableController.fetchTables();
    }

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Colors.transparent, // Transparent status bar
    ));
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Table Management',
            style: TextStyle(color: Colors.white),
          ),
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
          iconTheme: IconThemeData(color: Colors.white),
        ),
        drawer: NavDrawer(),
        body: RefreshIndicator(
          onRefresh: _refresh,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.0),
            height: MediaQuery.sizeOf(context).height,
            width: MediaQuery.sizeOf(context).width,
            child: Column(
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 7.0),
                  child: Text(
                    'Welcome to Table Management',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 19.0,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                Expanded(
                  child: Obx(() {
                    if (tableController.isLoading.value) {
                      return Center(child: CircularProgressIndicator());
                    } else if (tableController.tables.isEmpty) {
                      return Center(child: Text('No tables available'));
                    } else {
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          // Determine the number of columns based on the screen width
                          int columns = constraints.maxWidth > 600 ? 4 : 2;

                          return GridView.builder(
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: columns,
                              crossAxisSpacing: 8.0,
                              mainAxisSpacing: 8.0,
                            ),
                            itemCount: tableController.tables.length,
                            itemBuilder: (context, index) {
                              var table = tableController.tables[index];
                              return GestureDetector(
                                onTap: () {
                                  if (table['status'] == '1') {
                                    Get.toNamed(Routes.ADDORDER, arguments: {
                                      'table_number': table["id"],
                                      'reference_id': table['reference_id']
                                    });
                                  } else {
                                    // Show the dialog
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text(
                                            'Table - ${table['number']}',
                                            style: TextStyle(
                                                color: Colors.blueGrey,
                                                fontWeight: FontWeight.w800),
                                          ),
                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children:
                                                  getMenuItems(table, context),
                                            ),
                                          ),
                                          actions: [
                                            TextButton(
                                              child: Text('Close'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }
                                },
                                child: Card(
                                  color: table['status'] == '1'
                                      ? Colors.green
                                      : table['status'] == '2'
                                          ? Colors.red
                                          : Colors.amber[700],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 4,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Text(
                                          '${table['number']}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 32.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 3.0),
                                      Text(
                                        table['status'] == '1'
                                            ? 'Vacant'
                                            : table['status'] == '2'
                                                ? 'Booked'
                                                : 'Billed',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 17.0,
                                          fontWeight: FontWeight.w500,
                                        ),
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
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
