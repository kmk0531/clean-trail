class Coupon {
  final String id;
  final String shopName;
  final String discountDetails;
  final String expiryDate;
  bool isUsed;

  Coupon({
    required this.id,
    required this.shopName,
    required this.discountDetails,
    required this.expiryDate,
    this.isUsed = false,
  });
}
