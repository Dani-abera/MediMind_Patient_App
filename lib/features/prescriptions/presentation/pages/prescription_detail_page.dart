import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../domain/entities/prescription.dart';
import '../bloc/prescriptions_bloc.dart';
import '../bloc/prescriptions_event.dart';
import '../bloc/prescriptions_state.dart';

class PrescriptionDetailPage extends StatefulWidget {
  const PrescriptionDetailPage({super.key, required this.id});
  final String id;

  @override
  State<PrescriptionDetailPage> createState() =>
      _PrescriptionDetailPageState();
}

class _PrescriptionDetailPageState extends State<PrescriptionDetailPage> {
  @override
  void initState() {
    super.initState();
    context
        .read<PrescriptionsBloc>()
        .add(PrescriptionDetailRequested(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text('Prescription', style: AppTypography.title),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.neutral900,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            onPressed: () {},
          ),
        ],
      ),
      body: BlocBuilder<PrescriptionsBloc, PrescriptionsState>(
        builder: (context, state) {
          if (state is PrescriptionsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is PrescriptionsFailure) {
            return Center(
                child: Text(state.message, style: AppTypography.body));
          }
          if (state is PrescriptionDetailLoaded) {
            return _PrescriptionDetail(prescription: state.prescription);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _PrescriptionDetail extends StatelessWidget {
  const _PrescriptionDetail({required this.prescription});
  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _InfoCard(prescription: prescription),
          SizedBox(height: 16.h),
          if (prescription.medications.isNotEmpty) ...[
            Text('Medications', style: AppTypography.title),
            SizedBox(height: 8.h),
            ...prescription.medications
                .map((m) => _MedicationTile(medication: m)),
          ],
          if (prescription.labTests.isNotEmpty) ...[
            SizedBox(height: 16.h),
            Text('Lab Tests', style: AppTypography.title),
            SizedBox(height: 8.h),
            ...prescription.labTests.map((t) => _LabTestTile(test: t)),
          ],
          if (prescription.followUpInstructions != null) ...[
            SizedBox(height: 16.h),
            Text('Follow-up Instructions', style: AppTypography.title),
            SizedBox(height: 8.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(prescription.followUpInstructions!,
                  style: AppTypography.body),
            ),
          ],
          if (prescription.qrCodeBase64 != null) ...[
            SizedBox(height: 16.h),
            _QrSection(base64: prescription.qrCodeBase64!),
          ],
          SizedBox(height: 24.h),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.prescription});
  final Prescription prescription;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Row(label: 'Reference', value: prescription.referenceNumber),
          _Row(label: 'Diagnosis', value: prescription.diagnosis),
          _Row(label: 'Doctor', value: 'Dr. ${prescription.doctorName}'),
          _Row(label: 'Specialty', value: prescription.doctorSpecialty),
          _Row(
              label: 'Issued',
              value: _formatDate(prescription.issuedAt)),
          _Row(
              label: 'Expires',
              value: _formatDate(prescription.expiryDate)),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}/${d.month}/${d.year}';
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 90.w,
              child: Text(label, style: AppTypography.caption)),
          Expanded(child: Text(value, style: AppTypography.body)),
        ],
      ),
    );
  }
}

class _MedicationTile extends StatelessWidget {
  const _MedicationTile({required this.medication});
  final PrescriptionMedication medication;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(medication.name, style: AppTypography.subtitle),
          SizedBox(height: 4.h),
          Text(
            '${medication.dosage} · ${medication.frequency} · ${medication.durationDays} days',
            style: AppTypography.caption,
          ),
          if (medication.instructions != null) ...[
            SizedBox(height: 4.h),
            Text(medication.instructions!, style: AppTypography.caption),
          ],
        ],
      ),
    );
  }
}

class _LabTestTile extends StatelessWidget {
  const _LabTestTile({required this.test});
  final PrescriptionLabTest test;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.neutral300),
      ),
      child: Row(
        children: [
          Icon(Icons.science_outlined,
              size: 18.sp, color: AppColors.primary),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(test.testName, style: AppTypography.body),
                if (test.notes != null)
                  Text(test.notes!, style: AppTypography.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QrSection extends StatelessWidget {
  const _QrSection({required this.base64});
  final String base64;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('QR Code', style: AppTypography.title),
        SizedBox(height: 8.h),
        Center(
          child: Container(
            width: 160.w,
            height: 160.w,
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: AppColors.neutral300),
            ),
            child: Image.memory(
              base64Decode(base64),
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(Icons.qr_code,
                  size: 80, color: AppColors.neutral500),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Center(
          child: TextButton.icon(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: base64));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('QR data copied')),
              );
            },
            icon: const Icon(Icons.copy_rounded),
            label: const Text('Copy QR Data'),
          ),
        ),
      ],
    );
  }
}
