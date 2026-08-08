import 'package:flutter/material.dart';

class OrderItem {
  final String badgeText;
  final Color badgeColor;
  final Color badgeTextColor;
  final String time;
  final String name;
  final String subtitle;

  const OrderItem({
    required this.badgeText,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.time,
    required this.name,
    required this.subtitle,
  });

  static const List<OrderItem> samples = [
    OrderItem(
      badgeText: 'عاجل',
      badgeColor: Color(0xFFFCE4EC),
      badgeTextColor: Colors.red,
      time: 'منذ ساعتين',
      name: 'أحمد محمد',
      subtitle: 'طلب صيانة • شقة رقم 104',
    ),
    OrderItem(
      badgeText: 'قيد المراجعة',
      badgeColor: Color(0xFFE3F2FD),
      badgeTextColor: Color(0xFF0D47C9),
      time: 'منذ 5 ساعات',
      name: 'سارة علي',
      subtitle: 'تجديد عقد • فيلا الرمال',
    ),
    OrderItem(
      badgeText: 'تم الدفع',
      badgeColor: Color(0xFFF2F4F7),
      badgeTextColor: Color(0xFF1A1A24),
      time: 'أمس',
      name: 'محمد خالد',
      subtitle: 'سداد إيجار • مكتب تجاري 4',
    ),
    OrderItem(
      badgeText: 'مؤكد',
      badgeColor: Color(0xFFE8F5E9),
      badgeTextColor: Color(0xFF2E7D32),
      time: 'منذ 3 أيام',
      name: 'نورة العنزي',
      subtitle: 'حجز جديد • شقة النرجس',
    ),
    OrderItem(
      badgeText: 'ملغي',
      badgeColor: Color(0xFFFBE9E7),
      badgeTextColor: Color(0xFFE65100),
      time: 'منذ أسبوع',
      name: 'فهد الدوسري',
      subtitle: 'إلغاء حجز • فيلا العليا',
    ),
    OrderItem(
      badgeText: 'قيد الانتظار',
      badgeColor: Color(0xFFFEF3E2),
      badgeTextColor: Color(0xFFF57C00),
      time: 'منذ 4 أيام',
      name: 'هند القحطاني',
      subtitle: 'استفسار • مكتب الرمال',
    ),
    OrderItem(
      badgeText: 'مكتمل',
      badgeColor: Color(0xFFE8F5E9),
      badgeTextColor: Color(0xFF2E7D32),
      time: 'منذ أسبوعين',
      name: 'يوسف الشمري',
      subtitle: 'إنهاء عقد • استوديو الملقا',
    ),
    OrderItem(
      badgeText: 'عاجل',
      badgeColor: Color(0xFFFCE4EC),
      badgeTextColor: Colors.red,
      time: 'منذ يوم',
      name: 'مشاري العتيبي',
      subtitle: 'شكوى • فيلا النرجس 5',
    ),
  ];
}
