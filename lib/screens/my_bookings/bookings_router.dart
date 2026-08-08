import 'package:flutter/material.dart';
import '../../core/constants/account_type.dart';
import 'owner_bookings_screen.dart';
import 'my_bookings_screen.dart';

class BookingsRouter extends StatelessWidget {
  const BookingsRouter({super.key});

  @override
  Widget build(BuildContext context) {
    if (AccountType.current == AccountType.owner) {
      return const OwnerBookingsScreen();
    }
    return const MyBookingsScreen();
  }
}
