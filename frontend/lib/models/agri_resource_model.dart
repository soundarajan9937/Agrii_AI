class AgriResourceModel {
  final String id;
  final String name;
  final String category;
  final String sellerName;
  final String sellerId;
  final double price;
  final String phoneNumber;
  final String image;
  final String status;
  final String? description;
  final String? rejectionReason;

  AgriResourceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.sellerName,
    required this.sellerId,
    required this.price,
    required this.phoneNumber,
    required this.image,
    required this.status,
    this.description,
    this.rejectionReason,
  });

  factory AgriResourceModel.fromJson(Map<String, dynamic> json) {
    return AgriResourceModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      sellerName: json['sellerName'] ?? '',
      sellerId: json['sellerId'] ?? '',
      price: num.tryParse(json['price']?.toString() ?? '0')?.toDouble() ?? 0.0,
      phoneNumber: json['phoneNumber'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? 'pending',
      description: json['description'],
      rejectionReason: json['rejectionReason'],
    );
  }
}
