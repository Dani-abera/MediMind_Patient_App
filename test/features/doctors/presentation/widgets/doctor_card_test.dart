import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/features/doctors/domain/entities/doctor.dart';
import 'package:medimind/features/doctors/presentation/widgets/doctor_card.dart';

const _doctor = Doctor(
  id: 'd1',
  fullName: 'Jane Smith',
  specialization: 'Cardiologist',
  yearsExperience: 10,
  rating: 4.9,
  reviewCount: 85,
  patientsSeen: 1200,
  consultationFee: 800,
  languages: ['English', 'Amharic'],
  qualifications: ['MBBS', 'MD'],
  centerIds: ['c1'],
  nextAvailableLabel: 'Tomorrow',
);

Widget _buildCard({
  Doctor doctor = _doctor,
  VoidCallback? onTap,
  bool isFavorite = false,
  VoidCallback? onFavoriteToggle,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(
      home: Scaffold(
        body: DoctorCard(
          doctor: doctor,
          onTap: onTap ?? () {},
          isFavorite: isFavorite,
          onFavoriteToggle: onFavoriteToggle,
        ),
      ),
    ),
  );
}

void main() {
  group('DoctorCard', () {
    testWidgets('displays doctor name with Dr. prefix', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('Dr. Jane Smith'), findsOneWidget);
    });

    testWidgets('displays specialization', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('Cardiologist'), findsOneWidget);
    });

    testWidgets('displays years of experience', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.textContaining('10'), findsWidgets);
    });

    testWidgets('displays formatted consultation fee', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('ETB 800'), findsOneWidget);
    });

    testWidgets('displays rating', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('4.9'), findsOneWidget);
    });

    testWidgets('shows next available label when provided', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('Tomorrow'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_buildCard(onTap: () => tapped = true));
      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('shows avatar initials when no avatarUrl', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('JS'), findsOneWidget);
    });

    testWidgets('does not show next available when null', (tester) async {
      const noNext = Doctor(
        id: 'd2',
        fullName: 'Bob Lee',
        specialization: 'Surgeon',
        yearsExperience: 15,
        rating: 4.7,
        reviewCount: 50,
        patientsSeen: 500,
        consultationFee: 1200,
        languages: ['English'],
        qualifications: ['MBBS'],
        centerIds: [],
      );
      await tester.pumpWidget(_buildCard(doctor: noNext));
      // No 'Tomorrow' or availability label
      expect(find.text('Tomorrow'), findsNothing);
    });
  });
}
