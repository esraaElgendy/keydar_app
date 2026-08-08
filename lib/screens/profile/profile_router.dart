import 'package:flutter/material.dart';
import '../../core/constants/account_type.dart';
import '../account/account_screen.dart';
import 'profile_screen.dart';

class ProfileRouter extends StatelessWidget {
  const ProfileRouter({super.key});

  @override
  Widget build(BuildContext context) {
    if (AccountType.current == AccountType.owner) {
      return const AccountScreen();
    }
    return const ProfileScreen();
  }
}
