import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final String? price;
  final String? period;
  const BookingConfirmationScreen({super.key, this.price, this.period});

  @override
  State<BookingConfirmationScreen> createState() => _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentPrice {
    final prices = ['2,300,000', '195,000', '2,300,000'];
    return prices[_selectedTab];
  }

  String get _currentPeriodLabel {
    final labels = ['يوم', 'شهر', 'سنة'];
    return labels[_selectedTab];
  }

  String get _currentPeriodFull {
    final labels = ['يوم واحد', 'شهر واحد (30 يوماً)', 'سنة واحدة (12 شهراً)'];
    return labels[_selectedTab];
  }

  String get _currentUnitPrice {
    final prices = ['2,300,000', '195,000', '2,300,000'];
    return prices[_selectedTab];
  }

  String get _currentServiceFee {
    final fees = ['+5,000 ريال', '+10,000 ريال', '+50,000 ريال'];
    return fees[_selectedTab];
  }

  String get _currentTotal {
    final totals = ['2,305,000', '205,000', '2,350,000'];
    return totals[_selectedTab];
  }

  String get _currentPayNow {
    final amounts = ['2,305,000', '205,000', '2,350,000'];
    return amounts[_selectedTab];
  }

  void _showEditPeriodDialog() {
    final options = ['يوم واحد', 'شهر واحد (30 يوماً)', 'سنة واحدة (12 شهراً)'];
    Get.bottomSheet(
      Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Center(
                  child: Container(
                    width: 40, height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.fieldBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('اختر مدة الإيجار',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black)),
                const SizedBox(height: 16),
                ...options.asMap().entries.map((e) => GestureDetector(
                  onTap: () {
                    setState(() => _selectedTab = e.key);
                    _tabController.animateTo(e.key);
                    Get.back();
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: e.key == _selectedTab ? AppColors.primary.withValues(alpha: 0.1) : AppColors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: e.key == _selectedTab ? AppColors.primary : AppColors.fieldBorder,
                      ),
                    ),
                    child: Row(
                      children: [
                        Text(e.value,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: e.key == _selectedTab ? AppColors.primary : AppColors.black,
                          )),
                        const Spacer(),
                        if (e.key == _selectedTab)
                          const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
                      ],
                    ),
                  ),
                )),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          _AppBar(tabController: _tabController, selectedTab: _selectedTab),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _PriceCard(price: _currentPrice, periodLabel: _currentPeriodLabel),
                  const SizedBox(height: 16),
                  _DurationCard(fullPeriod: _currentPeriodFull, onEdit: _showEditPeriodDialog),
                  const SizedBox(height: 16),
                  _DateRow(),
                  const SizedBox(height: 16),
                  _TimeRow(),
                  const SizedBox(height: 20),
                  _PayNowSection(amount: _currentPayNow),
                  const SizedBox(height: 16),
                  _CostBreakdown(
                    unitLabel: '$_currentPeriodLabel واحد × $_currentUnitPrice ريال',
                    unitPrice: '$_currentUnitPrice ريال',
                    serviceFee: _currentServiceFee,
                    total: _currentTotal,
                  ),
                ],
              ),
            ),
          ),
          _BottomButton(),
        ],
      ),
    );
  }
}

class _AppBar extends StatelessWidget {
  final TabController tabController;
  final int selectedTab;
  const _AppBar({required this.tabController, required this.selectedTab});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: const Icon(Icons.arrow_forward, color: AppColors.black, size: 24),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      'تأكيد الحجز',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
                    ),
                  ),
                ),
                const Icon(Icons.more_horiz, color: AppColors.black, size: 24),
              ],
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F1F1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TabBar(
              controller: tabController,
              indicator: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.white,
              unselectedLabelColor: AppColors.grey,
              labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              unselectedLabelStyle: const TextStyle(fontSize: 14),
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: 'يومي'),
                Tab(text: 'شهري'),
                Tab(text: 'سنوي'),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final String price;
  final String periodLabel;
  const _PriceCard({required this.price, required this.periodLabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Text(
            price,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.black),
          ),
          const SizedBox(height: 2),
          Text(
            'ريال / $periodLabel',
            style: const TextStyle(fontSize: 13, color: AppColors.grey),
          ),
        ],
      ),
    );
  }
}

class _DurationCard extends StatelessWidget {
  final String fullPeriod;
  final VoidCallback? onEdit;
  const _DurationCard({required this.fullPeriod, this.onEdit});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                fullPeriod,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black),
              ),
              const SizedBox(height: 2),
              Text(
                'بإمكانك تعديل مدة الإيجار',
                style: const TextStyle(fontSize: 11, color: AppColors.grey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              GestureDetector(
                onTap: onEdit,
                child: const Row(
                  children: [
                    Icon(Icons.edit, size: 14, color: AppColors.grey),
                    SizedBox(width: 4),
                    Text('تعديل', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('تاريخ الوصول', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('الأربعاء، 29 أكتوبر',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                    Text('2025',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                  ],
                ),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.fieldBorder),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('تاريخ المغادرة', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                    const SizedBox(width: 4),
                    Icon(Icons.calendar_today, size: 14, color: AppColors.primary),
                  ],
                ),
                const SizedBox(height: 6),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('الجمعة، 31 أكتوبر',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                    Text('2026',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: AppColors.grey),
                    const SizedBox(width: 4),
                    Text('وقت الوصول', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('5:00 مساء',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
              ],
            ),
          ),
          Container(width: 1, height: 50, color: AppColors.fieldBorder),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text('وقت المغادرة', style: TextStyle(fontSize: 11, color: AppColors.grey)),
                    const SizedBox(width: 4),
                    Icon(Icons.access_time, size: 14, color: AppColors.grey),
                  ],
                ),
                const SizedBox(height: 6),
                Text('12:00 مساء',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PayNowSection extends StatelessWidget {
  final String amount;
  const _PayNowSection({required this.amount});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          const Text(
            'ستدفع الآن',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black),
          ),
          const SizedBox(height: 4),
          Text(
            '$amount ريال',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.black),
          ),
        ],
      ),
    );
  }
}

class _CostBreakdown extends StatelessWidget {
  final String unitLabel;
  final String unitPrice;
  final String serviceFee;
  final String total;
  const _CostBreakdown({
    required this.unitLabel,
    required this.unitPrice,
    required this.serviceFee,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(unitLabel,
                      textAlign: TextAlign.right,
                      style: TextStyle(fontSize: 12, color: AppColors.grey))),
                    Text(unitPrice,
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.black)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text('رسوم الخدمات',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                        color: Colors.orange.shade800)),
                    const Spacer(),
                    Text(serviceFee,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(14)),
            ),
            child: Row(
              children: [
                const Text('المجموع الكلي',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.black)),
                const Spacer(),
                Text(total,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 6,
              shadowColor: AppColors.primary.withValues(alpha: 0.3),
            ),
            child: const Text('تأكيد الحجز و الدفع',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}
