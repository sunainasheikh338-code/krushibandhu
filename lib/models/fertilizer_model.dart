class FertilizerModel {
  final String fertilizerName;
  final String company;
  final double price;
  final int quantity;

  FertilizerModel({
    required this.fertilizerName,
    required this.company,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'fertilizerName': fertilizerName,
      'company': company,
      'price': price,
      'quantity': quantity,
    };
  }

  factory FertilizerModel.fromMap(Map<String, dynamic> map) {
    return FertilizerModel(
      fertilizerName: map['fertilizerName'] ?? '',
      company: map['company'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 0,
    );
  }
}