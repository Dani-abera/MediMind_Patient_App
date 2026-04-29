import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'data/datasources/reviews_remote_datasource.dart';
import 'data/repositories/reviews_repository_impl.dart';
import 'domain/repositories/reviews_repository.dart';
import 'domain/usecases/submit_review_usecase.dart';
import 'presentation/bloc/review_bloc.dart';

void initReviewsFeature(GetIt sl) {
  sl.registerLazySingleton<ReviewsRemoteDataSource>(
    () => ReviewsRemoteDataSourceImpl(sl<Dio>()),
  );

  sl.registerLazySingleton<ReviewsRepository>(
    () => ReviewsRepositoryImpl(sl<ReviewsRemoteDataSource>()),
  );

  sl.registerLazySingleton(
      () => SubmitReviewUsecase(sl<ReviewsRepository>()));

  sl.registerFactory(
    () => ReviewBloc(submitReview: sl<SubmitReviewUsecase>()),
  );
}
