// ignore_for_file: camel_case_types, avoid_print, use_build_context_synchronously

import 'package:eventory/screnns/home/home.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../services/auth.dart';
import 'register.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sign_In extends StatefulWidget {
  const Sign_In({super.key});

  @override
  State<Sign_In> createState() => _Sign_InState();
}

class _Sign_InState extends State<Sign_In> {
  final AuthServices _auth = AuthServices();

  String email = '';
  String password = '';
  bool _passwordVisible = false; // Manage visibility of password

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _rememberMe = prefs.getBool('rememberMe') ?? false;
      if (_rememberMe) {
        email = prefs.getString('email') ?? '';
        password = prefs.getString('password') ?? '';
        _emailController.text = email;
        _passwordController.text = password;
      }
    });
  }

  // Function to validate and perform login
  Future<void> _login() async {
    if (email.isEmpty || password.isEmpty) {
      _showDialog('Email and Password cannot be empty.');
      return;
    }

    if (password.length < 6) {
      _showDialog('Password must be at least 6 characters long.');
      return;
    }

    //Save & Clear Credentials Functions
    Future<void> saveCredentials() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', true);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
    }

    Future<void> clearSavedCredentials() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('rememberMe', false);
      await prefs.remove('email');
      await prefs.remove('password');
    }

    // Call your sign-in function here
    dynamic result = await _auth.signInWithEmailAndPassword(email, password);
// After successful login:
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showWelcomeAfterLogin', true);
    if (result == null) {
      _showDialog('Login failed. Please check your credentials.');
    } else {
      if (_rememberMe) {
        saveCredentials();
      } else {
        clearSavedCredentials();
      }
      if (!mounted) return;
      // Navigate to the Home page after successful login
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  // Function to reset the password
  void _forgotPassword() {
    TextEditingController emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Password'),
          content: TextField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: 'Enter your email',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (emailController.text.isNotEmpty) {
                  await _auth.resetPassword(emailController.text);
                  Navigator.of(context).pop();
                  _showDialog(
                      'A password reset link has been sent to your email.');
                } else {
                  _showDialog('Please enter a valid email.');
                }
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  // Function to handle Google sign-in
  Future<void> _signInWithGoogle() async {
    dynamic result = await _auth.signInWithGoogle();
    if (result == null) {
      _showDialog('Google sign-in failed, Please Try Again Later');
    } else {
      // Navigate to the Home page after successful Google sign-in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Home()),
      );
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Message'),
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

  bool _rememberMe = false; // To track the checkbox state
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Welcome To ",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            Text(
                              "Eventory",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xffFF611A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 120),
                  TextField(
                    controller: _emailController,
                    onChanged: (value) {
                      email = value;
                    },
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: Colors.grey),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    onChanged: (value) {
                      password = value;
                    },
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.grey),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.orange),
                      ),
                    ),
                    style: TextStyle(color: Colors.white),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: _forgotPassword,
                      child: Text(
                        'Forget Password?',
                        style: TextStyle(
                          color: Colors.grey,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value!;
                          });
                        },
                        activeColor: Colors.orange,
                      ),
                      Text(
                        'Remember me',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  SizedBox(height: 30),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xffFF611A),
                          padding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: _login,
                        child: Text(
                          'LOG IN',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Sign Up/Sign In with Google',
                        style: TextStyle(
                          color: Color(0xffFF611A),
                          decoration: TextDecoration.underline,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = _signInWithGoogle,
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: "Don't Have An Account? ",
                        style: TextStyle(color: Colors.grey),
                        children: [
                          TextSpan(
                            text: 'Sign Up',
                            style: TextStyle(
                              color: Color(0xffFF611A),
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Register(),
                                  ),
                                );
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GestureDetector(
                        onTap: () async {
                          dynamic result = await _auth.signInAnonymouse();
                          if (result == null) {
                            print("Error in sign-in: User is null");
                          } else {
                            print("Signed in successfully");
                            print("User ID is: ${result.uid}");
                            // Navigate to the Home page after successful sign-in
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => Home()),
                            );
                          }
                        },
                        child: Center(
                          child: Text(
                            'Login as Guest',
                            style: TextStyle(
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ),
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
}
