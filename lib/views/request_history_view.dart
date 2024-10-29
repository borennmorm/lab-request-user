import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:user/utils/drawer.dart';
import '../../controllers/request_controller.dart';

class RequestHistory extends StatefulWidget {
  const RequestHistory({super.key});

  @override
  State<RequestHistory> createState() => _RequestHistoryState();
}

class _RequestHistoryState extends State<RequestHistory> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final RequestController controller = Get.find<RequestController>();

  @override
  void initState() {
    super.initState();
    controller.fetchUserRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("History"),
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
              // Placeholder for Notifications page
            },
            icon: const Icon(Icons.notifications),
          ),
        ],
      ),
      backgroundColor: Colors.grey[100],
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Obx(() {
          if (controller.userRequests.isEmpty) {
            return const Center(
              child: Text(
                'No requests available.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            itemCount: controller.userRequests.length,
            itemBuilder: (context, index) {
              final request = controller.userRequests[index];

              // Check if 'studyTimes' exists and is a list
              final studyTimes = (request['studyTimes'] != null)
                  ? List<String>.from(
                      request['studyTimes']
                          .map((time) => time['time'])
                          .toList(),
                    )
                  : <String>[]; // Default to an empty list if null

              return RequestCards(
                labName: request['lab']['name'] ?? 'Unknown Lab',
                date: request['request_date'] ?? 'No Date',
                studyTimes: studyTimes,
                onDelete: () => controller.deleteRequest(request['id']),
              );
            },
          );
        }),
      ),
    );
  }
}

class RequestCards extends StatelessWidget {
  final String labName;
  final String date;
  final List<String> studyTimes;
  final VoidCallback onDelete;

  const RequestCards({
    super.key,
    required this.labName,
    required this.date,
    required this.studyTimes,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.computer, color: Colors.blue, size: 20),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        labName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: studyTimes
                      .map((time) => _buildStudyTimeChip(time))
                      .toList(),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                onPressed: onDelete,
                constraints: BoxConstraints.tight(const Size(36, 36)),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget to create a study time chip
  Widget _buildStudyTimeChip(String time) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300, width: 0.8),
      ),
      child: Text(
        time,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.blue,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
