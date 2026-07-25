class RenterModel {
  final int? id;
  final String name;
  final String cpf;
  final String rg;
  final String cnh;
  final String cnhCategory;
  final String cnhExpiration;
  final String phone;
  final String email;
  final String address;
  final String emergencyContact;
  final String notes;

  const RenterModel({
    this.id,
    required this.name,
    required this.cpf,
    required this.rg,
    required this.cnh,
    required this.cnhCategory,
    required this.cnhExpiration,
    required this.phone,
    required this.email,
    required this.address,
    required this.emergencyContact,
    required this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'rg': rg,
      'cnh': cnh,
      'cnhCategory': cnhCategory,
      'cnhExpiration': cnhExpiration,
      'phone': phone,
      'email': email,
      'address': address,
      'emergencyContact': emergencyContact,
      'notes': notes,
    };
  }

  factory RenterModel.fromMap(Map<String, dynamic> map) {
    return RenterModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      cpf: map['cpf'] as String? ?? '',
      rg: map['rg'] as String? ?? '',
      cnh: map['cnh'] as String? ?? '',
      cnhCategory: map['cnhCategory'] as String? ?? '',
      cnhExpiration: map['cnhExpiration'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      email: map['email'] as String? ?? '',
      address: map['address'] as String? ?? '',
      emergencyContact: map['emergencyContact'] as String? ?? '',
      notes: map['notes'] as String? ?? '',
    );
  }
}