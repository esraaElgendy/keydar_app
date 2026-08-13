/// بيانات المالك (Owner) كما تعود من `POST /auth/owner-login`.
class Owner {
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
  final bool isSuperAdmin;

  const Owner({
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
    this.isSuperAdmin = false,
  });

  /// الاسم الكامل من firstName + lastName (أو `name` كاحتياط).
  String get fullName {
    final f = (firstName ?? '').trim();
    final l = (lastName ?? '').trim();
    if (f.isNotEmpty && l.isNotEmpty) return '$f $l';
    if (f.isNotEmpty) return f;
    return name;
  }

  factory Owner.fromJson(Map<String, dynamic> json) {
    return Owner(
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
      isSuperAdmin: json['isSuperAdmin'] as bool? ?? false,
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
        'isSuperAdmin': isSuperAdmin,
      };
}