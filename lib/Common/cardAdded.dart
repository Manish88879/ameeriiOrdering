import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AddRemoveButton extends StatelessWidget {
  final RxInt itemCount;
  final Function() onAdd;
  final Function() onRemove;

  AddRemoveButton({
    required this.itemCount,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 127, 80, 244),
                  width: 2,
                ),
                color: Color.fromARGB(60, 127, 80, 244),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5.0),
                  bottomLeft: Radius.circular(5.0),
                ),
              ),
              width: 26,
              height: 27,
              child: Icon(
                Icons.remove,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            height: 27,
            width: 26,
            decoration: BoxDecoration(
              border: Border.symmetric(
                horizontal: BorderSide(
                  color: Color.fromARGB(255, 127, 80, 244),
                  width: 2,
                ),
              ),
              color: Color.fromARGB(60, 127, 80, 244),
            ),
            child: Center(
                child: Obx(
              () => Text(
                '$itemCount',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )),
          ),
          GestureDetector(
            onTap: onAdd,
            child: Container(
              height: 27,
              width: 26,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Color.fromARGB(255, 127, 80, 244),
                  width: 2,
                ),
                color: Color.fromARGB(60, 127, 80, 244),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(5.0),
                  bottomRight: Radius.circular(5.0),
                ),
              ),
              child: Icon(
                Icons.add,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
