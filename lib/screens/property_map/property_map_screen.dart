import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';

class PropertyMapScreen extends StatefulWidget {
  final double latitude;
  final double longitude;
  final String address;

  const PropertyMapScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    this.address = '',
  });

  @override
  State<PropertyMapScreen> createState() => _PropertyMapScreenState();
}

class _PropertyMapScreenState extends State<PropertyMapScreen> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final lat = widget.latitude;
    final lng = widget.longitude;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) {
          if (mounted) setState(() => _loading = false);
        },
      ))
      ..loadRequest(Uri.parse(
        'https://www.openstreetmap.org/?mlat=$lat&mlng=$lng#map=16/$lat/$lng',
      ));
  }

  Future<void> _openInGoogleMaps() async {
    final lat = widget.latitude;
    final lng = widget.longitude;
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        Get.snackbar('تنبيه', 'تعذر فتح خرائط جوجل', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      if (mounted) {
        Get.snackbar('تنبيه', 'تعذر فتح خرائط جوجل', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _getDirections() async {
    final lat = widget.latitude;
    final lng = widget.longitude;
    final uri = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving');
    try {
      final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!opened && mounted) {
        Get.snackbar('تنبيه', 'تعذر فتح الاتجاهات', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (_) {
      if (mounted) {
        Get.snackbar('تنبيه', 'تعذر فتح الاتجاهات', snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.latitude;
    final lng = widget.longitude;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.darkText, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('موقع العقار', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.darkText)),
            if (widget.address.isNotEmpty)
              Text(widget.address, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.7))),
          ],
        ),
        centerTitle: false,
        actions: [
          TextButton.icon(
            onPressed: _getDirections,
            icon: const Icon(Icons.directions_outlined, size: 18, color: Colors.white),
            label: const Text('اتجاهات', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white)),
            style: TextButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading)
            const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          Positioned(
            bottom: 24,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.12), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40, height: 40,
                        decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.location_on, color: AppColors.primary, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (widget.address.isNotEmpty)
                              Text(widget.address, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkText)),
                            Text('${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
                                style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.7))),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _getDirections,
                          icon: const Icon(Icons.directions_outlined, size: 16, color: Colors.white),
                          label: const Text('الاتجاهات', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _openInGoogleMaps,
                          icon: Icon(Icons.map_outlined, size: 16, color: AppColors.primary),
                          label: Text('فتح في خرائط جوجل', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            side: const BorderSide(color: AppColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
