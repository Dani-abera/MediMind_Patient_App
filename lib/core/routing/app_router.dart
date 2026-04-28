import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/appointments/presentation/bloc/appointments/appointments_bloc.dart';
import '../../features/appointments/presentation/bloc/appointments/appointments_event.dart';
import '../../features/appointments/presentation/bloc/booking_flow/booking_flow_bloc.dart';
import '../../features/appointments/presentation/bloc/slot_picker/slot_picker_bloc.dart';
import '../../features/appointments/presentation/bloc/slot_picker/slot_picker_event.dart';
import '../../features/appointments/presentation/pages/appointment_detail_page.dart';
import '../../features/appointments/presentation/pages/booking_confirmation_page.dart';
import '../../features/appointments/presentation/pages/booking_summary_page.dart';
import '../../features/appointments/presentation/pages/slot_picker_page.dart';
import '../../features/auth/presentation/bloc/auth/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth/auth_state.dart';
import '../../features/auth/presentation/bloc/otp/otp_bloc.dart';
import '../../features/auth/presentation/bloc/register/register_bloc.dart';
import '../../features/auth/presentation/pages/onboarding_page.dart';
import '../../features/auth/presentation/pages/otp_verification_page.dart';
import '../../features/auth/presentation/pages/phone_entry_page.dart';
import '../../features/auth/presentation/pages/profile_completion_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/book/presentation/pages/book_page.dart';
import '../../features/centers/presentation/bloc/centers_bloc.dart';
import '../../features/centers/presentation/pages/center_detail_page.dart';
import '../../features/centers/presentation/pages/center_search_page.dart';
import '../../features/doctors/presentation/pages/center_doctors_page.dart';
import '../../features/doctors/presentation/pages/doctor_detail_page.dart';
import '../../features/health/presentation/pages/health_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/payments/presentation/pages/payment_webview_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../di/service_locator.dart';
import '../widgets/navigation/app_shell.dart';
import 'route_names.dart';

class AppRouter {
  AppRouter._();

  static final _rootNavKey = GlobalKey<NavigatorState>();
  static final _otpShellKey = GlobalKey<NavigatorState>();
  static final _homeNavKey = GlobalKey<NavigatorState>();
  static final _bookNavKey = GlobalKey<NavigatorState>();
  static final _healthNavKey = GlobalKey<NavigatorState>();
  static final _profileNavKey = GlobalKey<NavigatorState>();

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

