import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../models/order_item.dart';

class AllOrdersScreen extends StatelessWidget {
  const AllOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FC),
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('جميع الطلبات', style: TextStyle(color: Color(0xFF1A1A24), fontSize: 16, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1A1A24), size: 20),
          onPressed: () => Get.back(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(20),
        itemCount: OrderItem.samples.length,
        separatorBuilder: (_, _) => const Divider(height: 1, color: Color(0xFFF2F4F7)),
        itemBuilder: (context, index) => _OrderTile(order: OrderItem.samples[index]),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final OrderItem order;
  const _OrderTile({required this.order});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: order.badgeColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(order.badgeText, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: order.badgeTextColor)),
                  ),
                  const SizedBox(width: 8),
                  Text(order.time, style: const TextStyle(fontSize: 11, color: AppColors.grey)),
                ],
              ),
              const SizedBox(height: 6),
              Text(order.name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1A1A24))),
              const SizedBox(height: 2),
              Text(order.subtitle, style: const TextStyle(fontSize: 12, color: AppColors.grey)),
            ],
          ),
          const Spacer(),
          const CircleAvatar(
            radius: 20,
            backgroundColor: Color(0xFFF2F4F7),
            child: Icon(Icons.person, color: AppColors.grey, size: 22),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.keyboard_arrow_down, color: AppColors.grey, size: 20),
        ],
      ),
    );
  }
}
