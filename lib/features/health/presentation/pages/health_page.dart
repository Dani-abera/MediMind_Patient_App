import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/theme/app_typography.dart';
import 'tabs/vitals_tab.dart';
import 'tabs/predictions_tab.dart';
import 'tabs/medications_tab.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Health', style: AppTypography.title),
        centerTitle: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral500,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: AppTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 12.sp,
          ),
          tabs: const [
            Tab(text: 'Vitals'),
            Tab(text: 'Predictions'),
            Tab(text: 'Medications'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          VitalsTab(),
          PredictionsTab(),
          MedicationsTab(),
        ],
      ),
    );
  }
}
