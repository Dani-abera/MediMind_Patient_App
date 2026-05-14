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
import '../../features/health_records/domain/usecases/delete_record_usecase.dart';
import '../../features/health_records/domain/usecases/get_health_records_usecase.dart';
import '../../features/health_records/domain/usecases/get_latest_record_usecase.dart';
import '../../features/health_records/domain/usecases/get_record_count_usecase.dart';
import '../../features/health_records/domain/usecases/get_trends_usecase.dart';
import '../../features/health_records/domain/usecases/log_vitals_usecase.dart';
import '../../features/health_records/presentation/bloc/trends/trends_bloc.dart';
import '../../features/health_records/presentation/bloc/trends/trends_event.dart';
import '../../features/health_records/presentation/bloc/vitals/vitals_bloc.dart';
import '../../features/health_records/presentation/bloc/vitals/vitals_event.dart';
import '../../features/health_records/presentation/bloc/vitals_form/vitals_form_bloc.dart';
import '../../features/health_records/presentation/pages/log_vitals_page.dart';
import '../../features/health_records/presentation/pages/trends_detail_page.dart';
import '../../features/home/presentation/bloc/home_bloc.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/medication_reminders/domain/usecases/add_reminder_usecase.dart';
import '../../features/medication_reminders/domain/usecases/delete_reminder_usecase.dart';
import '../../features/medication_reminders/domain/usecases/get_reminders_usecase.dart';
import '../../features/medication_reminders/domain/usecases/toggle_reminder_usecase.dart';
import '../../features/medication_reminders/presentation/bloc/medication_reminders_bloc.dart';
import '../../features/medication_reminders/presentation/bloc/medication_reminders_event.dart';
import '../../features/medication_reminders/presentation/pages/add_reminder_page.dart';
import '../../features/emergency_contacts/presentation/bloc/emergency_contacts_bloc.dart';
import '../../features/emergency_contacts/presentation/pages/add_edit_contact_page.dart';
import '../../features/emergency_contacts/presentation/pages/emergency_contacts_page.dart';
import '../../features/favorites/presentation/bloc/favorites_bloc.dart';
import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/medical_history/presentation/bloc/medical_history_bloc.dart';
import '../../features/medical_history/presentation/pages/medical_history_page.dart';
import '../../features/notifications/presentation/bloc/notifications_list_bloc.dart';
import '../../features/notifications/presentation/pages/notification_preferences_page.dart';
import '../../features/notifications/presentation/pages/notifications_page.dart';
import '../../features/payments/presentation/bloc/payments_history_bloc.dart';
import '../../features/payments/presentation/pages/payment_history_page.dart';
import '../../features/payments/presentation/pages/payment_webview_page.dart';
import '../../features/prescriptions/presentation/bloc/prescriptions_bloc.dart';
import '../../features/prescriptions/presentation/pages/prescription_detail_page.dart';
import '../../features/prescriptions/presentation/pages/prescriptions_list_page.dart';
import '../../features/profile/presentation/bloc/profile_bloc.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/reviews/presentation/bloc/review_bloc.dart';
import '../../features/reviews/presentation/pages/leave_review_page.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/predictions/domain/usecases/get_latest_prediction_usecase.dart';
import '../../features/predictions/domain/usecases/get_prediction_by_id_usecase.dart';
import '../../features/predictions/domain/usecases/get_predictions_usecase.dart';
import '../../features/predictions/domain/usecases/request_prediction_usecase.dart';
import '../../features/predictions/presentation/bloc/prediction/prediction_bloc.dart';
import '../../features/predictions/presentation/bloc/prediction/prediction_event.dart';
import '../../features/predictions/presentation/pages/prediction_detail_page.dart';
import '../../features/predictions/presentation/pages/request_prediction_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/queue/domain/usecases/cancel_queue_usecase.dart';
import '../../features/queue/domain/usecases/get_queue_status_usecase.dart';
import '../../features/queue/presentation/bloc/queue_bloc.dart';
import '../../features/queue/presentation/pages/queue_status_page.dart';
import '../../features/queue/services/queue_signalr_service.dart';
import '../../features/video_consultation/domain/usecases/get_consultation_usecase.dart';
import '../../features/video_consultation/domain/usecases/join_consultation_usecase.dart';
import '../../features/video_consultation/presentation/bloc/video_call_bloc.dart';
import '../../features/video_consultation/presentation/pages/video_call_page.dart';
import '../../features/video_consultation/services/video_signalr_service.dart';
import '../di/service_locator.dart';
import '../services/analytics_service.dart';
import '../services/notification_service.dart';
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
    observers: [AnalyticsService.instance.observer, AnalyticsRouteObserver()],
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

      // ── Notifications ────────────────────────────────────────────────
      GoRoute(
        name: RouteNames.notifications,
        path: '/notifications',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<NotificationsListBloc>(),
          child: const NotificationsPage(),
        ),
        routes: [
          GoRoute(
            name: RouteNames.notificationPreferences,
            path: 'preferences',
            builder: (_, __) => BlocProvider(
              create: (_) => sl<NotificationsListBloc>(),
              child: const NotificationPreferencesPage(),
            ),
          ),
        ],
      ),

      // ── Prescriptions ────────────────────────────────────────────────
      GoRoute(
        name: RouteNames.prescriptions,
        path: '/prescriptions',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<PrescriptionsBloc>(),
          child: const PrescriptionsListPage(),
        ),
        routes: [
          GoRoute(
            name: RouteNames.prescriptionDetail,
            path: ':id',
            builder: (_, state) => BlocProvider(
              create: (_) => sl<PrescriptionsBloc>(),
              child: PrescriptionDetailPage(
                  id: state.pathParameters['id']!),
            ),
          ),
        ],
      ),

      // ── Emergency Contacts ────────────────────────────────────────────
      GoRoute(
        name: RouteNames.emergencyContacts,
        path: '/emergency-contacts',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<EmergencyContactsBloc>(),
          child: const EmergencyContactsPage(),
        ),
        routes: [
          GoRoute(
            name: RouteNames.addEditContact,
            path: 'contact',
            builder: (_, state) => BlocProvider(
              create: (_) => sl<EmergencyContactsBloc>(),
              child: AddEditContactPage(
                  contact: state.extra as dynamic),
            ),
          ),
        ],
      ),

      // ── Favorites ─────────────────────────────────────────────────────
      GoRoute(
        name: RouteNames.favorites,
        path: '/favorites',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<FavoritesBloc>(),
          child: const FavoritesPage(),
        ),
      ),

      // ── Leave Review ──────────────────────────────────────────────────
      GoRoute(
        name: RouteNames.leaveReview,
        path: '/review/:appointmentId',
        builder: (_, state) {
          final extra = state.extra as Map<String, String>? ?? {};
          return BlocProvider(
            create: (_) => sl<ReviewBloc>(),
            child: LeaveReviewPage(
              appointmentId: state.pathParameters['appointmentId']!,
              doctorName: extra['doctorName'] ?? '',
              centerName: extra['centerName'] ?? '',
            ),
          );
        },
      ),

      // ── Medical History ───────────────────────────────────────────────
      GoRoute(
        name: RouteNames.medicalHistory,
        path: '/medical-history',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<MedicalHistoryBloc>(),
          child: const MedicalHistoryPage(),
        ),
      ),

      // ── Payment History ───────────────────────────────────────────────
      GoRoute(
        name: RouteNames.paymentHistory,
        path: '/payment-history',
        builder: (_, __) => BlocProvider(
          create: (_) => sl<PaymentsHistoryBloc>(),
          child: const PaymentHistoryPage(),
        ),
      ),

      // ── Queue status (full-screen, outside shell) ─────────────────────
      GoRoute(
        name: RouteNames.queueStatus,
        path: '/queue/status/:appointmentId',
        builder: (_, state) => BlocProvider(
          create: (_) => QueueBloc(
            queueSignalR: sl<QueueSignalRService>(),
            getQueueStatus: sl<GetQueueStatusUsecase>(),
            cancelQueue: sl<CancelQueueUsecase>(),
          ),
          child: QueueStatusPage(
            appointmentId: state.pathParameters['appointmentId']!,
          ),
        ),
      ),

      // ── Video call (full-screen) ──────────────────────────────────────
      GoRoute(
        name: RouteNames.videoCall,
        path: '/call/:id',
        builder: (_, state) => BlocProvider(
          create: (_) => VideoCallBloc(
            getConsultation: sl<GetConsultationUsecase>(),
            joinConsultation: sl<JoinConsultationUsecase>(),
            videoSignalR: sl<VideoSignalRService>(),
          ),
          child: VideoCallPage(
            consultationId: state.pathParameters['id']!,
          ),
        ),
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
          // All health BLoCs are provided at the ShellRoute level so
          // sub-pages (LogVitals, Trends, Predictions, etc.) can read them.
          StatefulShellBranch(
            navigatorKey: _healthNavKey,
            routes: [
              ShellRoute(
                builder: (context, state, child) => MultiBlocProvider(
                  providers: [
                    BlocProvider<VitalsBloc>(
                      create: (_) => VitalsBloc(
                        getHealthRecords: sl<GetHealthRecordsUsecase>(),
                        getLatestRecord: sl<GetLatestRecordUsecase>(),
                        getRecordCount: sl<GetRecordCountUsecase>(),
                        deleteRecord: sl<DeleteRecordUsecase>(),
                      )..add(const VitalsRequested()),
                    ),
                    BlocProvider<VitalsFormBloc>(
                      create: (_) =>
                          VitalsFormBloc(logVitals: sl<LogVitalsUsecase>()),
                    ),
                    BlocProvider<TrendsBloc>(
                      create: (_) => TrendsBloc(
                        getTrends: sl<GetTrendsUsecase>(),
                      )..add(const TrendsRequested()),
                    ),
                    BlocProvider<PredictionBloc>(
                      create: (_) => PredictionBloc(
                        requestPrediction: sl<RequestPredictionUsecase>(),
                        getPredictions: sl<GetPredictionsUsecase>(),
                        getLatestPrediction: sl<GetLatestPredictionUsecase>(),
                        getPredictionById: sl<GetPredictionByIdUsecase>(),
                        getRecordCount: sl<GetRecordCountUsecase>(),
                      )..add(const PredictionsRequested()),
                    ),
                    BlocProvider<MedicationRemindersBloc>(
                      create: (_) => MedicationRemindersBloc(
                        getReminders: sl<GetRemindersUsecase>(),
                        addReminder: sl<AddReminderUsecase>(),
                        deleteReminder: sl<DeleteReminderUsecase>(),
                        toggleReminder: sl<ToggleReminderUsecase>(),
                        notificationService: NotificationService.instance,
                      )..add(const MedicationRemindersRequested()),
                    ),
                  ],
                  child: child,
                ),
                routes: [
                  GoRoute(
                    name: RouteNames.health,
                    path: '/health',
                    builder: (_, __) => const HealthPage(),
                  ),
                  GoRoute(
                    path: RouteNames.logVitals,
                    builder: (_, state) => LogVitalsPage(
                      recordId: state.uri.queryParameters['recordId'],
                    ),
                  ),
                  GoRoute(
                    path: RouteNames.trendsDetail,
                    builder: (_, __) => const TrendsDetailPage(),
                  ),
                  GoRoute(
                    path: RouteNames.requestPrediction,
                    builder: (_, __) => const RequestPredictionPage(),
                  ),
                  GoRoute(
                    path: '${RouteNames.predictionDetail}/:id',
                    builder: (_, state) => PredictionDetailPage(
                      predictionId: state.pathParameters['id']!,
                    ),
                  ),
                  GoRoute(
                    path: RouteNames.addReminder,
                    builder: (_, __) => const AddReminderPage(),
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
                    builder: (_, __) => BlocProvider(
                      create: (_) => sl<ProfileBloc>(),
                      child: const EditProfilePage(),
                    ),
                  ),
                  GoRoute(
                    name: RouteNames.settings,
                    path: 'settings',
                    builder: (_, __) => BlocProvider(
                      create: (_) => sl<SettingsBloc>(),
                      child: const SettingsPage(),
                    ),
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
