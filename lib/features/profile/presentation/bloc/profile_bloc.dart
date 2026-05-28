import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/error/exceptions.dart';
import '../../data/datasources/profile_remote_datasource.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required ProfileRemoteDataSource dataSource})
      : _ds = dataSource,
        super(const ProfileInitial()) {
    on<ProfileRequested>(_onRequested);
    on<ProfileUpdated>(_onUpdated);
    on<ProfileImageUploaded>(_onImageUploaded);
    on<ProfileImageDeleted>(_onImageDeleted);
  }

  final ProfileRemoteDataSource _ds;

  // Extracts a human-readable message from any exception type.
  static String _msg(Object e) =>
      e is ServerException ? e.message : e.toString();

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _ds.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileFailure(_msg(e)));
    }
  }

  Future<void> _onUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    final currentUser = current is ProfileLoaded
        ? current.user
        : (current is ProfileSaved ? current.user : null);
    if (currentUser == null) return;

    emit(ProfileSaving(currentUser));
    try {
      final data = <String, dynamic>{};
      // Backend PatchPatientProfileApiRequest fields: fullName, dateOfBirth,
      // gender, address, medicalHistory, allergies, bloodType.
      // NOTE: email is NOT in the patch DTO — omit it.
      if (event.fullName != null) data['fullName'] = event.fullName;
      if (event.dateOfBirth != null) {
        data['dateOfBirth'] =
            event.dateOfBirth!.toIso8601String().substring(0, 10);
      }
      if (event.gender != null) data['gender'] = event.gender;

      final updated = await _ds.updateProfile(data);
      emit(ProfileSaved(updated));
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileLoaded(currentUser));
      emit(ProfileFailure(_msg(e)));
    }
  }

  Future<void> _onImageUploaded(
    ProfileImageUploaded event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    final currentUser = current is ProfileLoaded
        ? current.user
        : (current is ProfileSaved ? current.user : null);
    if (currentUser == null) return;

    emit(ProfileSaving(currentUser));
    try {
      final url = await _ds.uploadProfileImage(event.filePath);
      final updated = currentUser.copyWith(profileImageUrl: url);
      emit(ProfileSaved(updated));
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileLoaded(currentUser));
      emit(ProfileFailure(_msg(e)));
    }
  }

  Future<void> _onImageDeleted(
    ProfileImageDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    final currentUser = current is ProfileLoaded
        ? current.user
        : (current is ProfileSaved ? current.user : null);
    if (currentUser == null) return;

    emit(ProfileSaving(currentUser));
    try {
      await _ds.deleteProfileImage();
      final updated = currentUser.copyWith(profileImageUrl: '');
      emit(ProfileSaved(updated));
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileLoaded(currentUser));
      emit(ProfileFailure(_msg(e)));
    }
  }
}
