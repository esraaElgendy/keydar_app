/// الملف الكامل للمالك من `GET /owner/profile`.
///
/// يحمل بيانات التحقق والشركة والحساب البنكي التي لا توجد في
/// استجابة تسجيل الدخول ([Owner]).
class OwnerProfile {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? city;
  final String? address;
  final String? companyName;
  final String? commercialRegistration;
  final String? taxNumber;
  final String verificationStatus;
  final OwnerBanking? banking;
  final String? createdAt;

  const OwnerProfile({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.city,
    this.address,
    this.companyName,
    this.commercialRegistration,
    this.taxNumber,
    this.verificationStatus = 'pending',
    this.banking,
    this.createdAt,
  });

  factory OwnerProfile.fromJson(Map<String, dynamic> json) {
    final banking = json['banking'];
    return OwnerProfile(
      id: (json['id'] as num?)?.toInt() ?? 0,
      name: (json['name'] as String?) ?? '',
      email: (json['email'] as String?) ?? '',
      phone: json['phone'] as String?,
      avatar: json['avatar'] as String?,
      city: json['city'] as String?,
      address: json['address'] as String?,
      companyName: json['companyName'] as String?,
      commercialRegistration: json['commercialRegistration'] as String?,
      taxNumber: json['taxNumber'] as String?,
      verificationStatus: (json['verificationStatus'] as String?) ?? 'pending',
      banking: banking is Map
          ? OwnerBanking.fromJson(Map<String, dynamic>.from(banking))
          : null,
      createdAt: json['createdAt'] as String?,
    );
  }

  /// هل تمت الموافقة على التحقق (اعتماد الحساب)؟
  bool get isVerified => verificationStatus.toLowerCase() == 'approved';

  /// تسمية حالة التحقق بالعربية.
  String get verificationLabel => switch (verificationStatus.toLowerCase()) {
        'approved' => 'حساب موثّق',
        'rejected' => 'تم رفض الطلب',
        _ => 'قيد المراجعة',
      };
}

/// بيانات الحساب البنكي الخاصة بالمالك.
class OwnerBanking {
  final String? bankName;
  final String? bankAccountHolder;
  final String? iban;

  const OwnerBanking({this.bankName, this.bankAccountHolder, this.iban});

  factory OwnerBanking.fromJson(Map<String, dynamic> json) => OwnerBanking(
        bankName: json['bankName'] as String?,
        bankAccountHolder: json['bankAccountHolder'] as String?,
        iban: json['iban'] as String?,
      );

  /// هل اكتملت بيانات البنك (وُجدت بيانات فعلياً)؟
  bool get isComplete =>
      (bankName?.trim().isNotEmpty ?? false) &&
      (iban?.trim().isNotEmpty ?? false);
}