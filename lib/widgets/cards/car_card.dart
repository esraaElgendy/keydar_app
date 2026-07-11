import 'package:flutter/material.dart';
import '../../core/constants/app_assets.dart';
import '../../core/constants/app_colors.dart';
import '../../models/property.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const CarCard({super.key, required this.car, this.isFavorite = false, this.onFavoriteTap, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: Stack(
              children: [
                Image.asset(
                  AppAssets.car,
                  height: 110,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    height: 110,
                    color: AppColors.fieldBorder,
                    child: const Icon(Icons.directions_car_outlined, color: AppColors.grey, size: 40),
                  ),
                ),
                if (car.isAvailable)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('متاحة الآن', style: TextStyle(fontSize: 9, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                    ),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : AppColors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(car.category, style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.7))),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        Text(car.rating.toString(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${car.name} ${car.model}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(car.price,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(width: 2),
                    Text('/ ${car.period}',
                        style: TextStyle(fontSize: 10, color: AppColors.grey.withValues(alpha: 0.6))),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _CarSpec(icon: Icons.people_outline, text: '${car.seats} ركاب'),
                    const SizedBox(width: 8),
                    _CarSpec(icon: Icons.local_gas_station, text: car.fuel),
                    const SizedBox(width: 8),
                    _CarSpec(icon: Icons.settings, text: car.transmission),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _CarSpec extends StatelessWidget {
  final IconData icon;
  final String text;
  const _CarSpec({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: TextStyle(fontSize: 10, color: AppColors.grey.withValues(alpha: 0.6))),
        const SizedBox(width: 2),
        Icon(icon, size: 12, color: AppColors.grey.withValues(alpha: 0.5)),
      ],
    );
  }
}

extension on Car {
  String get period => 'شهرياً';
}
