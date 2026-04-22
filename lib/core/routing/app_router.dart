import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../di/service_locator.dart';
import '../storage/secure_storage.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static GoRouter get config => _router;

  static final GoRouter _router = GoRouter(
    initialLocation: '/',
    redirect: _globalRedirect,
    routes: [
      GoRoute(
        name: RouteNames.splash,
        path: '/',
        builder: (_, __) => _Placeholder(RouteNames.splash),
      ),
      GoRoute(
        name: RouteNames.onboarding,
        path: '/onboarding',
        builder: (_, __) => _Placeholder(RouteNames.onboarding),
      ),
      GoRoute(
        name: RouteNames.phoneEntry,
        path: '/auth/phone',
        builder: (_, __) => _Placeholder(RouteNames.phoneEntry),
      ),
      GoRoute(
        name: RouteNames.otpVerification,
        path: '/auth/otp',
        builder: (_, __) => _Placeholder(RouteNames.otpVerification),
      ),
      GoRoute(
        name: RouteNames.profileCompletion,
        path: '/auth/profile-completion',
        builder: (_, __) => _Placeholder(RouteNames.profileCompletion),
      ),
      GoRoute(
        name: RouteNames.home,
        path: '/home',
        builder: (_, __) => _Placeholder(RouteNames.home),
      ),
      GoRoute(
        name: RouteNames.book,
        path: '/book',
        builder: (_, __) => _Placeholder(RouteNames.book),
      ),
      GoRoute(
        name: RouteNames.health,
        path: '/health',
        builder: (_, __) => _Placeholder(RouteNames.health),
      ),
      GoRoute(
        name: RouteNames.profile,
        path: '/profile',
        builder: (_, __) => _Placeholder(RouteNames.profile),
      ),
      GoRoute(
        name: RouteNames.searchDoctors,
        path: '/book/search',
        builder: (_, __) => _Placeholder(RouteNames.searchDoctors),
      ),
      GoRoute(
        name: RouteNames.doctorDetail,
        path: '/book/doctor/:id',
        builder: (_, state) => _Placeholder('${RouteNames.doctorDetail}/${state.pathParameters['id']}'),
      ),
      GoRoute(
        name: RouteNames.appointmentSlots,
        path: '/book/slots',
        builder: (_, __) => _Placeholder(RouteNames.appointmentSlots),
      ),
      GoRoute(
        name: RouteNames.appointmentConfirm,
        path: '/book/confirm',
        builder: (_, __) => _Placeholder(RouteNames.appointmentConfirm),
      ),
      GoRoute(
        name: RouteNames.appointmentSuccess,
        path: '/book/success',
        builder: (_, __) => _Placeholder(RouteNames.appointmentSuccess),
      ),
      GoRoute(
        name: RouteNames.myAppointments,
        path: '/appointments',
        builder: (_, __) => _Placeholder(RouteNames.myAppointments),
      ),
      GoRoute(
        name: RouteNames.appointmentDetail,
        path: '/appointments/:id',
        builder: (_, __) => _Placeholder(RouteNames.appointmentDetail),
      ),
      GoRoute(
        name: RouteNames.healthRecords,
        path: '/health/records',
        builder: (_, __) => _Placeholder(RouteNames.healthRecords),
      ),
      GoRoute(
        name: RouteNames.recordDetail,
        path: '/health/records/:id',
        builder: (_, __) => _Placeholder(RouteNames.recordDetail),
      ),
      GoRoute(
        name: RouteNames.uploadRecord,
        path: '/health/records/upload',
        builder: (_, __) => _Placeholder(RouteNames.uploadRecord),
      ),
      GoRoute(
        name: RouteNames.videoCall,
        path: '/call/:id',
        builder: (_, __) => _Placeholder(RouteNames.videoCall),
      ),
      GoRoute(
        name: RouteNames.editProfile,
        path: '/profile/edit',
        builder: (_, __) => _Placeholder(RouteNames.editProfile),
      ),
      GoRoute(
        name: RouteNames.settings,
        path: '/profile/settings',
        builder: (_, __) => _Placeholder(RouteNames.settings),
      ),
      GoRoute(
        name: RouteNames.notifications,
        path: '/profile/notifications',
        builder: (_, __) => _Placeholder(RouteNames.notifications),
      ),
      GoRoute(
        name: RouteNames.pharmacy,
        path: '/pharmacy',
        builder: (_, __) => _Placeholder(RouteNames.pharmacy),
      ),
      GoRoute(
        name: RouteNames.qrScanner,
        path: '/scanner',
        builder: (_, __) => _Placeholder(RouteNames.qrScanner),
      ),
      GoRoute(
        name: RouteNames.webViewer,
        path: '/web',
        builder: (_, __) => _Placeholder(RouteNames.webViewer),
      ),
      GoRoute(
        name: RouteNames.pdfViewer,
        path: '/pdf',
        builder: (_, __) => _Placeholder(RouteNames.pdfViewer),
      ),
    ],
  );

  static final _publicRoutes = {
    '/',
    '/onboarding',
    '/auth/phone',
    '/auth/otp',
    '/auth/profile-completion',
  };

  static Future<String?> _globalRedirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final isPublic = _publicRoutes.any(
      (path) => state.matchedLocation.startsWith(path),
    );
    if (isPublic) return null;

    final token = await sl<SecureStorage>().getAccessToken();
    if (token == null) return '/auth/phone';
    return null;
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.routeName);
  final String routeName;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(
            routeName,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      );
}
