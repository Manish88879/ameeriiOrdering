import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';

void showCustomModalBottomSheet(BuildContext context) {
  final CartController cartController = Get.put(CartController());

  RxBool _customTileExpanded = false.obs;
  showModalBottomSheet(
    context: context,
    backgroundColor: Color.fromARGB(5, 0, 0, 0),
    elevation: 10,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20.0),
    ),
    builder: (BuildContext context) {
      return SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(left: 50, bottom: 15, right: 20),
          padding: EdgeInsets.only(top: 25.0, right: 16.0, left: 16.0),
          decoration: BoxDecoration(
              color: Colors.black, borderRadius: BorderRadius.circular(10)),
          width: MediaQuery.of(context).size.width,
          height: 400,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin: EdgeInsets.only(bottom: 15.0),
                    child: Text(
                      'Categories',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    (cartController.category.value.length + 1).toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Expanded(
                child: Obx(() {
                  return ListView.builder(
                    itemCount: cartController.category.value.length +
                        1, // Increased itemCount by 1
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        // This is the "All Products" option
                        return GestureDetector(
                          onTap: () {
                            cartController.SelectedCat.value = 'All Products';
                            print('All Products');
                            Navigator.pop(context);
                            cartController.fetchAllProducts(
                                context); // Assuming you have this method to fetch all products
                          },
                          child: Container(
                            padding: EdgeInsets.all(15.0),
                            margin: EdgeInsets.only(
                                bottom:
                                    0.0), // Background color to distinguish it
                            child: Text(
                              'All Products',
                              style: TextStyle(
                                color: cartController.SelectedCat.value ==
                                        'All Products'
                                    ? Colors.white
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        );
                      }

                      var category = cartController.category.value[index - 1];
                      var subcategories = category['subcategory'] ?? [];
                      var isSubCategory = category['is_subcategory'];

                      return ((isSubCategory == '1')
                          ? ExpansionTile(
                              onExpansionChanged: (bool expanded) {
                                _customTileExpanded.value =
                                    !_customTileExpanded.value;
                              },
                              trailing: Obx(
                                () => Icon(
                                  _customTileExpanded.value
                                      ? Icons.remove
                                      : Icons.add,
                                  color: Colors.grey,
                                ),
                              ),
                              title: Text(
                                category['name'],
                                style: TextStyle(color: Colors.grey),
                              ),
                              children: <Widget>[
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: subcategories
                                        .map<Widget>((subcategory) {
                                      return GestureDetector(
                                        onTap: () {
                                          cartController.SelectedCat.value =
                                              subcategory['name'];
                                          Navigator.pop(context);
                                          print(
                                              "Sub category ID -- ${subcategory['id']} -- ");
                                          cartController.fetchProducts(
                                              '${subcategory['id']}');
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 1.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(7.0),
                                          ),
                                          margin: EdgeInsets.only(bottom: 10.0),
                                          height: 30,
                                          width: 190,
                                          child: Text(
                                            subcategory['name'],
                                            style: TextStyle(
                                                color: cartController
                                                            .SelectedCat
                                                            .value ==
                                                        subcategory['name']
                                                    ? Colors.white
                                                    : Colors.grey),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                )
                              ],
                            )
                          : GestureDetector(
                              onTap: () {
                                cartController.SelectedCat.value =
                                    category['name'];
                                Navigator.pop(context);
                                print('Category -- ${category['id']}');
                                cartController.fetchProducts(category['id']);
                              },
                              child: Container(
                                padding: EdgeInsets.all(16.0),
                                margin: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  category['name'],
                                  style: TextStyle(
                                      color: cartController.SelectedCat.value ==
                                              category['name']
                                          ? Colors.white
                                          : Colors.grey),
                                ),
                              ),
                            ));
                    },
                  );
                }),
              )
            ],
          ),
        ),
      );
    },
  );
}
