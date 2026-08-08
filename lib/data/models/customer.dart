/// بيانات المستخدم (Customer) كما تعود من الباك إند.
class Customer {
  final int id;
  final String name;
  final String? firstName;
  final String? lastName;
  final String email;
  final String? phone;
  final String? avatar;
  final bool verified;
  final String? joinDate;
  final String? role;
  final String? status;
  final String? city;
  final String? address;

  const Customer({
    required this.id,
    required this.name,
    this.firstName,
    this.lastName,
    required this.email,
    this.phone,
    this.avatar,
    this.verified = false,
    this.joinDate,
    this.role,
    this.status,
    this.city,
    this.address,
  });

  /// الاسم الكامل من firstName + lastName (أو `name` كاحتياط).
  String get fullName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isNotEmpty && l.isNotEmpty) return '$f $l';
    if (f.isNotEmpty) return f;
    return name;
  }

  /// نسخة جديدة مع استبدال الحقول المعطاة (لحفظ التعديلات محلياً).
  Customer copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? city,
    String? address,
  }) {
    return Customer(
      id: id,
      name: name,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      phone: phone ?? this.phone,
      avatar: avatar,
      verified: verified,
      joinDate: joinDate,
      role: role,
      status: status,
      city: city ?? this.city,
      address: address ?? this.address,
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: json['name'] as String? ?? '',
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      verified: json['verified'] as bool? ?? false,
      joinDate: json['joinDate'] as String?,
      role: json['role'] as String?,
      status: json['status'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phone': phone,
    'avatar': avatar,
    'verified': verified,
    'joinDate': joinDate,
    'role': role,
    'status': status,
    'city': city,
    'address': address,
  };
}