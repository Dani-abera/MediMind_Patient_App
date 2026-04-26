import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/features/auth/presentation/bloc/auth/auth_bloc.dart';
import 'package:medimind/features/auth/presentation/bloc/auth/auth_event.dart';
import 'package:medimind/features/auth/presentation/bloc/auth/auth_state.dart';
import 'package:medimind/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:medimind/features/home/presentation/bloc/home_bloc.dart';
import 'package:medimind/features/home/presentation/bloc/home_event.dart';
import 'package:medimind/features/home/presentation/bloc/home_state.dart';
import 'package:medimind/features/home/presentation/pages/home_page.dart';
import 'package:medimind/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:medimind/features/notifications/presentation/bloc/notification_event.dart';
import 'package:medimind/features/notifications/presentation/bloc/notification_state.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState>
    implements HomeBloc {}

class MockAuthBloc extends MockBloc<AuthEvent, AuthState>
    implements AuthBloc {}

class MockNotificationBloc
    extends MockBloc<NotificationEvent, NotificationState>
    implements NotificationBloc {}

Widget _buildTestApp({required Widget child}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, __) => MaterialApp(
      home: child,
    ),
  );
}

void main() {
  late MockHomeBloc homeBloc;
  late MockAuthBloc authBloc;
  late MockNotificationBloc notificationBloc;

  setUp(() {
    homeBloc = MockHomeBloc();
    authBloc = MockAuthBloc();
    notificationBloc = MockNotificationBloc();

    when(() => authBloc.state).thenReturn(const Unauthenticated());
    when(() => notificationBloc.state)
        .thenReturn(const NotificationState(unreadCount: 0));
  });

  Widget buildSubject() => MultiBlocProvider(
        providers: [
          BlocProvider<HomeBloc>.value(value: homeBloc),
          BlocProvider<AuthBloc>.value(value: authBloc),
          BlocProvider<NotificationBloc>.value(value: notificationBloc),
        ],
        child: const HomePage(),
      );

  group('HomePage', () {
    testWidgets('shows shimmer while loading', (tester) async {
      when(() => homeBloc.state).thenReturn(const HomeLoading());

      await tester.pumpWidget(_buildTestApp(child: buildSubject()));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Shimmer is rendered (SingleChildScrollView with physics disabled)
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    });

    testWidgets('shows quick actions when loaded', (tester) async {
      when(() => homeBloc.state)
          .thenReturn(const HomeLoaded(HomeData()));

      await tester.pumpWidget(_buildTestApp(child: buildSubject()));
      await tester.pump();

      expect(find.text('Quick Actions'), findsOneWidget);
      expect(find.text('Book\nAppointment'), findsOneWidget);
      expect(find.text('Log\nVitals'), findsOneWidget);
    });

    testWidgets('shows error state and retry button on HomeError',
        (tester) async {
      when(() => homeBloc.state)
          .thenReturn(const HomeError('Server error'));

      await tester.pumpWidget(_buildTestApp(child: buildSubject()));
      await tester.pump();

      expect(find.text('Server error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('retry button fires HomeRefreshed event', (tester) async {
      when(() => homeBloc.state)
          .thenReturn(const HomeError('Server error'));

      await tester.pumpWidget(_buildTestApp(child: buildSubject()));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      verify(() => homeBloc.add(const HomeRefreshed())).called(1);
    });

    testWidgets('shows empty vitals CTA when no health record',
        (tester) async {
      when(() => homeBloc.state)
          .thenReturn(const HomeLoaded(HomeData()));

      await tester.pumpWidget(_buildTestApp(child: buildSubject()));
      await tester.pump();

      expect(find.text('No vitals logged today'), findsOneWidget);
    });
  });
}
