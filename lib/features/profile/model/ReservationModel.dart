class ReservationModel {
  final int id;
  final String? reservationDate;
  final String? checkInDate;
  final String? checkOutDate;
  final double? discount;
  final double? discountedPrice;

  ReservationModel({
    required this.id,
    this.reservationDate,
    this.checkInDate,
    this.checkOutDate,
    this.discount,
    this.discountedPrice,
  });

  factory ReservationModel.fromJson(Map<String, dynamic> json) {
    return ReservationModel(
      id: json['id'] as int,
      reservationDate: json['reservationDate'] as String?,
      checkInDate: json['checkInDate'] as String?,
      checkOutDate: json['checkOutDate'] as String?,
      discount: (json['discount'] as num?)?.toDouble(),
      discountedPrice: (json['discountedPrice'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'reservationDate': reservationDate,
      'checkInDate': checkInDate,
      'checkOutDate': checkOutDate,
      'discount': discount,
      'discountedPrice': discountedPrice,
    };
  }
}