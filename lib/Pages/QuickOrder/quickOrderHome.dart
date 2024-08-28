import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/bottomSheet.dart';
import 'package:ameerii/Common/cardAdded.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';
import 'package:ameerii/Components/navDrawer.dart';
import 'package:ameerii/Routes/app_pages.dart';

class QuickOrderHome extends StatelessWidget {
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

  QuickOrderHome({super.key});
  final CartController cartController = Get.put(CartController());

  @override
  Widget build(BuildContext context) {
    Future<void> _refresh() async {
      // Simulate a network call or any other refresh logic
      await Future.delayed(Duration(seconds: 2));
      // After the refresh is complete, you can update the UI or perform any other necessary actions
      cartController.fetchAllProducts(context);
    }

    final Size screen = MediaQuery.sizeOf(context);
    return WillPopScope(
      onWillPop: () => _onWillPop(context),
      child: Scaffold(
        backgroundColor: Color.fromARGB(255, 219, 218, 218),
        appBar: AppBar(
          leading: Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(
                  Icons.align_horizontal_left_outlined,
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
            'Quick Order',
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
                      color: Colors.grey,
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
        drawer: NavDrawer(),
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
                          'images/no_product_available.gif',
                          width: 200,
                          height: 200,
                          fit: BoxFit.contain,
                        ),
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
                                    width:
                                        MediaQuery.of(context).size.width * 0.7,
                                    margin: EdgeInsets.symmetric(
                                      horizontal: 12.0,
                                      vertical: 3,
                                    ).copyWith(
                                      bottom: index ==
                                              cartController
                                                      .filteredProducts.length -
                                                  1
                                          ? 120.0
                                          : 3.0,
                                    ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.0,
                                      vertical: 10.0,
                                    ),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.grey,
                                          width: 0.2,
                                        ),
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
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
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.4,
                                          child: Column(
                                            children: [
                                              Text(
                                                product["name"],
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              Text(
                                                ' ${double.parse(product['price']).toStringAsFixed(2)}',
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
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.018,
                                        ),
                                        Obx(() => (cartController
                                                        .getOrderItemCount(
                                                            product) ==
                                                    0 ||
                                                cartController
                                                        .getOrderItemCount(
                                                            product) ==
                                                    null)
                                            ? ElevatedButton(
                                                onPressed: () {
                                                  print(
                                                      'Cart -- ${cartController.orderAtCart.value}');
                                                  cartController
                                                      .addToCart(product);
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
                                                    .getOrderItemCount(product),
                                                onAdd: () {
                                                  cartController
                                                      .addToCart(product);
                                                },
                                                onRemove: () {
                                                  cartController
                                                      .removeItemFromCart(
                                                          product);
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
                                  onTap: (() => Get.toNamed(Routes.CART)),
                                  child: Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 19.0),
                                    height: 60.0,
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
                                          GestureDetector(
                                            onTap: (() =>
                                                Get.toNamed(Routes.CART)),
                                            child: Row(
                                              children: [
                                                Text('View Cart',
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 17.0)),
                                                Icon(
                                                  Icons.arrow_right_rounded,
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
        ),
      ),
    );
  }
}
