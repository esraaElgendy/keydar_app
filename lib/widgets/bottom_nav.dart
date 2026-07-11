import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNav({super.key, required this.currentIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_items.length, (i) {
              final item = _items[i];
              final active = i == currentIndex;
              return GestureDetector(
                onTap: () => onTap(i),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: active ? AppColors.primary : AppColors.grey, size: 24),
                    const SizedBox(height: 2),
                    Text(item.label, style: TextStyle(fontSize: 11, color: active ? AppColors.primary : AppColors.grey)),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}

const List<_NavItem> _items = [
  _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
  _NavItem(icon: Icons.explore_rounded, label: 'استكشف'),
  _NavItem(icon: Icons.calendar_today_rounded, label: 'حجوزاتي'),
  _NavItem(icon: Icons.favorite_rounded, label: 'المفضلة'),
  _NavItem(icon: Icons.person_outline_rounded, label: 'حسابي'),
];
