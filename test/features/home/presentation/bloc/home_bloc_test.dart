import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medimind/core/error/failures.dart';
import 'package:medimind/features/home/domain/usecases/get_home_data_usecase.dart';
import 'package:medimind/features/home/presentation/bloc/home_bloc.dart';
import 'package:medimind/features/home/presentation/bloc/home_event.dart';
import 'package:medimind/features/home/presentation/bloc/home_state.dart';
import 'package:mocktail/mocktail.dart';

class MockGetHomeDataUsecase extends Mock implements GetHomeDataUsecase {}

void main() {
  late MockGetHomeDataUsecase mockUsecase;

  const emptyData = HomeData();
  const partialData = HomeData(failedSections: ['centers']);
  const fullData = HomeData(unreadCount: 3);

  setUp(() => mockUsecase = MockGetHomeDataUsecase());

  HomeBloc buildBloc() =>
      HomeBloc(getHomeData: mockUsecase);

  group('HomeOpened', () {
    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeLoaded] when all data succeeds',
      build: () {
        when(() => mockUsecase()).thenAnswer(
          (_) async => const Right(fullData),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeOpened()),
      expect: () => [
        const HomeLoading(),
        const HomeLoaded(fullData),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomePartialLoaded] when some sections fail',
      build: () {
        when(() => mockUsecase()).thenAnswer(
          (_) async => const Right(partialData),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeOpened()),
      expect: () => [
        const HomeLoading(),
        isA<HomePartialLoaded>().having(
          (s) => s.errors,
          'errors',
          contains('centers'),
        ),
      ],
    );

    blocTest<HomeBloc, HomeState>(
      'emits [HomeLoading, HomeError] when all data fails',
      build: () {
        when(() => mockUsecase()).thenAnswer(
          (_) async => const Left(
            ServerFailure(message: 'Failed to load dashboard data'),
          ),
        );
        return buildBloc();
      },
      act: (bloc) => bloc.add(const HomeOpened()),
      expect: () => [
        const HomeLoading(),
        isA<HomeError>().having(
          (s) => s.message,
          'message',
          'Failed to load dashboard data',
        ),
      ],
    );
  });

  group('HomeRefreshed', () {
    blocTest<HomeBloc, HomeState>(
      'reloads data and emits HomeLoaded',
      build: () {
        when(() => mockUsecase()).thenAnswer(
          (_) async => const Right(emptyData),
        );
        return buildBloc();
      },
      seed: () => const HomeLoaded(fullData),
      act: (bloc) => bloc.add(const HomeRefreshed()),
      expect: () => [const HomeLoaded(emptyData)],
    );

    blocTest<HomeBloc, HomeState>(
      'does not emit HomeLoading on refresh (keeps current data visible)',
      build: () {
        when(() => mockUsecase()).thenAnswer(
          (_) async => const Right(emptyData),
        );
        return buildBloc();
      },
      seed: () => const HomeLoaded(fullData),
      act: (bloc) => bloc.add(const HomeRefreshed()),
      expect: () => isNot(contains(const HomeLoading())),
      verify: (_) => verify(() => mockUsecase()).called(1),
    );
  });
}
