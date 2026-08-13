/// تحويل أسماء المرافق القادمة من الـ Backend (إنجليزية غالباً)
/// إلى تسميات عربية معروضة في الواجهة.
class AmenityLabels {
  AmenityLabels._();

  static const Map<String, String> _map = {
    'wifi': 'إنترنت',
    'parking': 'موقف سيارات',
    'ac': 'تكييف',
    'air conditioning': 'تكييف',
    'elevator': 'مصعد',
    'gym': 'نادي رياضي',
    'pool': 'مسبح',
    'security': 'أمن 24/7',
    'garden': 'حديقة',
    'balcony': 'شرفة',
    'city view': 'إطلالة على المدينة',
    'sea view': 'إطلالة بحرية',
    'furnished': 'مفروش',
    'kitchen': 'مطبخ',
    'full kitchen': 'مطبخ كامل',
    'oven': 'فرن',
    'refrigerator': 'ثلاجة',
    'fridge': 'ثلاجة',
    'freezer': 'فريزر',
    'microwave': 'ميكروويف',
    'stove': 'بوتجاز',
    'kettle': 'غلاية',
    'coffee maker': 'ماكينة قهوة',
    'dishwasher': 'غسالة صحون',
    'towels': 'مناشف',
    'bathroom': 'حمام',
    'shower': 'دش حديث',
    'bathtub': 'حوض استحمام',
    'water heater': 'سخان مياه',
    'washer': 'غسالة ملابس',
    'waching machine': 'غسالة ملابس',
    'washing machine': 'غسالة ملابس',
    'dryer': 'مجفف',
    'tv': 'تلفزيون',
    'smart tv': 'تلفزيون ذكي',
    'internet': 'إنترنت',
    'fiber': 'ألياف بصرية',
    'children play area': 'منطقة ألعاب أطفال',
    'playground': 'منطقة ألعاب',
    'mosque': 'قريب من المسجد',
    'near mosque': 'قريب من المسجد',
    'cctv': 'كاميرات مراقبة',
    'video surveillance': 'كاميرات مراقبة',
    'fire alarm': 'إنذار حريق',
    'smoke detector': 'كاشف دخان',
    'water tank': 'خزان مياه',
    'generator': 'مولد كهرباء',
    'double glazing': 'زجاج مزدوج',
    'electricity': 'كهرباء',
    'water': 'مياه',
    'gas': 'غاز',
    'pets allowed': 'مسموح بالحيوانات',
  };

  /// ترجمة اسم مرافق/مواصفة من الـ API إلى العربية.
  /// إن لم نجد الترجمة نرجع الاسم كما هو.
  static String translate(String value) {
    final v = value.trim();
    if (v.isEmpty) return v;
    return _map[v.toLowerCase()] ?? v;
  }

  /// قائمة المرافق المعروفة التي يمكن للمالك إضافتها/إزالتها.
  /// كل عنصر: (الاسم العربي المعروض، القيمة المُرسلة للـ API).
  static const List<(String, String)> options = [
    ('إنترنت', 'WiFi'),
    ('موقف سيارات', 'Parking'),
    ('تكييف', 'AC'),
    ('مصعد', 'Elevator'),
    ('نادي رياضي', 'Gym'),
    ('مسبح', 'Pool'),
    ('أمن 24/7', 'Security'),
    ('شرفة', 'Balcony'),
    ('إطلالة على المدينة', 'City view'),
    ('إطلالة بحرية', 'Sea view'),
    ('حديقة', 'Garden'),
    ('فرن', 'Oven'),
    ('ثلاجة', 'Refrigerator'),
    ('فريزر', 'Freezer'),
    ('ميكروويف', 'Microwave'),
    ('بوتجاز', 'Stove'),
    ('غلاية', 'Kettle'),
    ('ماكينة قهوة', 'Coffee maker'),
    ('غسالة صحون', 'Dishwasher'),
    ('غسالة ملابس', 'Washing machine'),
    ('مناشف', 'Towels'),
    ('دش حديث', 'Shower'),
    ('حوض استحمام', 'Bathtub'),
    ('سخان مياه', 'Water heater'),
    ('تلفزيون ذكي', 'Smart TV'),
    ('كاميرات مراقبة', 'CCTV'),
    ('إنذار حريق', 'Fire alarm'),
    ('مولد كهرباء', 'Generator'),
    ('خزان مياه', 'Water tank'),
    ('مسموح بالحيوانات', 'Pets allowed'),
  ];

  /// البحث عن القيمة المُرسلة للـ API من الاسم العربي المعروض.
  static String? apiValueForLabel(String label) {
    for (final o in options) {
      if (o.$1 == label) return o.$2;
    }
    return null;
  }
}
