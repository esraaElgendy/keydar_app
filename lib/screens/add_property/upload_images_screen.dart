import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../controllers/app_controller.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/property_repository.dart';

/// شاشة رفع صور + فيديو العقار بعد إنشائه.
class UploadImagesScreen extends StatefulWidget {
  final int propertyId;
  final String propertyTitle;

  const UploadImagesScreen({
    super.key,
    required this.propertyId,
    required this.propertyTitle,
  });

  @override
  State<UploadImagesScreen> createState() => _UploadImagesScreenState();
}

class _UploadImagesScreenState extends State<UploadImagesScreen> {
  final List<File> _selectedImages = [];
  File? _selectedVideo;
  List<UploadedImage> _uploadedImages = [];
  bool _uploading = false;
  bool _done = false;
  String _uploadStatus = '';
  bool _videoUploaded = false;

  // ═══════════════════════════════════════════════
  //  اختيار الصور والفيديو
  // ═══════════════════════════════════════════════

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final images = await picker.pickMultiImage(imageQuality: 85);
    if (images.isNotEmpty) {
      setState(() => _selectedImages.addAll(images.map((e) => File(e.path))));
    }
  }

  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final video = await picker.pickVideo(source: ImageSource.gallery, maxDuration: const Duration(minutes: 5));
    if (video != null) {
      final file = File(video.path);
      final sizeInMb = await file.length() / (1024 * 1024);
      if (sizeInMb > 50) {
        Get.snackbar('ملف كبير جداً', 'الحد الأقصى لحجم الفيديو 50 ميجا',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFFF6F00), colorText: Colors.white);
        return;
      }
      setState(() => _selectedVideo = file);
    }
  }

  void _removeImage(int index) => setState(() => _selectedImages.removeAt(index));
  void _removeVideo() => setState(() => _selectedVideo = null);

  // ═══════════════════════════════════════════════
  //  رفع الصور والفيديو
  // ═══════════════════════════════════════════════

  Future<void> _uploadAll() async {
    if (_selectedImages.isEmpty && _selectedVideo == null) return;

    setState(() {
      _uploading = true;
      _uploadStatus = '';
    });

    try {
      // ── رفع الصور ──
      if (_selectedImages.isNotEmpty) {
        setState(() => _uploadStatus = 'جاري رفع الصور...');
        final paths = _selectedImages.map((f) => f.path).toList();
        final result = await PropertyRepository().uploadPropertyImages(
          propertyId: widget.propertyId,
          files: paths,
        );
        setState(() => _uploadedImages = result);
      }

      // ── رفع الفيديو ──
      if (_selectedVideo != null) {
        setState(() => _uploadStatus = 'جاري رفع الفيديو...');
        final success = await PropertyRepository().uploadPropertyVideo(
          propertyId: widget.propertyId,
          filePath: _selectedVideo!.path,
        );
        setState(() => _videoUploaded = success);
        if (success) {
          Get.snackbar('تم رفع الفيديو', 'تم رفع فيديو العقار بنجاح',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary, colorText: Colors.white);
        }
      }

      setState(() {
        _done = true;
        _uploadStatus = '';
      });
    } catch (e) {
      Get.snackbar('فشل الرفع', 'تعذر رفع الملفات، حاول مرة أخرى',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFC62828), colorText: Colors.white);
    }

    setState(() => _uploading = false);
  }

  void _finish() {
    Get.find<AppController>().refreshOwnerProperty(widget.propertyId);
    Get.back();
    Get.back();
  }

  Future<void> _deleteImage(UploadedImage image) async {
    final confirm = await Get.defaultDialog<bool>(
      title: 'حذف الصورة',
      middleText: 'هل أنت متأكد من حذف هذه الصورة؟',
      textConfirm: 'حذف',
      textCancel: 'إلغاء',
      confirmTextColor: Colors.white,
      buttonColor: const Color(0xFFC62828),
      onConfirm: () => Get.back(result: true),
      onCancel: () => Get.back(result: false),
    );

    if (confirm != true) return;

    try {
      final success = await PropertyRepository().deletePropertyImage(
        propertyId: widget.propertyId,
        imageId: image.id,
      );
      if (success) {
        setState(() => _uploadedImages.removeWhere((e) => e.id == image.id));
        Get.snackbar('تم الحذف', 'تم حذف الصورة بنجاح',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.primary, colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('خطأ', 'تعذر حذف الصورة',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFFC62828), colorText: Colors.white);
    }
  }

  // ═══════════════════════════════════════════════
  //  البناء
  // ═══════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('صور وفيديو العقار', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.darkText)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: _done ? _finish : () => Get.back(),
        ),
      ),
      body: Column(
        children: [
          // ── معلومات العقار ──
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
            ),
            child: Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.home_work, color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.propertyTitle, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                      const SizedBox(height: 2),
                      Text('ID: ${widget.propertyId}', style: TextStyle(fontSize: 12, color: AppColors.grey.withValues(alpha: 0.6))),
                    ],
                  ),
                ),
                if (_done)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(8)),
                    child: const Text('تم الرفع', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32))),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── المحتوى ──
          Expanded(
            child: _done ? _buildSuccessView() : _buildPickerView(),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  وضع الاختيار والرفع
  // ═══════════════════════════════════════════════

  Widget _buildPickerView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // ── اختيار الصور ──
          GestureDetector(
            onTap: _uploading ? null : _pickImages,
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 32, color: AppColors.primary.withValues(alpha: 0.6)),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('إضافة صور', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.primary.withValues(alpha: 0.8))),
                      Text('اختر عدة صور مرة واحدة', style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.5))),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ── اختيار الفيديو ──
          GestureDetector(
            onTap: _uploading ? null : _pickVideo,
            child: Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _selectedVideo != null
                      ? AppColors.primary
                      : AppColors.primary.withValues(alpha: 0.15),
                  width: _selectedVideo != null ? 2 : 1.5,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.videocam_outlined, size: 32,
                      color: _selectedVideo != null
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.4)),
                  const SizedBox(width: 10),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_selectedVideo != null ? 'تم اختيار الفيديو' : 'إضافة فيديو',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600,
                              color: _selectedVideo != null ? AppColors.primary : AppColors.primary.withValues(alpha: 0.6))),
                      Text(_selectedVideo != null ? 'حد أقصى 50 ميجا' : 'اختياري — فيديو واحد فقط',
                          style: TextStyle(fontSize: 11, color: AppColors.grey.withValues(alpha: 0.5))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── الصور المختارة ──
          if (_selectedImages.isNotEmpty) ...[
            Row(
              children: [
                Text('الصور (${_selectedImages.length})',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                const Spacer(),
                if (!_uploading)
                  GestureDetector(
                    onTap: () => setState(() => _selectedImages.clear()),
                    child: const Text('مسح الكل', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selectedImages.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (_, i) => Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(_selectedImages[i], width: 90, height: 90, fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4, left: 4,
                      child: GestureDetector(
                        onTap: _uploading ? null : () => _removeImage(i),
                        child: Container(
                          width: 22, height: 22,
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, size: 12, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // ── الفيديو المختار ──
          if (_selectedVideo != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.videocam, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                const Text('الفيديو المختار', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                const Spacer(),
                if (!_uploading)
                  GestureDetector(
                    onTap: _removeVideo,
                    child: const Text('إزالة', style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              height: 60,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 28),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(_selectedVideo!.path.split('/').last,
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13, color: AppColors.black)),
                  ),
                ],
              ),
            ),
          ],

          const Spacer(),

          // ── زر الرفع ──
          if ((_selectedImages.isNotEmpty || _selectedVideo != null) && !_done)
            Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: SizedBox(
                width: double.infinity, height: 52,
                child: ElevatedButton(
                  onPressed: _uploading ? null : _uploadAll,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 4,
                  ),
                  child: _uploading
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)),
                            const SizedBox(width: 12),
                            Text(_uploadStatus, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.cloud_upload, size: 20),
                            const SizedBox(width: 8),
                            Text(_buildUploadButtonText(), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _buildUploadButtonText() {
    final parts = <String>[];
    if (_selectedImages.isNotEmpty) parts.add('${_selectedImages.length} صور');
    if (_selectedVideo != null) parts.add('فيديو');
    return 'رفع ${parts.join(' و ')}';
  }

  // ═══════════════════════════════════════════════
  //  وضع النجاح
  // ═══════════════════════════════════════════════

  Widget _buildSuccessView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 48),
                const SizedBox(height: 12),
                Text(
                  _uploadedImages.isNotEmpty && _videoUploaded
                      ? 'تم رفع ${_uploadedImages.length} صور + فيديو بنجاح'
                      : _uploadedImages.isNotEmpty
                          ? 'تم رفع ${_uploadedImages.length} صور بنجاح'
                          : 'تم رفع الفيديو بنجاح',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF2E7D32)),
                ),
                const SizedBox(height: 4),
                const Text('ستظهر الوسائط للعملاء عند تصفح العقار',
                    style: TextStyle(fontSize: 13, color: Color(0xFF4CAF50))),
              ],
            ),
          ),
          if (_uploadedImages.isNotEmpty) ...[
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10,
                ),
                itemCount: _uploadedImages.length,
                itemBuilder: (_, i) => _NetworkImageTile(
                  image: _uploadedImages[i],
                  onDelete: () => _deleteImage(_uploadedImages[i]),
                ),
              ),
            ),
          ] else
            const Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton(
                onPressed: _finish,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                child: const Text('تم', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════
//  مكونات الصور
// ═══════════════════════════════════════════════

class _NetworkImageTile extends StatelessWidget {
  final UploadedImage image;
  final VoidCallback? onDelete;
  const _NetworkImageTile({required this.image, this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            image.fullUrl,
            width: double.infinity, height: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              color: AppColors.fieldBorder,
              child: const Icon(Icons.broken_image, color: AppColors.grey, size: 28),
            ),
          ),
        ),
        if (image.isPrimary)
          Positioned(
            top: 4, right: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
              child: const Text('رئيسية', style: TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        if (onDelete != null)
          Positioned(
            top: 4, left: 4,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                width: 24, height: 24,
                decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline, size: 14, color: Colors.white),
              ),
            ),
          ),
      ],
    );
  }
}
