import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/TableController/tableController.dart';
import 'package:ameerii/Common/getMenuItems.dart';

// Define your controller (if not already defined)
// class TableController extends GetxController {
//   var isLoading = true.obs;
//   var tables = [].obs;

//   // Mock data for demonstration purposes
//   void loadTables() {
//     isLoading.value = true;
//     Future.delayed(Duration(seconds: 2), () {
//       tables.value = [
//         {'number': 1, 'status': '1'},
//         {'number': 2, 'status': '2'},
//         {'number': 3, 'status': '3'},
//       ];
//       isLoading.value = false;
//     });
//   }
// }

final TableController tableController = Get.put(TableController());

// Define the modal widget
class TableManagementModal extends StatelessWidget {
  final String fromReference_number;

  TableManagementModal({required this.fromReference_number});

  @override
  Widget build(BuildContext context) {
    print('from Reference Number --- ${fromReference_number}');
    // tableController.loadTables(); // Load tables when the modal is opened
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.0),
      height: MediaQuery.of(context).size.height * 0.8,
      width: MediaQuery.of(context).size.width,
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 15.0),
            child: const Text(
              'Select Table number',
              style: TextStyle(
                color: Colors.black,
                fontSize: 19.0,
                fontWeight: FontWeight.w600,
              ),
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
                    var filteredTables = tableController.tables
                        .where((table) => table['status'] == '1')
                        .toList();
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 8.0,
                        mainAxisSpacing: 8.0,
                      ),
                      itemCount: filteredTables.length,
                      itemBuilder: (context, index) {
                        var table = filteredTables[index];

                        return GestureDetector(
                          onTap: () {
                            // Handle the tap on the card
                            tableController.swap_table(
                                fromReference_number, table['reference_id']);
                            Navigator.pop(context);
                          },
                          child: Stack(
                            children: [
                              Card(
                                color: Colors.green,
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
                                      'Vacant',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 17.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
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
    );
  }
}
