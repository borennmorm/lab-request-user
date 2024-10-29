import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:user/controllers/request_controller.dart';
import 'package:user/utils/drawer.dart';

import 'request_detail_view.dart';

class RequestView extends StatefulWidget {
  const RequestView({super.key});

  @override
  State<RequestView> createState() => RequestViewState();
}

class RequestViewState extends State<RequestView> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text('Lab Booking'),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.sort),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        backgroundColor: Colors.grey[100],
        actions: [
          IconButton(
            onPressed: () {
              // Get.to(() => Notifications());
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      drawer: CustomDrawer(),
      backgroundColor: Colors.grey[100],
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DateSelection(),
              SizedBox(height: 10),
              LabSelection(),
              SizedBox(height: 10),
              SessionSelection(),
              SizedBox(height: 10),
              NextButton(),
            ],
          ),
        ),
      ),
    );
  }
}

// Date Selection
class DateSelection extends StatefulWidget {
  const DateSelection({super.key});

  @override
  State<DateSelection> createState() => _DateSelectionState();
}

class _DateSelectionState extends State<DateSelection> {
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(RequestController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Obx(() => Text(
                  DateFormat('dd MMM yyyy')
                      .format(controller.selectedDate.value),
                  style: const TextStyle(fontSize: 16),
                )),
          ],
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: WeekView(controller: controller),
        ),
      ],
    );
  }
}

class WeekView extends StatelessWidget {
  final RequestController controller;

  const WeekView({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> getDaysOfWeek() {
      DateTime now = DateTime.now();

      return List.generate(14, (index) {
        DateTime date = now.add(Duration(days: index));
        return {
          "day": DateFormat('EEE').format(date),
          "date": date.day.toString(),
          "isSelected": date.day == controller.selectedDate.value.day &&
              date.month == controller.selectedDate.value.month &&
              date.year == controller.selectedDate.value.year,
          "isToday": date.day == now.day &&
              date.month == now.month &&
              date.year == now.year,
          "fullDate": date
        };
      });
    }

    List<Map<String, dynamic>> days = getDaysOfWeek();

    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: days.map((day) {
        return GestureDetector(
          onTap: () {
            controller.updateSelectedDate(day['fullDate']);
          },
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Obx(() {
              bool isSelected = day['fullDate'].day ==
                      controller.selectedDate.value.day &&
                  day['fullDate'].month ==
                      controller.selectedDate.value.month &&
                  day['fullDate'].year == controller.selectedDate.value.year;

              return Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  color: day['isToday']
                      ? Colors.blue.shade200
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(16),
                  border: isSelected
                      ? Border.all(color: Colors.blue, width: 3)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      day['day'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      day['date'],
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        );
      }).toList(),
    );
  }
}

// Lab Selection
class LabSelection extends StatelessWidget {
  const LabSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestController controller = Get.find<RequestController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.labs.isEmpty) {
        return const Text('No labs available');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Lab',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...controller.labs.map((lab) {
            bool isSelected =
                controller.selectedLabId.value == lab.id.toString();
            return GestureDetector(
              onTap: () => controller.updateSelectedLab(lab.id.toString()),
              child: Container(
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade100 : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(lab.name, style: const TextStyle(fontSize: 16)),
                    Text(lab.building,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        )),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

// Session Selection
class SessionSelection extends StatelessWidget {
  const SessionSelection({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestController controller = Get.find();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.sessions.isEmpty) {
        return const Text('No sessions available');
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Select Sessions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...controller.sessions.map((session) {
            bool isSelected =
                controller.selectedSessions.contains(session['id'].toString());
            return GestureDetector(
              onTap: () =>
                  controller.toggleSessionSelection(session['id'].toString()),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue.shade100 : Colors.white,
                  border: Border.all(
                    color: isSelected ? Colors.blue : Colors.grey,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.timelapse,
                        color: isSelected ? Colors.blue : Colors.black),
                    Text('${session['time']}',
                        style: TextStyle(
                            fontSize: 16,
                            color: isSelected ? Colors.blue : Colors.black)),
                  ],
                ),
              ),
            );
          }),
        ],
      );
    });
  }
}

// Next Button
class NextButton extends StatelessWidget {
  const NextButton({super.key});

  @override
  Widget build(BuildContext context) {
    final RequestController controller = Get.find();

    return Obx(() {
      // Observe the state of the controller to disable the button when details are incomplete
      bool isButtonEnabled = controller.areSelectionsComplete();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Text(
            'Make the request',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: isButtonEnabled
                ? () {
                    print('Selected Lab ID: ${controller.selectedLabId.value}');
                    print('Selected Sessions: ${controller.selectedSessions}');

                    // If selections are complete, navigate to the RequestDetailScreen
                    Get.to(() => const RequestDetailScreen());
                  }
                : () {
                    // Show warning if the button is disabled
                    Get.snackbar(
                      'Incomplete Selection',
                      'Please select both a lab and at least one session before proceeding.',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red[700],
                      colorText: Colors.white,
                    );
                  },
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isButtonEnabled ? Colors.blue : Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(16),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Next',
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 100),
        ],
      );
    });
  }
}
