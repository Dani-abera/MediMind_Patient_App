import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/favorite.dart';
import '../bloc/favorites_bloc.dart';
import '../bloc/favorites_event.dart';
import '../bloc/favorites_state.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    context.read<FavoritesBloc>().add(const FavoritesRequested());
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Favorites', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.neutral500,
          indicatorColor: AppColors.primary,
          tabs: const [Tab(text: 'Doctors'), Tab(text: 'Centers')],
        ),
      ),
      body: BlocBuilder<FavoritesBloc, FavoritesState>(
        builder: (context, state) {
          if (state is FavoritesLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is FavoritesFailure) {
            return Center(child: Text(state.message, style: AppTypography.body));
          }
          if (state is FavoritesLoaded) {
            return TabBarView(
              controller: _tabs,
              children: [
                _DoctorsList(doctors: state.doctors),
                _CentersList(centers: state.centers),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _DoctorsList extends StatelessWidget {
  const _DoctorsList({required this.doctors});
  final List<FavoriteDoctor> doctors;

  @override
  Widget build(BuildContext context) {
    if (doctors.isEmpty) {
      return const _EmptyView(
          icon: Icons.person_outline, label: 'No favorite doctors');
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: doctors.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _DoctorCard(
        doctor: doctors[i],
        onRemove: () => context.read<FavoritesBloc>().add(
            FavoriteDoctorToggled(doctors[i].doctorId,
                isFavorite: false)),
        onTap: () => context.pushNamed(RouteNames.doctorDetail,
            pathParameters: {'id': doctors[i].doctorId}),
      ),
    );
  }
}

class _CentersList extends StatelessWidget {
  const _CentersList({required this.centers});
  final List<FavoriteCenter> centers;

  @override
  Widget build(BuildContext context) {
    if (centers.isEmpty) {
      return const _EmptyView(
          icon: Icons.local_hospital_outlined,
          label: 'No favorite centers');
    }
    return ListView.separated(
      padding: EdgeInsets.all(16.w),
      itemCount: centers.length,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, i) => _CenterCard(
        center: centers[i],
        onRemove: () => context.read<FavoritesBloc>().add(
            FavoriteCenterToggled(centers[i].centerId,
                isFavorite: false)),
        onTap: () => context.pushNamed(RouteNames.centerDetail,
            pathParameters: {'id': centers[i].centerId}),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard(
      {required this.doctor, required this.onRemove, required this.onTap});
  final FavoriteDoctor doctor;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SwipeToRemoveCard(
      key: Key(doctor.doctorId),
      onRemove: onRemove,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                backgroundImage: doctor.avatarUrl != null
                    ? NetworkImage(doctor.avatarUrl!)
                    : null,
                child: doctor.avatarUrl == null
                    ? Text(doctor.fullName[0],
                        style: AppTypography.title
                            .copyWith(color: AppColors.primary))
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Dr. ${doctor.fullName}',
                        style: AppTypography.subtitle),
                    Text(doctor.specialty, style: AppTypography.caption),
                    if (doctor.centerName != null)
                      Text(doctor.centerName!,
                          style: AppTypography.caption),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded,
                      size: 16.sp, color: AppColors.warning),
                  SizedBox(width: 2.w),
                  Text(doctor.rating.toStringAsFixed(1),
                      style: AppTypography.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterCard extends StatelessWidget {
  const _CenterCard(
      {required this.center, required this.onRemove, required this.onTap});
  final FavoriteCenter center;
  final VoidCallback onRemove;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SwipeToRemoveCard(
      key: Key(center.centerId),
      onRemove: onRemove,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.neutral900.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  image: center.imageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(center.imageUrl!),
                          fit: BoxFit.cover)
                      : null,
                  color: AppColors.primary.withValues(alpha: 0.12),
                ),
                child: center.imageUrl == null
                    ? Icon(Icons.local_hospital_outlined,
                        color: AppColors.primary, size: 24.sp)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(center.name, style: AppTypography.subtitle),
                    Text(center.type, style: AppTypography.caption),
                    if (center.address != null)
                      Text(center.address!,
                          style: AppTypography.caption),
                  ],
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded,
                      size: 16.sp, color: AppColors.warning),
                  SizedBox(width: 2.w),
                  Text(center.rating.toStringAsFixed(1),
                      style: AppTypography.caption),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SwipeToRemoveCard extends StatelessWidget {
  const _SwipeToRemoveCard(
      {super.key, required this.child, required this.onRemove});
  final Widget child;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Icon(Icons.favorite_border,
            color: AppColors.white, size: 24.sp),
      ),
      confirmDismiss: (_) async {
        onRemove();
        return false;
      },
      child: child,
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64.sp, color: AppColors.neutral300),
          SizedBox(height: 16.h),
          Text(label, style: AppTypography.subtitle),
        ],
      ),
    );
  }
}
