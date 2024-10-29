import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/models/user_model.dart';
import 'package:user/service/api.dart';
import 'package:user/utils/navigation.dart';
import 'package:user/views/home.dart';

import '../views/auth_view.dart';

class AuthController extends GetxController {
  var user = UserModel().obs;
  var isLoading = false.obs;
  final ApiService apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    _loadUserToken();
  }

  Future<void> _loadUserToken() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    if (token != null) {
      user.value.token = token;
      Get.offAll(() => Navigation());
    }
  }

  Future<void> login(String email, String password) async {
    isLoading.value = true;
    try {
      final response = await apiService.login(email, password);
      final responseData = jsonDecode(response.body);

      if (responseData.containsKey('access_token')) {
        user.value.token = responseData['access_token'];
        await apiService.storeToken(responseData['access_token']);
        await fetchUserProfile();
        Get.offAll(() => const Navigation());
      } else {
        Get.snackbar('Error', 'Access token not found.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Login failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUserProfile() async {
    try {
      final response = await apiService.getUserProfile();
      print("Profile response: ${response.body}"); 

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        user.value = UserModel.fromJson(userData);
      } else {
        Get.snackbar('Error', 'Failed to fetch profile: ${response.body}');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to load user profile: $e');
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Clear the saved token

    // Clear the user information
    user.value = UserModel();

    // Navigate to the login screen
    Get.offAll(() => LoginView());
  }
}
