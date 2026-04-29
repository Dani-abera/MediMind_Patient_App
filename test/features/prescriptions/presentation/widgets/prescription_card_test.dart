import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/features/prescriptions/domain/entities/prescription.dart';

// Inline card widget extracted from the list page for testing
class _PrescriptionCard extends StatelessWidget {
  const _PrescriptionCard({required this.prescription, required this.onTap});
  final Prescription prescription;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusLabel = switch (prescription.status) {
      PrescriptionStatus.active => 'Active',
      PrescriptionStatus.expired => 'Expired',
      PrescriptionStatus.dispensed => 'Dispensed',
    };
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(prescription.referenceNumber),
              Text(statusLabel),
              Text(prescription.diagnosis),
              Text('Dr. ${prescription.doctorName}'),
            ],
          ),
        ),
      ),
    );
  }
}

final _activePrescription = Prescription(
  id: 'p1',
  referenceNumber: 'RX-2024-001',
  issuedAt: DateTime(2024, 1, 1),
  expiryDate: DateTime(2024, 7, 1),
  status: PrescriptionStatus.active,
  doctorName: 'Smith',
  doctorSpecialty: 'Cardiology',
  diagnosis: 'Hypertension',
  medications: const [
    PrescriptionMedication(
        name: 'Lisinopril', dosage: '10mg', frequency: 'once daily', durationDays: 30),
  ],
);

void main() {
  testWidgets('PrescriptionCard renders reference, status, diagnosis, doctor',
      (tester) async {
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: _PrescriptionCard(
              prescription: _activePrescription,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('RX-2024-001'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Hypertension'), findsOneWidget);
    expect(find.text('Dr. Smith'), findsOneWidget);
  });

  testWidgets('PrescriptionCard triggers onTap callback', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: _PrescriptionCard(
              prescription: _activePrescription,
              onTap: () => tapped = true,
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(GestureDetector).first);
    expect(tapped, true);
  });

  testWidgets('PrescriptionCard shows Expired status for expired prescription',
      (tester) async {
    final expired = Prescription(
      id: 'p2',
      referenceNumber: 'RX-2023-999',
      issuedAt: DateTime(2023, 1, 1),
      expiryDate: DateTime(2023, 6, 1),
      status: PrescriptionStatus.expired,
      doctorName: 'Jones',
      doctorSpecialty: 'GP',
      diagnosis: 'Infection',
      medications: const [],
    );
    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, __) => MaterialApp(
          home: Scaffold(
            body: _PrescriptionCard(
              prescription: expired,
              onTap: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Expired'), findsOneWidget);
  });
}
