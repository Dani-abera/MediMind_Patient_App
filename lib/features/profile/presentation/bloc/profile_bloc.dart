import 'package:flutter_bloc/flutter_bloc.dart';
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

  Future<void> _onRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoading());
    try {
      final user = await _ds.getProfile();
      emit(ProfileLoaded(user));
    } catch (e) {
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> _onUpdated(
    ProfileUpdated event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    final currentUser =
        current is ProfileLoaded ? current.user : (current is ProfileSaved ? current.user : null);
    if (currentUser == null) return;

    emit(ProfileSaving(currentUser));
    try {
      final data = <String, dynamic>{};
      if (event.fullName != null) data['fullName'] = event.fullName;
      if (event.email != null) data['email'] = event.email;
      if (event.dateOfBirth != null) {
        data['dateOfBirth'] = event.dateOfBirth!.toIso8601String();
      }
      if (event.gender != null) data['gender'] = event.gender;

      final updated = await _ds.updateProfile(data);
      emit(ProfileSaved(updated));
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileLoaded(currentUser));
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> _onImageUploaded(
    ProfileImageUploaded event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    final currentUser =
        current is ProfileLoaded ? current.user : (current is ProfileSaved ? current.user : null);
    if (currentUser == null) return;

    emit(ProfileSaving(currentUser));
    try {
      final url = await _ds.uploadProfileImage(event.filePath);
      final updated = currentUser.copyWith(profileImageUrl: url);
      emit(ProfileSaved(updated));
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileLoaded(currentUser));
      emit(ProfileFailure(e.toString()));
    }
  }

  Future<void> _onImageDeleted(
    ProfileImageDeleted event,
    Emitter<ProfileState> emit,
  ) async {
    final current = state;
    final currentUser =
        current is ProfileLoaded ? current.user : (current is ProfileSaved ? current.user : null);
    if (currentUser == null) return;

    emit(ProfileSaving(currentUser));
    try {
      await _ds.deleteProfileImage();
      final updated = currentUser.copyWith(profileImageUrl: '');
      emit(ProfileSaved(updated));
      emit(ProfileLoaded(updated));
    } catch (e) {
      emit(ProfileLoaded(currentUser));
      emit(ProfileFailure(e.toString()));
    }
  }
}
