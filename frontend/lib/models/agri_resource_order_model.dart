class AgriResourceOrderModel {
  final String id;
  final String buyerName;
  final String buyerId;
  final String resourceId;
  final String sellerId;
  final double price;
  final String paymentMethod;
  final String status;
  final String buyerPhone;
  final String deliveryAddress;
  final String? resourceName; // From populate
  final String? resourceImage; // From populate

  AgriResourceOrderModel({
    required this.id,
    required this.buyerName,
    required this.buyerId,
    required this.resourceId,
    required this.sellerId,
    required this.price,
    required this.paymentMethod,
    required this.status,
    required this.buyerPhone,
    required this.deliveryAddress,
    this.resourceName,
    this.resourceImage,
  });

  factory AgriResourceOrderModel.fromJson(Map<String, dynamic> json) {
    final resourceData = json['resourceId'];
    return AgriResourceOrderModel(
      id: json['_id'] ?? '',
      buyerName: json['buyerName'] ?? '',
      buyerId: json['buyerId'] ?? '',
      resourceId: resourceData is Map ? (resourceData['_id'] ?? '') : (resourceData ?? ''),
      sellerId: json['sellerId'] ?? '',
      price: num.tryParse(json['price']?.toString() ?? '0')?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      status: json['status'] ?? 'pending',
      buyerPhone: json['buyerPhone'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      resourceName: resourceData is Map ? resourceData['name'] : null,
      resourceImage: resourceData is Map ? resourceData['image'] : null,
    );
  }
}
