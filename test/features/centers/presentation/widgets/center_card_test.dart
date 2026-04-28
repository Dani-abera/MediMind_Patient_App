import 'package:flutter/material.dart' hide Center;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/features/centers/domain/entities/center.dart';
import 'package:medimind/features/centers/presentation/widgets/center_card.dart';

const _center = Center(
  id: 'c1',
  name: 'City Medical Center',
  type: CenterType.hospital,
  address: '14 Bole Road',
  city: 'Addis Ababa',
  phone: '+251911000000',
  rating: 4.5,
  reviewCount: 128,
  distanceKm: 1.2,
  specializations: ['Cardiology', 'Neurology', 'Dermatology', 'Pediatrics'],
  isOpenNow: true,
  isFavorite: false,
  closingTime: '9:00 PM',
);

Widget _buildCard({
  Center center = _center,
  VoidCallback? onTap,
  VoidCallback? onFavoriteToggle,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(
      home: Scaffold(
        body: CenterCard(
          center: center,
          onTap: onTap ?? () {},
          onFavoriteToggle: onFavoriteToggle,
        ),
      ),
    ),
  );
}

void main() {
  group('CenterCard', () {
    testWidgets('displays center name', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('City Medical Center'), findsOneWidget);
    });

    testWidgets('shows open now status', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.textContaining('Open now'), findsOneWidget);
    });

    testWidgets('shows closed status when center is closed', (tester) async {
      const closed = Center(
        id: 'c2',
        name: 'Night Clinic',
        type: CenterType.clinic,
        address: '5 Kazanchis',
        city: 'Addis Ababa',
        phone: '+251911111111',
        rating: 3.8,
        reviewCount: 20,
        distanceKm: 2.0,
        specializations: ['General'],
        isOpenNow: false,
        isFavorite: false,
      );
      await tester.pumpWidget(_buildCard(center: closed));
      expect(find.text('Closed'), findsOneWidget);
    });

    testWidgets('shows formatted distance', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('1.2 km away'), findsOneWidget);
    });

    testWidgets('shows distance in meters for < 1 km', (tester) async {
      const near = Center(
        id: 'c3',
        name: 'Near Clinic',
        type: CenterType.clinic,
        address: 'Nearby St',
        city: 'Addis Ababa',
        phone: '+251900000000',
        rating: 4.0,
        reviewCount: 5,
        distanceKm: 0.3,
        specializations: ['General'],
        isOpenNow: true,
        isFavorite: false,
      );
      await tester.pumpWidget(_buildCard(center: near));
      expect(find.text('300 m away'), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_buildCard(onTap: () => tapped = true));
      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('shows first 3 specializations', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Neurology'), findsOneWidget);
      expect(find.text('Dermatology'), findsOneWidget);
    });

    testWidgets('shows type badge', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('Hospital'), findsOneWidget);
    });

    testWidgets('shows rating', (tester) async {
      await tester.pumpWidget(_buildCard());
      expect(find.text('4.5'), findsOneWidget);
    });
  });
}
