import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/notification_service.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/check_auth_status_usecase.dart';
import '../../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required CheckAuthStatusUsecase checkAuthStatus,
    required LogoutUsecase logout,
    required AuthRepository authRepository,
  })  : _checkAuthStatus = checkAuthStatus,
        _logout = logout,
        super(const AuthInitial()) {
    on<AppStarted>(_onAppStarted);
    on<UserLoggedIn>(_onUserLoggedIn);
    on<UserLoggedOut>(_onUserLoggedOut);
    on<TokenExpired>(_onTokenExpired);

    _statusSub = authRepository.authStatusStream.listen(_onStatusChanged);
  }

  final CheckAuthStatusUsecase _checkAuthStatus;
  final LogoutUsecase _logout;
  late final StreamSubscription<AuthStatus> _statusSub;

  Future<void> _onAppStarted(
    AppStarted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _checkAuthStatus();
    result.fold(
      (_) => emit(const Unauthenticated()),
      (isAuth) => isAuth ? null : emit(const Unauthenticated()),
    );
  }

  void _onUserLoggedIn(UserLoggedIn event, Emitter<AuthState> emit) {
    emit(Authenticated(event.user));
    NotificationService.instance.registerDeviceToken();
  }

  Future<void> _onUserLoggedOut(
    UserLoggedOut event,
    Emitter<AuthState> emit,
  ) async {
    await NotificationService.instance.unregisterDeviceToken();
    await _logout();
    emit(const Unauthenticated());
  }

  void _onTokenExpired(TokenExpired event, Emitter<AuthState> emit) {
    emit(const Unauthenticated());
  }

  void _onStatusChanged(AuthStatus status) {
    if (status == AuthStatus.authenticated) return;
    if (state is! Unauthenticated) {
      add(const TokenExpired());
    }
  }

  @override
  Future<void> close() {
    _statusSub.cancel();
    return super.close();
  }
}
