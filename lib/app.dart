import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'core/connectivity/connectivity_cubit.dart';
import 'core/connectivity/offline_banner.dart';
import 'core/constants/app_constants.dart';
import 'core/di/service_locator.dart';
import 'core/network/network_info.dart';
import 'core/routing/app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth/auth_state.dart';
import 'features/notifications/presentation/bloc/notification_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/settings/presentation/bloc/settings_event.dart';
import 'features/settings/presentation/bloc/settings_state.dart';

class MediMindApp extends StatelessWidget {
  const MediMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => sl<AuthBloc>()),
        BlocProvider<NotificationBloc>(
          create: (_) => sl<NotificationBloc>(),
        ),
        BlocProvider<ConnectivityCubit>(
          create: (_) => ConnectivityCubit(sl<NetworkInfo>()),
        ),
        BlocProvider<SettingsBloc>(
          create: (_) => sl<SettingsBloc>()..add(const SettingsRequested()),
        ),
      ],
      child: ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: false,
        builder: (_, child) => ToastificationWrapper(
          child: EasyLocalization(
            supportedLocales: const [
              Locale('en', 'US'),
              Locale('am', 'ET'),
            ],
            path: AppConstants.translationsPath,
            fallbackLocale: const Locale('en', 'US'),
            child: BlocBuilder<SettingsBloc, SettingsState>(
              buildWhen: (prev, curr) =>
                  prev.themeMode != curr.themeMode ||
                  prev.languageCode != curr.languageCode,
              builder: (ctx, settings) {
                return MaterialApp.router(
                  title: AppConstants.appName,
                  debugShowCheckedModeBanner: false,
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: settings.themeMode,
                  locale: ctx.locale,
                  supportedLocales: ctx.supportedLocales,
                  localizationsDelegates: ctx.localizationDelegates,
                  routerConfig: AppRouter.config,
                  builder: (context, child) {
                    return _AppWrapper(child: child!);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AppWrapper extends StatefulWidget {
  const _AppWrapper({required this.child});
  final Widget child;

  @override
  State<_AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<_AppWrapper> {
  @override
  void initState() {
    super.initState();
    // Wire router to notification service for deep links
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppRouter.config.routerDelegate.addListener(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated) {
          AnalyticsService.instance.setUserId(
              state.user.patientId.hashCode.toUnsigned(32).toRadixString(16));
        }
      },
      child: OfflineBanner(child: widget.child),
    );
  }
}
