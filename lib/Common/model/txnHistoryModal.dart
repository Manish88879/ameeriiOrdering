class TxnHistoryModal {
  final String txnID;
  final String amount;
  final String type;
  final String created;

  TxnHistoryModal({
    required this.txnID,
    required this.amount,
    required this.type,
    required this.created,
  });

  factory TxnHistoryModal.fromJson(Map<String, dynamic> json) {
    return TxnHistoryModal(
      txnID: json['txnid'],
      amount: json['amount'],
      type: json['type'],
      created: json['created'],
    );
  }
}
