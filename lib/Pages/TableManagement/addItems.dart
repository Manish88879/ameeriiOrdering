import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/bottomSheet.dart';
import 'package:ameerii/Common/cardAdded.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';
import 'package:ameerii/Components/navDrawer.dart';
import 'package:ameerii/Routes/app_pages.dart';

class AddOrder extends StatelessWidget {
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    Future<void> _refresh() async {
      // Simulate a network call or any other refresh logic
      await Future.delayed(Duration(seconds: 2));
      // After the refresh is complete, you can update the UI or perform any other necessary actions
      cartController.fetchAllProducts(context);
    }

    final arguments = Get.arguments;

    final table_number = arguments['table_number'];
    final reference_id = arguments['reference_id'];

    final Size screen = MediaQuery.sizeOf(context);
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 245, 246, 251),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              //print('Back Pressed ${cartController.orderAtCart.length}');
              if (cartController.orderAtCart.length != 0) {
                Get.dialog(AlertDialog(
                  title: const Text("Alert!"),
                  content: const Text('Do you want to cancel the order?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigator.pop(context); // Close the dialog without clearing the cart
                      },
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () {
                        cartController.orderAtCart.value = [];
                        Get.back();
                        Navigator.pop(context); // Close the dialog
                      },
                      child: const Text("Yes"),
                    ),
                  ],
                ));
              } else {
                Navigator.pop(context);
              }
            },
          ),
          backgroundColor: CommonValue.textcolor,
          title: Text(
            'Add Orders',
            style: TextStyle(
                fontFamily: 'Raleway',
                color: Colors.white,
                fontWeight: FontWeight.w400),
          ),
          iconTheme: IconThemeData(color: Colors.white),
        ),
        floatingActionButton: Obx(
          () => Container(
            height: 67.0,
            width: 67.0,
            margin: EdgeInsets.only(
                right: 15.0,
                bottom:
                    cartController.orderAtCart.value.length > 0 ? 70.0 : 30),
            child: FloatingActionButton(
                shape: CircleBorder(),
                backgroundColor: Colors.black,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                        child: Icon(
                      Icons.fastfood,
                      color: Color.fromARGB(255, 245, 246, 251),
                      size: 25.0,
                    )),
                    SizedBox(height: 1.0),
                    Text(
                      'Category',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    )
                  ],
                ),
                onPressed: (() => showCustomModalBottomSheet(context))),
          ),
        ),
        body: Obx(
          () => cartController.products.value.length == 0
              ? Container(
                  color: Colors.white,
                  height: screen.height,
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: 170.0),
                        Image.asset(
                          'images/no_product_available.gif', // Replace 'your_image.jpg' with the actual path to your image asset
                          width: 200, // Adjust the width as needed
                          height: 200, // Adjust the height as needed
                          fit: BoxFit.contain, // Adjust the fit as needed
                        ),
                        // Text(
                        //   'No Products ',
                        //   style: TextStyle(
                        //       color: CommonValue.textcolor,
                        //       fontWeight: FontWeight.w500,
                        //       fontSize: 18.0),
                        // )
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _refresh,
                  child: Stack(
                    children: [
                      Container(
                        color: Color.fromARGB(255, 245, 246, 251),
                        height: MediaQuery.sizeOf(context).height,
                        width: MediaQuery.sizeOf(context).width,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Container(
                              width: screen.width * 0.94,
                              padding: EdgeInsets.only(left: 12.0),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Icon(Icons.search),
                                  Container(
                                    padding:
                                        EdgeInsets.only(top: 0.0, left: 10.0),
                                    width: screen.width * 0.6,
                                    height: 48.0,
                                    child: TextField(
                                      decoration: InputDecoration(
                                        hintText: 'Search Products...',
                                        border: InputBorder.none,
                                      ),
                                      onChanged: (value) {
                                        cartController.searchQuery.value =
                                            value;
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(child: Obx(() {
                              return ListView.builder(
                                itemCount:
                                    cartController.filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product =
                                      cartController.filteredProducts[index];
                                  RxInt itemCount =
                                      cartController.getOrderItemCount(product);
                                  String imageUrl = product['image'];

                                  if (imageUrl == null || imageUrl.isEmpty) {
                                    imageUrl =
                                        'https://img.freepik.com/free-vector/red-prohibited-sign-hand-drawn-cartoon-art-illustration_56104-889.jpg?size=626&ext=jpg&ga=GA1.1.44546679.1716422400&semt=ais_user';
                                  }
                                  return Container(
                                    width: screen.width * 0.7,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 3,
                                    ).copyWith(
                                      bottom: index ==
                                              cartController
                                                      .filteredProducts.length -
                                                  1
                                          ? 120.0
                                          : 3.0, // Add extra bottom margin to the last item
                                    ),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 10.0, vertical: 10.0),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                            color: Colors.grey, width: 0.5),
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      color: Colors.white,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.25,
                                          width:
                                              MediaQuery.sizeOf(context).width *
                                                  0.25,
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(25),
                                            child: Image.network(
                                              imageUrl,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Container(
                                          width: screen.width * 0.4,
                                          child: Column(
                                            children: [
                                              Text(
                                                cartController.products
                                                    .value[index]['name'],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                ' ${double.parse(cartController.products[index]['price']).toStringAsFixed(2)}',
                                                style: TextStyle(
                                                  color: Color.fromARGB(
                                                      255, 127, 80, 244),
                                                  fontSize: 16.0,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.sizeOf(context)
                                                  .height *
                                              0.018,
                                        ),
                                        Obx(() => (cartController
                                                        .getOrderItemCount(
                                                            cartController
                                                                    .products[
                                                                index]) ==
                                                    0 ||
                                                cartController
                                                        .getOrderItemCount(
                                                            cartController
                                                                    .products[
                                                                index]) ==
                                                    null)
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  print(
                                                      'Cart -- ${cartController.orderAtCart.value}');
                                                  cartController.addToCart(
                                                      cartController
                                                          .products[index]);
                                                  itemCount
                                                      .value++; // Increment itemCount when button is clicked
                                                },
                                                child: Text(
                                                  'Add',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: Color.fromARGB(
                                                        255, 127, 80, 244),
                                                  ),
                                                ),
                                              )
                                            : AddRemoveButton(
                                                itemCount: cartController
                                                    .getOrderItemCount(
                                                        cartController
                                                            .products[index]),
                                                onAdd: () {
                                                  cartController.addToCart(
                                                      cartController
                                                          .products[index]);
                                                },
                                                onRemove: () {
                                                  cartController
                                                      .removeItemFromCart(
                                                          cartController
                                                              .products[index]);
                                                },
                                              )),
                                      ],
                                    ),
                                  );
                                },
                              );
                            }))
                          ],
                        ),
                      ),
                      Obx(() => Positioned(
                          right: 12.0,
                          bottom: 10.0,
                          child: cartController.orderAtCart.value.length == 0
                              ? SizedBox(height: 10)
                              : GestureDetector(
                                  onTap: (() => {
                                        cartController.orderHistory_table(
                                            table_number, reference_id)
                                      }),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 19.0),
                                    height: 55.0,
                                    width: screen.width * 0.92,
                                    decoration: BoxDecoration(
                                        color: const Color.fromARGB(
                                            255, 76, 175, 132),
                                        borderRadius:
                                            BorderRadius.circular(13.0)),
                                    child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${cartController.orderAtCart.value.length} Product${cartController.orderAtCart.value.length > 1 ? 's' : ''} added',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 17.0),
                                          ),
                                          cartController.isLoading.value
                                              ? CircularProgressIndicator()
                                              : GestureDetector(
                                                  onTap: (() {
                                                    // cartController.saveOrderHistory();
                                                    cartController
                                                        .orderHistory_table(
                                                            table_number,
                                                            reference_id);
                                                  }),
                                                  child: Row(
                                                    children: [
                                                      Text('Order',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              fontSize: 17.0)),
                                                      Icon(
                                                        Icons
                                                            .arrow_right_rounded,
                                                        color: Colors.white,
                                                      )
                                                    ],
                                                  ),
                                                )
                                        ]),
                                  ),
                                )))
                    ],
                  ),
                ),
        ));
  }
}
