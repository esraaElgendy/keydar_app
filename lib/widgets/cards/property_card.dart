import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/property.dart';
import '../property_image.dart';

class PropertyCard extends StatelessWidget {
  final Property property;
  final bool isFavorite;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onTap;

  const PropertyCard({
    super.key,
    required this.property,
    this.isFavorite = false,
    this.onFavoriteTap,
    this.onTap,
  });

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
                PropertyImage(
                  imageUrl: property.imageUrl,
                  height: 115,
                  width: double.infinity,
                ),
                Positioned(top: 0, left: 0, right: 0, bottom: 0, child: Center(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.only(right: 4),
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                          child: const Icon(Icons.arrow_back_ios, size: 10, color: Colors.white70),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () {},
                        child: Container(
                          margin: const EdgeInsets.only(left: 4),
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.black26),
                          child: const Icon(Icons.arrow_forward_ios, size: 10, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                )),
                Positioned(bottom: 6, left: 0, right: 0, child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    width: 5, height: 5,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: i == 0 ? AppColors.white : AppColors.white.withValues(alpha: 0.4),
                    ),
                  )),
                )),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Row(
                    children: [
                      if (property.badge2 != null)
                        _Badge(text: property.badge2!, color: AppColors.grey, textColor: AppColors.darkGrey),
                      const SizedBox(width: 4),
                      _Badge(text: property.badge1, color: const Color(0xFFE8F5E9), textColor: const Color(0xFF2E7D32)),
                    ],
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? AppColors.primary : AppColors.white,
                      size: 22,
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
                    Text(
                      property.type,
                      style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.7)),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Text(
                          property.rating.toString(),
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.black),
                        ),
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  property.title,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      property.location,
                      style: const TextStyle(fontSize: 11, color: AppColors.primary),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.location_on, color: AppColors.primary, size: 12),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      property.price,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(width: 2),
                    Text(
                      property.period,
                      style: TextStyle(fontSize: 10, color: AppColors.grey.withValues(alpha: 0.6)),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Spec(icon: Icons.bed_outlined, text: '${property.bedrooms} غرف'),
                    const SizedBox(width: 8),
                    _Spec(icon: Icons.bathtub_outlined, text: '${property.bathrooms} حمام'),
                    const SizedBox(width: 8),
                    _Spec(icon: Icons.straighten, text: '${property.area} م²'),
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

class _Badge extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;
  const _Badge({required this.text, required this.color, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(text, style: TextStyle(fontSize: 9, color: textColor, fontWeight: FontWeight.w600)),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Spec({required this.icon, required this.text});

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
