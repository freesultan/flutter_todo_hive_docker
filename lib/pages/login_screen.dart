
import 'package:flutter/material.dart';

import 'package:my_project/services/auth_service.dart';
import 'package:my_project/models/user.dart';
 
import 'package:my_project/pages/todo_screen.dart';


class LoginScreen extends StatefulWidget {
  final AuthService authService;

  LoginScreen({required this.authService});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _login() {
    var username = _usernameController.text;
    var password = _passwordController.text;
    User? user = widget.authService.authenticateUser(username, password);
    if (user != null) {
      // Navigate to the to-do screen
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => TodoScreen(user: user, authService: widget.authService),
      ));
    } else {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid username or password')),
      );
    }
  }

  void _register()  {
    var username = _usernameController.text;
    var password = _passwordController.text;
     widget.authService.registerUser(username, password);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('User registered successfully')),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _login,
                  child: Text('Login'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: _register,
                  child: Text('Register'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}