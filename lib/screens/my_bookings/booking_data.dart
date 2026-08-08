import 'package:flutter/material.dart';

/// بيانات حجز ثابتة للعرض (مستخدمة في سلسلة المالك القديمة قبل ربط الـ API).
class BookingData {
  final String tenantName, title, location, price, period, status, dateRange;
  final String bookingDate, arrivalDate, departureDate;
  final String tenantEmail, tenantSince, tenantPhone;
  final Color statusColor, badgeBg;
  final int guestCount, nights;
  final double totalPrice, serviceFee, tax;
  const BookingData({
    required this.tenantName, required this.title, required this.location,
    required this.price, required this.period, required this.status,
    required this.statusColor, required this.badgeBg, required this.dateRange,
    required this.bookingDate, required this.arrivalDate, required this.departureDate,
    required this.guestCount, required this.nights,
    required this.totalPrice, required this.serviceFee, required this.tax,
    required this.tenantEmail, required this.tenantSince, required this.tenantPhone,
  });
}