// ignore_for_file: unused_local_variable, use_build_context_synchronously, unused_element

import 'package:eventory/modles/user_model.dart';
import 'package:eventory/services/auth.dart';
import 'package:flutter/material.dart';
import 'sign_in.dart'; // Ensure this import is correct for your project

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  bool _agreeToTerms = false;
  String errorMessage = "";
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  void _register() async {
    String userName = userNameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    // Validate password length
    if (password.length < 6) {
      setState(() {
        errorMessage = 'Password must be at least 6 characters long.';
      });
      return;
    }

    if (password != confirmPassword) {
      setState(() {
        errorMessage = 'Passwords do not match.';
      });
      return;
    }

    if (_agreeToTerms) {
      // Call the register method from AuthServices
      AuthServices authServices = AuthServices();
      try {
        UserModel? userModel = await authServices.registerWithEmailAndPassword(
            email, password, userName);

        if (userModel != null) {
          // If registration is successful, navigate to the Sign_In page
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => Sign_In()),
          );
        }
      } catch (err) {
        // If an error occurred, display the Firebase error message
        setState(() {
          errorMessage = err.toString(); // Display the error message directly
        });
      }
    } else {
      setState(() {
        errorMessage = 'Please agree to the terms and conditions to proceed.';
      });
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    userNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff121212),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              height: 250,
              decoration: BoxDecoration(
                color: Color(0xffF1F7F7),
                borderRadius: BorderRadius.only(
                  bottomRight: Radius.circular(75),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 80),
                    IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: Color(0xffFF611A),
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Create ",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            "Account",
                            style: TextStyle(
                              fontSize: 35,
                              fontWeight: FontWeight.bold,
                              color: Color(0xffFF611A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40),
                  _buildTextField(userNameController, "User Name"),
                  SizedBox(height: 20),
                  _buildTextField(emailController, "Email"),
                  SizedBox(height: 20),
                  _buildTextField(passwordController, "Password",
                      obscureText: _obscurePassword,
                      icon: _togglePasswordVisibility),
                  SizedBox(height: 20),
                  _buildTextField(confirmPasswordController, "Confirm Password",
                      obscureText: _obscureConfirmPassword,
                      icon: _toggleConfirmPasswordVisibility),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Checkbox(
                        value: _agreeToTerms,
                        onChanged: (value) {
                          setState(() {
                            _agreeToTerms = value!;
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                      Text("Agree to ", style: TextStyle(color: Colors.white)),
                      GestureDetector(
                        onTap: () {
                          // Handle Terms and Conditions click
                        },
                        child: Text("Terms and Conditions",
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  // Display the error message if there is one
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(color: Colors.red),
                    ),
                  SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xffFF611A),
                        padding: EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _register,
                      child: Text(
                        "Register",
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account? ",
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Sign_In()),
                            );
                          },
                          child: Text(
                            "Sign In",
                            style: TextStyle(fontSize: 14, color: Colors.blue),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, Function()? icon}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        fillColor: Colors.white,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        suffixIcon: icon != null
            ? IconButton(
          icon:
          Icon(obscureText ? Icons.visibility : Icons.visibility_off),
          onPressed: icon,
          color: Colors.grey,
        )
            : null,
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscurePassword = !_obscurePassword;
    });
  }

  void _toggleConfirmPasswordVisibility() {
    setState(() {
      _obscureConfirmPassword = !_obscureConfirmPassword;
    });
  }
}
