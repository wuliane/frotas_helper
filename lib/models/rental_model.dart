class RentalModel {
  final int? id;

  final int vehicleId;
  final int renterId;

  final DateTime startDate;
  final DateTime? endDate;

  final double fullValue;
  final double discountedValue;
  final String paymentFrequency;
  final int paymentWeekday;

  final double depositValue;
  final double depositReceived;

  final int initialKm;
  final int currentKm;
  final int kmClosingDay;
  final int kmLimitPerCycle;
  final double excessKmValue;

  final String status;
  final String notes;

  const RentalModel({
    this.id,
    required this.vehicleId,
    required this.renterId,
    required this.startDate,
    this.endDate,
    required this.fullValue,
    required this.discountedValue,
    required this.paymentFrequency,
    required this.paymentWeekday,
    required this.depositValue,
    required this.depositReceived,
    required this.initialKm,
    required this.currentKm,
    required this.kmClosingDay,
    required this.kmLimitPerCycle,
    required this.excessKmValue,
    required this.status,
    required this.notes,
  });

  double get depositRemaining {
    final remaining = depositValue - depositReceived;
    return remaining < 0 ? 0 : remaining;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'vehicleId': vehicleId,
      'renterId': renterId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'fullValue': fullValue,
      'discountedValue': discountedValue,
      'paymentFrequency': paymentFrequency,
      'paymentWeekday': paymentWeekday,
      'depositValue': depositValue,
      'depositReceived': depositReceived,
      'initialKm': initialKm,
      'currentKm': currentKm,
      'kmClosingDay': kmClosingDay,
      'kmLimitPerCycle': kmLimitPerCycle,
      'excessKmValue': excessKmValue,
      'status': status,
      'notes': notes,
    };
  }

  factory RentalModel.fromMap(Map<String, dynamic> map) {
    final endDateValue = map['endDate'] as String?;

    return RentalModel(
      id: map['id'] as int?,
      vehicleId: map['vehicleId'] as int,
      renterId: map['renterId'] as int,
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: endDateValue == null || endDateValue.isEmpty
          ? null
          : DateTime.parse(endDateValue),
      fullValue: (map['fullValue'] as num).toDouble(),
      discountedValue: (map['discountedValue'] as num).toDouble(),
      paymentFrequency: map['paymentFrequency'] as String,
      paymentWeekday: map['paymentWeekday'] as int,
      depositValue: (map['depositValue'] as num).toDouble(),
      depositReceived: (map['depositReceived'] as num).toDouble(),
      initialKm: map['initialKm'] as int,
      currentKm: map['currentKm'] as int,
      kmClosingDay: map['kmClosingDay'] as int,
      kmLimitPerCycle: map['kmLimitPerCycle'] as int,
      excessKmValue: (map['excessKmValue'] as num).toDouble(),
      status: map['status'] as String,
      notes: map['notes'] as String? ?? '',
    );
  }
}