      // ── OTP Auth Shell ────────────────────────────────────────────────
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
              final phone = state.extra as String? ?? '';
              return MaterialPage(
                child: OtpVerificationPage(phoneNumber: phone),
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
          final phone = state.extra as String? ?? '';
          return MaterialPage(
            child: BlocProvider(
              create: (_) => sl<RegisterBloc>(),
              child: ProfileCompletionPage(phoneNumber: phone),
            ),
          );
        },
      ),

      // ── Notifications (full-screen, outside shell) ────────────────────
      GoRoute(
        name: RouteNames.notifications,
        path: '/notifications',
        builder: (_, __) => const _Placeholder(RouteNames.notifications),
      ),

      // ── Video call (full-screen) ──────────────────────────────────────
      GoRoute(
        name: RouteNames.videoCall,
        path: '/call/:id',
        builder: (_, __) => const _Placeholder(RouteNames.videoCall),
      ),

      // ── Scanner / Web / PDF (full-screen) ────────────────────────────
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

      // ── Main App Shell (StatefulShellRoute) ───────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          // ── Tab 0: Home ─────────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _homeNavKey,
            routes: [
              GoRoute(
                name: RouteNames.home,
                path: '/home',
                builder: (_, __) => BlocProvider(
                  create: (_) => sl<HomeBloc>(),
                  child: const HomePage(),
                ),
              ),
            ],
          ),

          // ── Tab 1: Book ─────────────────────────────────────────────
          // BookingFlowBloc is provided at the branch shell level so it
          // persists across all booking sub-screens while the tab is active.
          StatefulShellBranch(
            navigatorKey: _bookNavKey,
            routes: [
              ShellRoute(
                builder: (context, state, child) => MultiBlocProvider(
                  providers: [
                    BlocProvider<BookingFlowBloc>(
                      create: (_) => sl<BookingFlowBloc>(),
                    ),
                    BlocProvider<AppointmentsBloc>(
                      create: (_) => sl<AppointmentsBloc>()
                        ..add(const AppointmentsRequested()),
                    ),
                  ],
                  child: child,
                ),
                routes: [
                  GoRoute(
                    name: RouteNames.book,
                    path: '/book',
                    builder: (_, __) => const BookPage(),
                  ),
                  GoRoute(
                    name: RouteNames.myAppointments,
                    path: '/appointments',
                    builder: (_, __) => const BookPage(),
                    routes: [
                      GoRoute(
                        name: RouteNames.appointmentDetail,
                        path: ':id',
                        builder: (_, state) => AppointmentDetailPage(
                          appointmentId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                  GoRoute(
                    name: RouteNames.centerSearch,
                    path: '/book/search',
                    builder: (_, __) => BlocProvider(
                      create: (_) => sl<CentersBloc>(),
                      child: const CenterSearchPage(),
                    ),
                  ),
                  GoRoute(
                    name: RouteNames.centerDetail,
                    path: '/book/center/:id',
                    builder: (_, state) => CenterDetailPage(
                      centerId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    name: RouteNames.centerDoctors,
                    path: '/book/center/:centerId/doctors',
                    builder: (_, state) => CenterDoctorsPage(
                      centerId: state.pathParameters['centerId']!,
                      centerName: state.uri.queryParameters['name'] ?? '',
                    ),
                  ),
                  GoRoute(
                    name: RouteNames.doctorDetail,
                    path: '/book/doctor/:id',
                    builder: (_, state) => DoctorDetailPage(
                      doctorId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    name: RouteNames.appointmentSlots,
                    path: '/book/slots',
                    builder: (_, state) {
                      final extra =
                          state.extra as Map<String, String>? ?? {};
                      return BlocProvider(
                        create: (_) => sl<SlotPickerBloc>()
                          ..add(SlotPickerInitialized(
                            doctorId: extra['doctorId'] ?? '',
                            centerId: extra['centerId'] ?? '',
                          )),
                        child: const SlotPickerPage(),
                      );
                    },
                  ),
                  GoRoute(
                    name: RouteNames.appointmentConfirm,
                    path: '/book/confirm',
                    builder: (_, __) => const BookingSummaryPage(),
                  ),
                  GoRoute(
                    name: RouteNames.paymentWebView,
                    path: '/book/payment',
                    builder: (_, state) {
                      final extra =
                          state.extra as Map<String, String>? ?? {};
                      return PaymentWebViewPage(
                        checkoutUrl: extra['checkoutUrl'] ?? '',
                        paymentId: extra['paymentId'] ?? '',
                      );
                    },
                  ),
                  GoRoute(
                    name: RouteNames.appointmentSuccess,
                    path: '/book/success',
                    builder: (_, __) => const BookingConfirmationPage(),
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 2: Health ─────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _healthNavKey,
            routes: [
              GoRoute(
                name: RouteNames.health,
                path: '/health',
                builder: (_, __) => const HealthPage(),
                routes: [
                  GoRoute(
                    name: RouteNames.healthRecords,
                    path: 'records',
                    builder: (_, __) =>
                        const _Placeholder(RouteNames.healthRecords),
                    routes: [
                      GoRoute(
                        name: RouteNames.recordDetail,
                        path: ':id',
                        builder: (_, __) =>
                            const _Placeholder(RouteNames.recordDetail),
                      ),
                      GoRoute(
                        name: RouteNames.uploadRecord,
                        path: 'upload',
                        builder: (_, __) =>
                            const _Placeholder(RouteNames.uploadRecord),
                      ),
                    ],
                  ),
                  GoRoute(
                    name: RouteNames.prescriptions,
                    path: 'prescriptions',
                    builder: (_, __) =>
                        const _Placeholder(RouteNames.prescriptions),
                  ),
                ],
              ),
            ],
          ),

          // ── Tab 3: Profile ────────────────────────────────────────
          StatefulShellBranch(
            navigatorKey: _profileNavKey,
            routes: [
              GoRoute(
                name: RouteNames.profile,
                path: '/profile',
                builder: (_, __) => const ProfilePage(),
                routes: [
                  GoRoute(
                    name: RouteNames.editProfile,
                    path: 'edit',
                    builder: (_, __) =>
                        const _Placeholder(RouteNames.editProfile),
                  ),
                  GoRoute(
                    name: RouteNames.settings,
                    path: 'settings',
                    builder: (_, __) =>
                        const _Placeholder(RouteNames.settings),
                  ),
                  GoRoute(
                    name: RouteNames.paymentMethods,
                    path: 'payments',
                    builder: (_, __) =>
                        const _Placeholder(RouteNames.paymentMethods),
                  ),
                ],
              ),
            ],
          ),
        ],
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
        appBar: AppBar(),
        body: Center(
          child: Text(routeName, style: const TextStyle(fontSize: 20)),
        ),
      );
}
