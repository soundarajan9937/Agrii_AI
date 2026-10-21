class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String quantity;
  final String unit;
  final String seller;
  final String sellerName;
  final String sellerPhone;
  final String location;
  final String image;
  final String description;

  // Admin approval
  final String approvalStatus;
  final String rejectionReason;

  ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.seller,
    required this.sellerName,
    required this.sellerPhone,
    required this.location,
    required this.image,
    required this.description,
    required this.approvalStatus,
    required this.rejectionReason,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Seller can be either an ID or a populated User object
    String sellerId = "";

    if (json["seller"] is Map) {
      sellerId = json["seller"]["_id"]?.toString() ?? "";
    } else {
      sellerId = json["seller"]?.toString() ?? "";
    }

    String sellerName = "";
    if (json["seller"] is Map) {
      sellerName = json["seller"]["name"]?.toString() ?? "";
    } else {
      sellerName = json["sellerName"]?.toString() ?? "";
    }

    String sellerPhone = "";
    if (json["seller"] is Map) {
      sellerPhone = json["seller"]["phone"]?.toString() ?? "";
    } else {
      sellerPhone = json["sellerPhone"]?.toString() ?? "";
    }

    return ProductModel(
      id: json["_id"]?.toString() ?? json["id"]?.toString() ?? "",
      name: json["name"]?.toString() ?? "",
      category: json["category"]?.toString() ?? "",
      price: json["price"] is num
          ? (json["price"] as num).toDouble()
          : double.tryParse(json["price"]?.toString() ?? "") ?? 0.0,
      quantity: json["quantity"]?.toString() ?? "",
      unit: json["unit"]?.toString() ?? "Kg",
      seller: sellerId,
      sellerName: sellerName,
      sellerPhone: sellerPhone,
      location: json["seller"] is Map
          ? json["seller"]["farmLocation"]?.toString() ??
                json["seller"]["location"]?.toString() ??
                json["location"]?.toString() ??
                ""
          : json["location"]?.toString() ?? "",
      image: json["image"]?.toString() ?? "",
      description: json["description"]?.toString() ?? "",
      approvalStatus: json["approvalStatus"]?.toString() ?? "pending",
      rejectionReason: json["rejectionReason"]?.toString() ?? "",
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "name": name,
      "category": category,
      "price": price,
      "quantity": quantity,
      "unit": unit,
      "seller": seller,
      "sellerName": sellerName,
      "sellerPhone": sellerPhone,
      "location": location,
      "image": image,
      "description": description,
      "approvalStatus": approvalStatus,
      "rejectionReason": rejectionReason,
    };
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? quantity,
    String? unit,
    String? seller,
    String? sellerName,
    String? sellerPhone,
    String? location,
    String? image,
    String? description,
    String? approvalStatus,
    String? rejectionReason,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      seller: seller ?? this.seller,
      sellerName: sellerName ?? this.sellerName,
      sellerPhone: sellerPhone ?? this.sellerPhone,
      location: location ?? this.location,
      image: image ?? this.image,
      description: description ?? this.description,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }
}
