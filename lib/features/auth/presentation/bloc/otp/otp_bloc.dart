import 'dart:async';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/usecases/request_otp_usecase.dart';
import '../../../domain/usecases/verify_otp_usecase.dart';
import 'otp_event.dart';
import 'otp_state.dart';

class OtpBloc extends Bloc<OtpEvent, OtpState> {
  OtpBloc({
    required RequestOtpUsecase requestOtp,
    required VerifyOtpUsecase verifyOtp,
  })  : _requestOtp = requestOtp,
        _verifyOtp = verifyOtp,
        super(const OtpInitial()) {
    on<OtpRequested>(_onOtpRequested);
    on<OtpSubmitted>(_onOtpSubmitted, transformer: droppable());
    on<OtpResendRequested>(_onOtpResendRequested);
    on<OtpTimerTicked>(_onTimerTicked);
  }

  final RequestOtpUsecase _requestOtp;
  final VerifyOtpUsecase _verifyOtp;
  Timer? _countdownTimer;

  static const int _otpDuration = 300;

  Future<void> _onOtpRequested(
    OtpRequested event,
    Emitter<OtpState> emit,
  ) async {
    emit(const OtpSending());
    final result = await _requestOtp(phoneNumber: event.phoneNumber);
    result.fold(
      (failure) => emit(
        OtpFailure(
          message: failure.message,
          phoneNumber: event.phoneNumber,
          remainingSeconds: 0,
        ),
      ),
      (_) {
        emit(OtpSent(
          phoneNumber: event.phoneNumber,
          remainingSeconds: _otpDuration,
        ));
        _startTimer(event.phoneNumber);
      },
    );
  }

  Future<void> _onOtpSubmitted(
    OtpSubmitted event,
    Emitter<OtpState> emit,
  ) async {
    final currentRemaining = _currentRemaining;
    emit(OtpVerifying(
      phoneNumber: event.phoneNumber,
      remainingSeconds: currentRemaining,
    ));
    final result = await _verifyOtp(
      VerifyOtpParams(
        phoneNumber: event.phoneNumber,
        otpCode: event.otpCode,
      ),
    );
    result.fold(
      (failure) => emit(
        OtpFailure(
          message: failure.message,
          phoneNumber: event.phoneNumber,
          remainingSeconds: currentRemaining,
        ),
      ),
      (user) {
        _cancelTimer();
        emit(OtpVerified(user));
      },
    );
  }

  Future<void> _onOtpResendRequested(
    OtpResendRequested event,
    Emitter<OtpState> emit,
  ) async {
    _cancelTimer();
    emit(const OtpSending());
    final result = await _requestOtp(phoneNumber: event.phoneNumber);
    result.fold(
      (failure) => emit(
        OtpFailure(
          message: failure.message,
          phoneNumber: event.phoneNumber,
          remainingSeconds: 0,
        ),
      ),
      (_) {
        emit(OtpSent(
          phoneNumber: event.phoneNumber,
          remainingSeconds: _otpDuration,
        ));
        _startTimer(event.phoneNumber);
      },
    );
  }

  void _onTimerTicked(OtpTimerTicked event, Emitter<OtpState> emit) {
    final current = state;
    if (event.remainingSeconds <= 0) {
      _cancelTimer();
      final phone = current is OtpSent
          ? current.phoneNumber
          : current is OtpFailure
              ? current.phoneNumber
              : '';
      emit(OtpExpired(phone));
      return;
    }
    if (current is OtpSent) {
      emit(OtpSent(
        phoneNumber: current.phoneNumber,
        remainingSeconds: event.remainingSeconds,
      ));
    } else if (current is OtpFailure) {
      emit(OtpFailure(
        message: current.message,
        phoneNumber: current.phoneNumber,
        remainingSeconds: event.remainingSeconds,
      ));
    }
  }

  int get _currentRemaining {
    final s = state;
    if (s is OtpSent) return s.remainingSeconds;
    if (s is OtpFailure) return s.remainingSeconds;
    if (s is OtpVerifying) return s.remainingSeconds;
    return 0;
  }

  void _startTimer(String phoneNumber) {
    _cancelTimer();
    var remaining = _otpDuration;
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      remaining--;
      add(OtpTimerTicked(remaining));
    });
  }

  void _cancelTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  Future<void> close() {
    _cancelTimer();
    return super.close();
  }
}
