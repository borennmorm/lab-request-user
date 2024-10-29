import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class HomeView extends StatelessWidget {
  final AuthController authController = Get.find<AuthController>();

  HomeView({super.key}) {
    authController.fetchUserProfile(); // Ensures data is fetched on load
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Information'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.logout(),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          final user = authController.user.value;

          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${user.id ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Name: ${user.name ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Email: ${user.email ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Phone: ${user.phone ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Gender: ${user.gender ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Department: ${user.department ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Faculty: ${user.faculty ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Position: ${user.position ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text('Token: ${user.token ?? 'N/A'}',
                    style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                if (user.image != null)
                  Image.network(user.image!,
                      height: 100, width: 100, fit: BoxFit.cover)
                else
                  const Text('No profile image available',
                      style: TextStyle(fontSize: 18)),
              ]);
        }),
      ),
    );
  }
}
