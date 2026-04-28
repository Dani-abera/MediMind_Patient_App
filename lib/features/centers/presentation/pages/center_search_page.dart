import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/feedback/app_shimmer.dart';
import '../../domain/usecases/get_centers_usecase.dart';
import '../bloc/centers_bloc.dart';
import '../bloc/centers_event.dart';
import '../bloc/centers_state.dart';
import '../widgets/center_card.dart';

class CenterSearchPage extends StatefulWidget {
  const CenterSearchPage({super.key});

  @override
  State<CenterSearchPage> createState() => _CenterSearchPageState();
}

class _CenterSearchPageState extends State<CenterSearchPage> {
  final _searchController = TextEditingController();
  String? _selectedSpecialization;
  bool _mapView = false;

  static const _specializations = [
    'General', 'Cardiology', 'Dentistry', 'Pediatrics',
    'Orthopedics', 'Dermatology', 'Neurology',
  ];

  @override
  void initState() {
    super.initState();
    context.read<CentersBloc>().add(const CentersRequested());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final bloc = context.read<CentersBloc>();
    final current = bloc.state;
    final base = current is CentersLoaded
        ? current.filters
        : const CenterFilters();
    bloc.add(CentersRequested(
      filters: base.copyWith(
        name: _searchController.text.isEmpty ? null : _searchController.text,
        specialization: _selectedSpecialization,
        page: 1,
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        title: const Text('Find a Center'),
        actions: [
          IconButton(
            icon: Icon(
              _mapView ? Icons.list_rounded : Icons.map_outlined,
            ),
            onPressed: () => setState(() => _mapView = !_mapView),
            tooltip: _mapView ? 'List View' : 'Map View',
          ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            onSubmitted: (_) => _search(),
          ),
          _FilterChips(
            selected: _selectedSpecialization,
            specializations: _specializations,
            onSelected: (s) {
              setState(() {
                _selectedSpecialization =
                    _selectedSpecialization == s ? null : s;
              });
              _search();
            },
          ),
          Expanded(
            child: _mapView ? const _MapPlaceholder() : const _ListView(),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller, required this.onSubmitted});
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: TextField(
        controller: controller,
        onSubmitted: onSubmitted,
        decoration: InputDecoration(
          hintText: 'Search centers by name or city…',
          prefixIcon: const Icon(Icons.search_rounded),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    controller.clear();
                    onSubmitted('');
                  },
                )
              : null,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.neutral300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.neutral300),
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        ),
      ),
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.selected,
    required this.specializations,
    required this.onSelected,
  });

  final String? selected;
  final List<String> specializations;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        scrollDirection: Axis.horizontal,
        itemCount: specializations.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, i) {
          final s = specializations[i];
          final isSelected = selected == s;
          return FilterChip(
            label: Text(s),
            selected: isSelected,
            onSelected: (_) => onSelected(s),
            selectedColor: AppColors.primary.withValues(alpha: 0.15),
            checkmarkColor: AppColors.primary,
            labelStyle: AppTypography.caption.copyWith(
              color:
                  isSelected ? AppColors.primary : AppColors.neutral700,
              fontWeight:
                  isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          );
        },
      ),
    );
  }
}

class _ListView extends StatelessWidget {
  const _ListView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CentersBloc, CentersState>(
      builder: (context, state) {
        if (state is CentersLoading) {
          return const _CentersShimmer();
        }

        if (state is CentersError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded,
                    size: 48.r, color: AppColors.neutral300),
                SizedBox(height: 12.h),
                Text(state.message, style: AppTypography.body),
                SizedBox(height: 16.h),
                TextButton(
                  onPressed: () => context
                      .read<CentersBloc>()
                      .add(const CentersRefreshed()),
                  child: const Text('Try again'),
                ),
              ],
            ),
          );
        }

        final centers = switch (state) {
          CentersLoaded(centers: final c) => c,
          CentersLoadingMore(centers: final c) => c,
          _ => <dynamic>[],
        };

        if (centers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off_rounded,
                    size: 48.r, color: AppColors.neutral300),
                SizedBox(height: 12.h),
                Text('No centers found.',
                    style: AppTypography.body),
                Text('Try expanding your search.',
                    style: AppTypography.caption),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            context
                .read<CentersBloc>()
                .add(const CentersRefreshed());
            await context
                .read<CentersBloc>()
                .stream
                .firstWhere((s) => s is CentersLoaded || s is CentersError);
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              if (n is ScrollEndNotification &&
                  n.metrics.extentAfter < 200 &&
                  state is CentersLoaded &&
                  (state).hasMore) {
                context
                    .read<CentersBloc>()
                    .add(const CentersLoadMore());
              }
              return false;
            },
            child: ListView.separated(
              padding: EdgeInsets.all(16.r),
              itemCount: centers.length +
                  (state is CentersLoadingMore ? 1 : 0),
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, i) {
                if (i >= centers.length) {
                  return const Center(
                      child: CircularProgressIndicator());
                }
                final center = centers[i];
                return CenterCard(
                  center: center,
                  onTap: () =>
                      context.push('/book/center/${center.id}'),
                  onFavoriteToggle: () => context
                      .read<CentersBloc>()
                      .add(CenterFavoriteToggled(center.id)),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, size: 64, color: AppColors.neutral300),
          SizedBox(height: 12),
          Text('Map view coming soon'),
        ],
      ),
    );
  }
}

class _CentersShimmer extends StatelessWidget {
  const _CentersShimmer();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.all(16.r),
      itemCount: 4,
      separatorBuilder: (_, __) => SizedBox(height: 12.h),
      itemBuilder: (_, __) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppShimmer.box(
              width: double.infinity, height: 140.h, radius: 12),
          SizedBox(height: 8.h),
          AppShimmer.line(width: 200.w),
          SizedBox(height: 4.h),
          AppShimmer.line(width: 120.w, height: 12),
        ],
      ),
    );
  }
}
