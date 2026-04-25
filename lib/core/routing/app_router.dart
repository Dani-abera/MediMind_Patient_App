import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth/auth_state.dart';
import '../../features/auth/presentation/bloc/otp/otp_bloc.dart';
import '../../features/auth/presentation/bloc/register/register_bloc.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/phone_entry_page.dart';
import '../../features/auth/presentation/pages/profile_completion_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../di/service_locator.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavKey = GlobalKey<NavigatorState>();
  static final _otpShellKey = GlobalKey<NavigatorState>();

  static GoRouter get config => _router;

  static final _router = GoRouter(
    navigatorKey: _rootNavKey,
    initialLocation: '/',
    redirect: _globalRedirect,
    refreshListenable: _AuthStateListenable(sl<AuthBloc>()),
    routes: [
      // ── Splash & Onboarding ───────────────────────────────────────────
      GoRoute(
        name: RouteNames.splash,
        path: '/',
        pageBuilder: (_, __) => const NoTransitionPage(child: SplashPage()),
      ),
      GoRoute(
        name: RouteNames.onboarding,
        path: '/onboarding',
        pageBuilder: (_, __) => const MaterialPage(child: OnboardingPage()),
      ),

      // ── OTP Auth Shell: PhoneEntry + OtpVerification share one OtpBloc ──
      ShellRoute(
        navigatorKey: _otpShellKey,
        builder: (context, state, child) => BlocProvider<OtpBloc>(
          create: (_) => sl<OtpBloc>(),
          child: child,
        ),
        routes: [
          GoRoute(
            name: RouteNames.phoneEntry,
            path: '/auth/phone',
            pageBuilder: (_, __) =>
                const MaterialPage(child: PhoneEntryPage()),
          ),
          GoRoute(
            name: RouteNames.otpVerification,
            path: '/auth/otp',
            pageBuilder: (_, state) {
              final phoneNumber = state.extra as String? ?? '';
              return MaterialPage(
                child: OtpVerificationPage(phoneNumber: phoneNumber),
              );
            },
          ),
        ],
      ),

      // ── Profile Completion ────────────────────────────────────────────
      GoRoute(
        name: RouteNames.profileCompletion,
        path: '/auth/profile-completion',
        pageBuilder: (_, state) {
          final phoneNumber = state.extra as String? ?? '';
          return MaterialPage(
            child: BlocProvider(
              create: (_) => sl<RegisterBloc>(),
              child: ProfileCompletionPage(phoneNumber: phoneNumber),
            ),
          );
        },
      ),

      // ── App ───────────────────────────────────────────────────────────
      GoRoute(
        name: RouteNames.home,
        path: '/home',
        builder: (_, __) => const _Placeholder(RouteNames.home),
      ),
      GoRoute(
        name: RouteNames.book,
        path: '/book',
        builder: (_, __) => const _Placeholder(RouteNames.book),
      ),
      GoRoute(
        name: RouteNames.health,
        path: '/health',
        builder: (_, __) => const _Placeholder(RouteNames.health),
      ),
      GoRoute(
        name: RouteNames.profile,
        path: '/profile',
        builder: (_, __) => const _Placeholder(RouteNames.profile),
      ),
      GoRoute(
        name: RouteNames.searchDoctors,
        path: '/book/search',
        builder: (_, __) => const _Placeholder(RouteNames.searchDoctors),
      ),
      GoRoute(
        name: RouteNames.doctorDetail,
        path: '/book/doctor/:id',
        builder: (_, state) => _Placeholder(
          '${RouteNames.doctorDetail}/${state.pathParameters['id']}',
        ),
      ),
      GoRoute(
        name: RouteNames.appointmentSlots,
        path: '/book/slots',
        builder: (_, __) => const _Placeholder(RouteNames.appointmentSlots),
      ),
      GoRoute(
        name: RouteNames.appointmentConfirm,
        path: '/book/confirm',
        builder: (_, __) =>
            const _Placeholder(RouteNames.appointmentConfirm),
      ),
      GoRoute(
        name: RouteNames.appointmentSuccess,
        path: '/book/success',
        builder: (_, __) =>
            const _Placeholder(RouteNames.appointmentSuccess),
      ),
      GoRoute(
        name: RouteNames.myAppointments,
        path: '/appointments',
        builder: (_, __) => const _Placeholder(RouteNames.myAppointments),
      ),
      GoRoute(
        name: RouteNames.appointmentDetail,
        path: '/appointments/:id',
        builder: (_, __) =>
            const _Placeholder(RouteNames.appointmentDetail),
      ),
      GoRoute(
        name: RouteNames.healthRecords,
        path: '/health/records',
        builder: (_, __) => const _Placeholder(RouteNames.healthRecords),
      ),
      GoRoute(
        name: RouteNames.recordDetail,
        path: '/health/records/:id',
        builder: (_, __) => const _Placeholder(RouteNames.recordDetail),
      ),
      GoRoute(
        name: RouteNames.uploadRecord,
        path: '/health/records/upload',
        builder: (_, __) => const _Placeholder(RouteNames.uploadRecord),
      ),
      GoRoute(
        name: RouteNames.videoCall,
        path: '/call/:id',
        builder: (_, __) => const _Placeholder(RouteNames.videoCall),
      ),
      GoRoute(
        name: RouteNames.editProfile,
        path: '/profile/edit',
        builder: (_, __) => const _Placeholder(RouteNames.editProfile),
      ),
      GoRoute(
        name: RouteNames.settings,
        path: '/profile/settings',
        builder: (_, __) => const _Placeholder(RouteNames.settings),
      ),
      GoRoute(
        name: RouteNames.notifications,
        path: '/profile/notifications',
        builder: (_, __) => const _Placeholder(RouteNames.notifications),
      ),
      GoRoute(
        name: RouteNames.pharmacy,
        path: '/pharmacy',
        builder: (_, __) => const _Placeholder(RouteNames.pharmacy),
      ),
      GoRoute(
        name: RouteNames.qrScanner,
        path: '/scanner',
        builder: (_, __) => const _Placeholder(RouteNames.qrScanner),
      ),
      GoRoute(
        name: RouteNames.webViewer,
        path: '/web',
        builder: (_, __) => const _Placeholder(RouteNames.webViewer),
      ),
      GoRoute(
        name: RouteNames.pdfViewer,
        path: '/pdf',
        builder: (_, __) => const _Placeholder(RouteNames.pdfViewer),
      ),
    ],
  );

  static const _publicPaths = {
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
    final isPublic = _publicPaths.any(
      (path) =>
          state.matchedLocation == path ||
          state.matchedLocation.startsWith('$path/'),
    );
    if (isPublic) return null;

    final authState = context.read<AuthBloc>().state;
    if (authState is Unauthenticated) return '/auth/phone';
    return null;
  }
}

class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable(AuthBloc bloc) {
    _sub = bloc.stream.listen((_) => notifyListeners());
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder(this.routeName);
  final String routeName;

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Text(routeName, style: const TextStyle(fontSize: 20)),
        ),
      );
}
