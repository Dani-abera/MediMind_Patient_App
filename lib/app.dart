import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:toastification/toastification.dart';
import 'core/constants/app_constants.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

class MediMindApp extends StatelessWidget {
  const MediMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
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
          child: Builder(
            builder: (ctx) => MaterialApp.router(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: ThemeMode.system,
              locale: ctx.locale,
              supportedLocales: ctx.supportedLocales,
              localizationsDelegates: ctx.localizationDelegates,
              routerConfig: AppRouter.config,
            ),
          ),
        ),
      ),
    );
  }
}
