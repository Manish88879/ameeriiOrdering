import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:ameerii/Common/bottomSheet.dart';
import 'package:ameerii/Common/cardAdded.dart';
import 'package:ameerii/Common/color.dart';
import 'package:ameerii/Common/controller/OrderController/orderController.dart';
import 'package:ameerii/Components/navDrawer.dart';
import 'package:ameerii/Pages/QuickOrder/checkoutPage.dart';
import 'package:ameerii/Pages/TableManagement/tableManagementModal.dart';
import 'package:ameerii/Routes/app_pages.dart';

class Cart extends StatelessWidget {
  final CartController cartController = Get.put(CartController());

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  TextEditingController cname = TextEditingController();
  TextEditingController cphone = TextEditingController();
  TextEditingController caddress = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Size screen = MediaQuery.sizeOf(context);
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 219, 218, 218),
      appBar: AppBar(
        backgroundColor: CommonValue.textcolor,
        title: Text(
          'Cart',
          style: TextStyle(
              fontFamily: 'Raleway',
              color: Colors.white,
              fontWeight: FontWeight.w400),
        ),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          Builder(
            builder: (context) => Row(
              children: [
                IconButton(
                  icon: Container(
                    margin: EdgeInsets.only(right: 17.0),
                    child: Icon(
                      Icons.person_add_alt,
                      color: Colors.white,
                      size: 25.0,
                    ),
                  ),
                  onPressed: () => showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        scrollable: true,
                        title: const Text("Customer Details"),
                        content: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Form(
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: cname,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    labelText: "Customer name",
                                    icon: Icon(Icons.person_4_outlined),
                                  ),
                                ),
                                TextFormField(
                                  controller: cphone,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: "Phone",
                                    icon: Icon(Icons.phone_android),
                                  ),
                                ),
                                TextFormField(
                                  controller: caddress,
                                  keyboardType: TextInputType.text,
                                  decoration: const InputDecoration(
                                    labelText: "Address (Optional)",
                                    icon: Icon(Icons.domain_add_rounded),
                                  ),
                                ),
                                SizedBox(height: 30),
                                GestureDetector(
                                  onTap: () {
                                    cartController.cname.value = cname.text;
                                    cartController.cphone.value = cphone.text;
                                    cartController.caddress.value =
                                        caddress.text;

                                    Navigator.pop(context);
                                  },
                                  child: Container(
                                    height: 34.0,
                                    width: screen.width * 0.65,
                                    decoration: BoxDecoration(
                                      color: CommonValue.phyloText,
                                      border: Border.all(
                                        color: CommonValue.phyloText,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    alignment: Alignment.center,
                                    child: const Text(
                                      'Submit',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15.0,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  tooltip:
                      MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(top: 10.0),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(6)),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 5.0, horizontal: 17),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(7.0),
                            color: Colors.green,
                          ),
                          child: Center(
                              child: Text(
                            'Check out below items for Dine In',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.none),
                          )),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 10),
                      color: Colors.deepPurpleAccent[50],
                      height: MediaQuery.sizeOf(context).height * 0.6,
                      child: ListView.builder(
                        itemCount: cartController.orderAtCart.length,
                        itemBuilder: (context, index) {
                          final product = cartController.orderAtCart[index];
                          RxInt itemCount =
                              cartController.getOrderItemCount(product);
                          String imageUrl = product['image'];

                          if (imageUrl == null || imageUrl.isEmpty) {
                            imageUrl =
                                'https://img.freepik.com/free-vector/red-prohibited-sign-hand-drawn-cartoon-art-illustration_56104-889.jpg?size=626&ext=jpg&ga=GA1.1.44546679.1716422400&semt=ais_user';
                          }
                          return Dismissible(
                            key: Key(product['id'].toString()),
                            onDismissed: (direction) {
                              cartController.deleteItemFromCart(product);
                              print(
                                  'Number ----  ${cartController.orderAtCart.length}');
                              if (cartController.orderAtCart.length == 0) {
                                Get.back();
                              }
                              // Get.offAndToNamed(Routes.CART);
                              // if (cartController.orderAtCart.value.length ==
                              //     1) {
                              //   print("Order Delete ---- ");
                              //   Navigator.of(context).pop();
                              // }
                            },
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: AlignmentDirectional.centerEnd,
                              color: Colors.red,
                              child: Padding(
                                padding:
                                    EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                              ),
                            ),
                            child: Container(
                              height: MediaQuery.sizeOf(context).height * 0.15,
                              decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white, width: 1),
                                  )),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 20.0),
                              child: Row(
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 15),
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.23,
                                    height:
                                        MediaQuery.sizeOf(context).height * 0.1,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          spreadRadius: 2,
                                          blurRadius: 5,
                                          offset: Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Container(
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.3,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(product["name"]),
                                        Text("${product["price"]}")
                                      ],
                                    ),
                                  ),
                                  Container(
                                      margin: EdgeInsets.only(left: 15.0),
                                      child: AddRemoveButton(
                                        itemCount: cartController
                                            .getOrderItemCount(product),
                                        onAdd: () {
                                          cartController.addToCart(product);
                                        },
                                        onRemove: () {
                                          if (cartController
                                                  .getOrderItemCount(product) ==
                                              1) {
                                            Get.dialog(AlertDialog(
                                              title: const Text("Alert!"),
                                              content: Text(
                                                  'Do you really want to delete ?'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () {
                                                    cartController
                                                        .removeItemFromCart(
                                                            product);
                                                    Get.back();
                                                    Get.offAndToNamed(
                                                        Routes.CART);
                                                    if (cartController
                                                            .orderAtCart
                                                            .length ==
                                                        0) {
                                                      Get.back();
                                                    }
                                                  },
                                                  child: const Text("Yes"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text("No"),
                                                ),
                                              ],
                                            ));
                                          } else {
                                            cartController
                                                .removeItemFromCart(product);
                                          }
                                        },
                                      ))
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 7.0, horizontal: 15.0),
              color: Colors.black12,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal',
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Color.fromARGB(255, 50, 50, 50),
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500),
                      ),
                      Obx(() => Text(
                            ' ${cartController.subtotal.value}',
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500),
                          ))
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Tax',
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Color.fromARGB(255, 50, 50, 50),
                            fontSize: 20.0,
                            fontWeight: FontWeight.w500),
                      ),
                      Obx(() => Text(
                            ' ${cartController.totalTaxes.value}',
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500),
                          ))
                    ],
                  ),
                  const SizedBox(height: 5.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Payable Amount',
                        style: TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.black,
                            fontSize: 22.0,
                            fontWeight: FontWeight.w700),
                      ),
                      Obx(() => Text(
                            ' ${cartController.totalAmount.value}',
                            style: TextStyle(
                                decoration: TextDecoration.none,
                                color: Colors.black,
                                fontSize: 20.0,
                                fontWeight: FontWeight.w500),
                          ))
                    ],
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Are you sure?'),
                                    content:
                                        Text('Do you really want to cancel?'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: Text('Yes'),
                                        onPressed: () {
                                          cartController.orderAtCart.value = [];
                                          cartController.referenceId.value =
                                              '0';
                                          Navigator.of(context).pop();
                                          Get.offAllNamed(Routes.QUICKORDER);
                                        },
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                              height: 50.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.0),
                                color: Colors.orange,
                              ),
                              child: Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20.0),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => {
                              if (!cartController.isLoading.value)
                                cartController.sendOrderHistory()
                            },
                            child: Container(
                              height: 50.0,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.0),
                                  color: Colors.green),
                              child: Center(
                                child: Obx(() => Text(
                                      cartController.isLoading.value
                                          ? 'Loading...'
                                          : 'Proceed',
                                      style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                          decoration: TextDecoration.none),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    )),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
