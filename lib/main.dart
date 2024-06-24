 

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/models/todo.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider/path_provider.dart' if (dart.library.html) 'package:path_provider/path_provider.dart' as path_provider;

import 'package:my_project/pages/login_screen.dart';


import 'package:my_project/services/auth_service.dart';
import 'package:my_project/models/user.dart';

import 'package:flutter/foundation.dart' show kIsWeb;


void main() async{
  WidgetsFlutterBinding.ensureInitialized();

   if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    final appDocumentDir = await path_provider.getApplicationDocumentsDirectory();
    await Hive.initFlutter(appDocumentDir.path);
  }
   
  //register adapter
    Hive.registerAdapter(UserAdapter());
    var userBox = await Hive.openBox<User>('userBox');

    Hive.registerAdapter(TodoAdapter());
    var todoBox = await Hive.openBox<Todo>('todoBox');

   // Print the contents of the userBox and todoBox with keys
  print('User Box:');
  userBox.toMap().forEach((key, value) => print('Key: $key, Value: $value'));

  print('Todo Box:');
  todoBox.toMap().forEach((key, value) => print('Key: $key, Value: $value'));


  runApp( MainApp(authService: AuthService(userBox)));
}

class MainApp extends StatelessWidget {
  final AuthService authService;
  const MainApp({required this.authService});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
      title: "Sultan to do app",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      home: LoginScreen(authService: authService)
    );
  }
}