import 'package:flutter/material.dart';
import '../core/constants/app_assets.dart';
import '../core/constants/app_colors.dart';

/// صورة عقار تظهر من الـ network إن وُجدت وإلا من مَورد محلي.
/// عند فشل كليهما يعرض أيقونة صورة رمادية (لا يكسر الشكل أبداً).
class PropertyImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackAsset;
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;

  const PropertyImage({
    super.key,
    this.imageUrl,
    this.fallbackAsset = AppAssets.building,
    required this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    final useNetwork = url != null && url.isNotEmpty;

    Widget child;
    if (useNetwork) {
      child = Image.network(
        url,
        height: height,
        width: width,
        fit: fit,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            height: height,
            width: width,
            color: AppColors.fieldBg,
            child: const Center(
              child: SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
              ),
            ),
          );
        },
        errorBuilder: (_, _, _) => _fallback(),
      );
    } else {
      child = Image.asset(
        fallbackAsset,
        height: height,
        width: width,
        fit: fit,
        errorBuilder: (_, _, _) => _fallback(),
      );
    }

    if (borderRadius == null) return child;
    return ClipRRect(borderRadius: borderRadius!, child: child);
  }

  Widget _fallback() {
    return Container(
      height: height,
      width: width,
      color: AppColors.fieldBorder,
      child: const Icon(Icons.image_outlined, color: AppColors.grey, size: 40),
    );
  }
}