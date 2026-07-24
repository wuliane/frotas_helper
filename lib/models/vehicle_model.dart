class VehicleModel {
  final int? id;
  final String plate;
  final String brand;
  final String model;
  final int year;
  final String color;
  final int currentKm;
  final double purchaseValue;
  final double rentalValue;
  final String status;

  const VehicleModel({
    this.id,
    required this.plate,
    required this.brand,
    required this.model,
    required this.year,
    required this.color,
    required this.currentKm,
    required this.purchaseValue,
    required this.rentalValue,
    required this.status,
  });

  VehicleModel copyWith({
    int? id,
    String? plate,
    String? brand,
    String? model,
    int? year,
    String? color,
    int? currentKm,
    double? purchaseValue,
    double? rentalValue,
    String? status,
  }) {
    return VehicleModel(
      id: id ?? this.id,
      plate: plate ?? this.plate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      year: year ?? this.year,
      color: color ?? this.color,
      currentKm: currentKm ?? this.currentKm,
      purchaseValue: purchaseValue ?? this.purchaseValue,
      rentalValue: rentalValue ?? this.rentalValue,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'plate': plate,
      'brand': brand,
      'model': model,
      'year': year,
      'color': color,
      'currentKm': currentKm,
      'purchaseValue': purchaseValue,
      'rentalValue': rentalValue,
      'status': status,
    };
  }

  factory VehicleModel.fromMap(Map<String, dynamic> map) {
    return VehicleModel(
      id: map['id'] as int?,
      plate: map['plate'] as String,
      brand: map['brand'] as String,
      model: map['model'] as String,
      year: map['year'] as int,
      color: map['color'] as String,
      currentKm: map['currentKm'] as int,
      purchaseValue: (map['purchaseValue'] as num).toDouble(),
      rentalValue: (map['rentalValue'] as num).toDouble(),
      status: map['status'] as String,
    );
  }
}
