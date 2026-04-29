import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/emergency_contact.dart';
import '../bloc/emergency_contacts_bloc.dart';
import '../bloc/emergency_contacts_event.dart';
import '../bloc/emergency_contacts_state.dart';

class EmergencyContactsPage extends StatefulWidget {
  const EmergencyContactsPage({super.key});

  @override
  State<EmergencyContactsPage> createState() =>
      _EmergencyContactsPageState();
}

class _EmergencyContactsPageState extends State<EmergencyContactsPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<EmergencyContactsBloc>()
        .add(const EmergencyContactsRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Emergency Contacts', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
      ),
      floatingActionButton:
          BlocBuilder<EmergencyContactsBloc, EmergencyContactsState>(
        builder: (context, state) {
          final count = state is EmergencyContactsLoaded
              ? state.contacts.length
              : 0;
          if (count >= 3) return const SizedBox.shrink();
          return FloatingActionButton.extended(
            onPressed: () =>
                context.pushNamed(RouteNames.addEditContact),
            backgroundColor: AppColors.primary,
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text('Add Contact',
                style: AppTypography.body.copyWith(color: AppColors.white)),
          );
        },
      ),
      body: BlocConsumer<EmergencyContactsBloc, EmergencyContactsState>(
        listener: (context, state) {
          if (state is EmergencyContactsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is EmergencyContactsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is EmergencyContactsLoaded ||
              state is EmergencyContactsActionSuccess) {
            final contacts = state is EmergencyContactsLoaded
                ? state.contacts
                : (state as EmergencyContactsActionSuccess).contacts;
            if (contacts.isEmpty) {
              return const _EmptyView();
            }
            return ListView.separated(
              padding: EdgeInsets.all(16.w),
              itemCount: contacts.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, i) => _ContactCard(
                contact: contacts[i],
                onSetPrimary: () => context
                    .read<EmergencyContactsBloc>()
                    .add(EmergencyContactSetPrimary(contacts[i].id)),
                onDelete: () => _confirmDelete(context, contacts[i]),
                onEdit: () => context.pushNamed(RouteNames.addEditContact,
                    extra: contacts[i]),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, EmergencyContact contact) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Remove ${contact.fullName}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () {
                Navigator.pop(context);
                context
                    .read<EmergencyContactsBloc>()
                    .add(EmergencyContactDeleted(contact.id));
              },
              style: TextButton.styleFrom(foregroundColor: AppColors.danger),
              child: const Text('Delete')),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.contact,
    required this.onSetPrimary,
    required this.onDelete,
    required this.onEdit,
  });
  final EmergencyContact contact;
  final VoidCallback onSetPrimary;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(contact.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 16.w),
        decoration: BoxDecoration(
          color: AppColors.danger,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child:
            Icon(Icons.delete_outline, color: AppColors.white, size: 24.sp),
      ),
      confirmDismiss: (_) async {
        onDelete();
        return false;
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: contact.isPrimary
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
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
              child: Text(
                contact.fullName.isNotEmpty
                    ? contact.fullName[0].toUpperCase()
                    : '?',
                style: AppTypography.title
                    .copyWith(color: AppColors.primary),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(contact.fullName, style: AppTypography.subtitle),
                      if (contact.isPrimary) ...[
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 6.w, vertical: 2.h),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          child: Text('Primary',
                              style: AppTypography.overline
                                  .copyWith(color: AppColors.primary)),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 2.h),
                  Text(contact.relationship, style: AppTypography.caption),
                  Text(contact.phoneNumber, style: AppTypography.caption),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'primary') onSetPrimary();
                if (v == 'edit') onEdit();
                if (v == 'delete') onDelete();
              },
              itemBuilder: (_) => [
                if (!contact.isPrimary)
                  const PopupMenuItem(
                      value: 'primary', child: Text('Set as Primary')),
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(
                    value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.contact_phone_outlined,
              size: 64.sp, color: AppColors.neutral300),
          SizedBox(height: 16.h),
          Text('No emergency contacts', style: AppTypography.subtitle),
          SizedBox(height: 8.h),
          Text('Add up to 3 emergency contacts',
              style: AppTypography.body),
        ],
      ),
    );
  }
}
