import 'package:dio/dio.dart';
import '../../../../core/error/exceptions.dart';
import '../../../auth/data/models/user_model.dart';

abstract class ProfileRemoteDataSource {
  Future<UserModel> getProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> data);
  Future<String> uploadProfileImage(String filePath);
  Future<void> deleteProfileImage();
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl(this._dio);
  final Dio _dio;

  @override
  Future<UserModel> getProfile() async {
    try {
      final res = await _dio.get('/auth/patient/profile');
      return UserModel.fromJson(res.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      // PATCH returns 204 NoContent — re-fetch the profile to get updated data.
      await _dio.patch('/auth/patient/profile', data: data);
      return await getProfile();
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<String> uploadProfileImage(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'image': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.put('/profile-images/me', data: formData);
      return res.data['imageUrl'] as String? ??
          res.data['profileImageUrl'] as String? ?? '';
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }

  @override
  Future<void> deleteProfileImage() async {
    try {
      await _dio.delete('/profile-images/me');
    } on DioException catch (e) {
      throw ServerException(
          message: e.response?.data?['message'] ?? e.message ?? 'Error');
    }
  }
}
