import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ameerii/Common/APIUrls.dart';
import 'package:ameerii/Common/model/txnHistoryModal.dart';

class TransactionHistoryPage extends StatefulWidget {
  final String cardNumber;
  const TransactionHistoryPage({super.key, required this.cardNumber});
  @override
  _TransactionHistoryPageState createState() =>
      _TransactionHistoryPageState(cardnumber: cardNumber);
}

class _TransactionHistoryPageState extends State<TransactionHistoryPage>
    with SingleTickerProviderStateMixin {
  final String cardnumber;
  _TransactionHistoryPageState({required this.cardnumber});
  late Future<List<TxnHistoryModal>> _transactionHistoryFuture;
  bool isLoading = false;
  late String? userId;

  @override
  void initState() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? counter = prefs.getString('userId');
    userId = counter;
    _transactionHistoryFuture = _txnHistory();

    super.initState();
  }

  Future<List<TxnHistoryModal>> _txnHistory() async {
    try {
      final response = await http
          .get(Uri.parse("${APIUrls.card_history}$userId&cardno=$cardnumber"));

      final data = json.decode(response.body);
      // print("Data ${data}");
      if (data != null && data["status"]) {
        final jsonData = data;
        final List<dynamic> transactionList = jsonData['users'];
        return transactionList
            .map((user) => TxnHistoryModal.fromJson(user))
            .toList();
      }
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Error!"),
            content: Text(error.toString()),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("OK"),
              ),
            ],
          );
        },
      );

      // Return an empty list if there's an error
      return [];
    } finally {
      setState(() {
        isLoading = false;
      });
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: Colors.blueGrey,
        title: Text('Transaction History'),
      ),
      body: Container(
        color: Colors.blueGrey,
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: MediaQuery.of(context).size.height * 0.8,
            child: Card(
              child: FutureBuilder<List<TxnHistoryModal>>(
                future: _transactionHistoryFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final transactionList = snapshot.data!;
                    return ListView.separated(
                      itemCount: transactionList.length,
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(color: Colors.grey);
                      },
                      itemBuilder: (context, index) {
                        final transaction = transactionList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(8.0),
                              onTap: () {
                                // Add your onTap functionality here
                              },
                              onHover: (hovering) {
                                // Add your hover functionality here
                              },
                              child: ListTile(
                                title: Text(
                                  'Transaction ID: ${transaction.txnID}',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Date : ${transaction.created}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      (transaction.type == '1' ||
                                              transaction.type == '3')
                                          ? Icons.add
                                          : Icons.remove,
                                      color: (transaction.type == '1' ||
                                              transaction.type == '3')
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                    SizedBox(width: 4), // Add some spacing
                                    Text(
                                      '₹${transaction.amount}',
                                      style: TextStyle(
                                          color: (transaction.type == '1' ||
                                                  transaction.type == '3')
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17.0),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
