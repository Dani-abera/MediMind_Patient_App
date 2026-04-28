import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routing/route_names.dart';
import '../../../appointments/presentation/pages/my_appointments_page.dart';

class BookPage extends StatelessWidget {
  const BookPage({super.key});

  @override
  Widget build(BuildContext context) {
    // The book tab root shows My Appointments.
    // The FAB and empty state navigate into the booking flow via centerSearch.
    return const MyAppointmentsPage();
  }
}

// Thin redirect helper used by quick-action buttons on other pages.
void navigateToBookingFlow(BuildContext context) {
  context.pushNamed(RouteNames.centerSearch);
}
