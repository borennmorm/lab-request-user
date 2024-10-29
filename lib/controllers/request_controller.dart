import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user/controllers/auth_controller.dart';
import 'package:user/models/lab_model.dart';
import 'package:user/service/api.dart';

import '../utils/navigation.dart';

class RequestController extends GetxController {
  var isLoading = false.obs;
  var sessions = [].obs;
  var labs = [].obs;
  var selectedLabId = ''.obs;
  var selectedSessions = <String>[].obs;
  var selectedDate = DateTime.now().obs;

  var softwareNeed = ''.obs;
  var generation = ''.obs;
  var major = ''.obs;
  var subject = ''.obs;
  var studentQuantity = ''.obs;
  var additionalNotes = ''.obs;
  var token = '';
  var userRequests = [].obs;

  final ApiService apiService = ApiService();
   final AuthController authController = Get.find<AuthController>();

  @override
  void onInit() {
    super.onInit();
    fetchLabs();
    fetchSessions();
    fetchUserRequests();
  }

  // Fetch labs from backend API
  void fetchLabs() async {
    isLoading(true);
    try {
      final response = await apiService.getLabs();
      if (response.statusCode == 200) {
        List<dynamic> decodedResponse = jsonDecode(response.body);
        print('Labs fetched: $decodedResponse');

        if (decodedResponse.isNotEmpty) {
          List<LabModel> labList =
              decodedResponse.map((lab) => LabModel.fromJson(lab)).toList();
          labs.assignAll(labList);
        } else {
          print('No labs available');
        }
      } else {
        print('Error fetching labs: ${response.body}');
      }
    } catch (e) {
      print('Error fetching labs: $e');
    } finally {
      isLoading(false);
    }
  }

  // Fetch study times (sessions) from backend API
  void fetchSessions() async {
    isLoading(true);
    try {
      final response = await apiService.getSessions();
      if (response.statusCode == 200) {
        var decodedResponse = jsonDecode(response.body);
        print('Sessions fetched: $decodedResponse');
        if (decodedResponse.isNotEmpty) {
          sessions.assignAll(decodedResponse);
        } else {
          print('No sessions available');
        }
      } else {
        print('Error fetching sessions: ${response.body}');
      }
    } catch (e) {
      print('Error fetching sessions: $e');
    } finally {
      isLoading(false);
    }
  }

   // Fetch requests for the logged-in user
  Future<void> fetchUserRequests() async {
    try {
      final userId = authController.user.value.id;
      if (userId == null) {
        print('User ID not available');
        return;
      }

      final response = await apiService.get('requests?user_id=$userId');

      if (response.statusCode == 200) {
        var decodedData = jsonDecode(response.body);
        userRequests.assignAll(decodedData);
        print('User requests fetched: $decodedData');
      } else {
        print('Failed to fetch user requests: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user requests: $e');
    }
  }

  // Delete a specific request by ID
  Future<void> deleteRequest(int requestId) async {
    try {
      final response = await apiService.delete('requests/$requestId');

      if (response.statusCode == 204) {
        userRequests.removeWhere((request) => request['id'] == requestId);
        Get.snackbar('Success', 'Request deleted successfully',
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.green);
      } else {
        print('Failed to delete request: ${response.body}');
        Get.snackbar('Error', 'Failed to delete request',
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.red);
      }
    } catch (e) {
      print('Error deleting request: $e');
      Get.snackbar('Error', 'An error occurred while deleting the request',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red);
    }
  }

  // Method to update the selected lab
  void updateSelectedLab(String labId) {
    selectedLabId(labId);
  }

  // Update selected date
  void updateSelectedDate(DateTime date) {
    selectedDate(date);
  }

  // Method to check if all details are complete
  bool areDetailsComplete() {
    return softwareNeed.isNotEmpty &&
        generation.isNotEmpty &&
        major.isNotEmpty &&
        subject.isNotEmpty &&
        studentQuantity.isNotEmpty;
  }

  // Toggle session selection
  void toggleSessionSelection(String sessionId) {
    if (selectedSessions.contains(sessionId)) {
      selectedSessions.remove(sessionId);
    } else {
      selectedSessions.add(sessionId);
    }
  }

  // Check if all necessary selections are complete
  bool areSelectionsComplete() {
    return selectedLabId.isNotEmpty && selectedSessions.isNotEmpty;
  }

  // Create a request by sending data to the backend
  Future<void> createRequests() async {
    isLoading(true);

    try {
      // Validation for required fields
      if (selectedLabId.value.isEmpty || selectedSessions.isEmpty) {
        Get.snackbar(
          'Error',
          'Please select a lab and at least one session.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        isLoading(false);
        return;
      }
      if (major.value.isEmpty ||
          subject.value.isEmpty ||
          generation.value.isEmpty ||
          softwareNeed.value.isEmpty ||
          studentQuantity.value.isEmpty) {
        Get.snackbar(
          'Error',
          'All fields are required. Please fill in all information.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
        );
        isLoading(false);
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      int? userId = prefs.getInt('user_id');

      if (userId == null) {
        final profileResponse = await apiService.getUserProfile();

        if (profileResponse.statusCode == 200) {
          final profileData = jsonDecode(profileResponse.body);
          print('Profile Data: $profileData');

          if (!profileData.containsKey('id') || profileData['id'] == null) {
            Get.snackbar('Error', 'User ID missing in profile response.',
                backgroundColor: Colors.red);
            isLoading(false);
            return;
          }

          userId = profileData['id'];
          await prefs.setInt('user_id', userId!);
        } else {
          Get.snackbar(
            'Error',
            'Failed to retrieve user profile. Please log in again.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.red,
          );
          isLoading(false);
          return;
        }
      }

      // Construct the request body
      final body = {
        "lab_id": int.tryParse(selectedLabId.value) ?? 0,
        "study_time_id":
            selectedSessions.map((s) => int.tryParse(s) ?? 0).toList(),
        "user_id": userId,
        'request_date': selectedDate.value.toIso8601String().split('T')[0],
        'major': major.value,
        'subject': subject.value,
        "generation": generation.value,
        'software_need': softwareNeed.value,
        "number_of_student": int.tryParse(studentQuantity.value) ?? 0,
        'additional': additionalNotes.value,
      };

      final response = await apiService.post('requests', body);

      if (response.statusCode == 201) {
        print('Request created successfully');
        Get.snackbar(
          'Success',
          'Request created successfully',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
        );

        // Clear selections and fields
        selectedLabId.value = '';
        selectedSessions.clear();
        selectedDate.value = DateTime.now();
        softwareNeed.value = '';
        generation.value = '';
        major.value = '';
        subject.value = '';
        studentQuantity.value = '';
        additionalNotes.value = '';

        // Navigate to another screen
        Get.offAll(
            const Navigation());  
      } else {
        Get.snackbar(
          'Error',
          'Failed to create request',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
        );
      }
    } catch (e, stacktrace) {
      print('Error creating request: $e');
      print('Stacktrace: $stacktrace');
      Get.snackbar(
        'Error',
        'An error occurred while creating the request',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
      );
    } finally {
      isLoading(false);
    }
  }
}
