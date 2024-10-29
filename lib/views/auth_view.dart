import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../utils/button.dart';
import '../utils/textfield.dart';

class LoginView extends StatelessWidget {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/nubb.png",
                width: 100,
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: emailController,
                label: 'Email',
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
                isPassword: false,
                obscureText: false,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 20),
              CustomTextField(
                controller: passwordController,
                label: 'Password',
                hint: 'Enter your password',
                keyboardType: TextInputType.visiblePassword,
                isPassword: true,
                obscureText: true,
                validator: (value) {
                  return null;
                },
              ),
              const SizedBox(height: 20),
              Obx(() {
                return authController.isLoading.value
                    ? const CircularProgressIndicator()
                    : CustomButton(
                        color: Colors.black,
                        onPressed: () {
                          authController.login(
                            emailController.text,
                            passwordController.text,
                          );
                        },
                        text: 'Login',
                      );
              }),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      // Navigate to the Register view
                      // Get.to(() => RegisterView());
                    },
                    child: const Text("Sign up"),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
