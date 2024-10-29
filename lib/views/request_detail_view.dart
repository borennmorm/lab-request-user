import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../controllers/request_controller.dart';

class RequestDetailScreen extends StatelessWidget {
  const RequestDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestController controller = Get.find();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        title: Text("request".tr),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Date(controller: controller),
              const SizedBox(height: 10),
              _LabSection(controller: controller),
              const SizedBox(height: 10),
              _SessionsSection(controller: controller),
              const SizedBox(height: 10),
              _AdditionalDetailsSection(),
              const SizedBox(height: 20),
              _SubmitButton(controller: controller),
            ],
          ),
        ),
      ),
    );
  }
}

class _Date extends StatelessWidget {
  final RequestController controller;

  const _Date({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.calendar_today,
          color: Colors.blue,
          size: 15,
        ),
        const SizedBox(width: 10),
        Text("date".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(() {
            final selectedDate = controller.selectedDate.value;
            final formattedDate =
                DateFormat('EEEE, dd MMM yyyy').format(selectedDate);
            return Text(
              formattedDate,
              overflow: TextOverflow.ellipsis,
            );
          }),
        ),
      ],
    );
  }
}

class _LabSection extends StatelessWidget {
  final RequestController controller;

  const _LabSection({required this.controller});

  String mapLabIdToName(String labId) {
    switch (labId) {
      case '1':
        return 'Lab A';
      case '2':
        return 'Lab B';
      case '3':
        return 'Lab C';
      case '4':
        return 'Lab D';
      case '5':
        return 'Lab E';
      default:
        return 'Unknown Lab';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(
          Icons.computer,
          color: Colors.blue,
          size: 15,
        ),
        const SizedBox(width: 10),
        Text("lab".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(width: 10),
        Expanded(
          child: Obx(() {
            final selectedLab = controller.selectedLabId.value;
            return Text(
              selectedLab.isNotEmpty
                  ? mapLabIdToName(selectedLab)
                  : "Not selected",
              overflow: TextOverflow.ellipsis,
            );
          }),
        ),
      ],
    );
  }
}

class _SessionsSection extends StatelessWidget {
  final RequestController controller;

  const _SessionsSection({required this.controller});

  String mapSessionIdToTime(String sessionId) {
    switch (sessionId) {
      case '1':
        return '07:00 - 08:30';
      case '2':
        return '08:40 - 10:20';
      case '3':
        return '10:30 - 12:00';
      case '4':
        return '01:00 - 02:30';
      case '5':
        return '02:40 - 03:20';
      case '6':
        return '03:30 - 05:00';
      default:
        return 'Unknown Session';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.lock_clock,
              color: Colors.blue,
              size: 15,
            ),
            const SizedBox(width: 10),
            Text("sessions".tr,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10),
        Obx(() {
          final selectedSessions = controller.selectedSessions;
          return Wrap(
            spacing: 10,
            runSpacing: 10,
            children: selectedSessions.map((session) {
              return Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: Colors.blue,
                    width: 1,
                  ),
                ),
                child: Text(
                  mapSessionIdToTime(session),
                  style: const TextStyle(fontSize: 14),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }
}

class _AdditionalDetailsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final RequestController controller = Get.find();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("additional_details".tr,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        _buildTextField('software_need'.tr, controller.softwareNeed),
        _buildTextField('generation'.tr, controller.generation),
        _buildTextField('major'.tr, controller.major),
        _buildTextField('subject'.tr, controller.subject),
        _buildTextField('student'.tr, controller.studentQuantity),
        _buildTextField('additional_optional'.tr, controller.additionalNotes,
            isOptional: true),
      ],
    );
  }

  Widget _buildTextField(String label, RxString value,
      {bool isOptional = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        decoration: InputDecoration(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          labelText: label + (isOptional ? '' : ' *'),
          labelStyle: TextStyle(color: isOptional ? Colors.grey : Colors.black),
        ),
        onChanged: (newValue) => value.value = newValue,
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final RequestController controller;

  const _SubmitButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Obx(() {
        bool isComplete = controller.areSelectionsComplete() &&
            controller.areDetailsComplete();
        return TextButton(
          onPressed: isComplete ? () => _submitRequest(controller) : null,
          child: Text(
            "submit".tr,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        );
      }),
    );
  }

  void _submitRequest(RequestController controller) async {
    try {
      await controller.createRequests();
      Get.snackbar(
        'Success',
        'Request submitted successfully.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await Future.delayed(const Duration(seconds: 2));
      Get.back(); // Go back to the previous screen
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to submit request: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error submitting request: $e');
    }
  }
}
