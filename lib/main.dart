 

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/models/todo.dart';
// import 'package:path_provider/path_provider.dart' as path_provider;
import 'package:path_provider/path_provider.dart' if (dart.library.html) 'package:path_provider/path_provider.dart' as path_provider;


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
      debugShowCheckedModeBanner: false,
      home: LoginScreen(authService: authService)
    );
  }
} 

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
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            ElevatedButton(
              onPressed: _register,
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}

class TodoScreen extends StatefulWidget {
  final User user;
  final AuthService authService;

  TodoScreen({required this.user, required this.authService});

  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _todoController = TextEditingController();
  late Box<Todo> _todoBox;

  @override
  void initState() {
    super.initState();
    _todoBox = Hive.box<Todo>('todoBox');
  }

  void _addTodo() {
    final title = _todoController.text;
    if (title.isNotEmpty) {
      final todo = Todo(
        title: title,
        isCompleted: false,
        userId: widget.user.username,
      );
      _todoBox.add(todo);
      _todoController.clear();
      setState(() {});
    }
  }

  void _toggleTodoCompletion(Todo todo) {
    todo.isCompleted = !todo.isCompleted;
    todo.save();
    setState(() {});
  }

  void _deleteTodo(Todo todo) {
    todo.delete();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome ${widget.user.username}'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              widget.authService.logout();
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) => LoginScreen(authService: widget.authService),
              ));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _todoController,
              decoration: InputDecoration(labelText: 'New To-Do'),
            ),
            ElevatedButton(
              onPressed: _addTodo,
              child: Text('Add To-Do'),
            ),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: _todoBox.listenable(),
                builder: (context, Box<Todo> box, _) {
                  // Filter todos by user
                  var userTodos = box.values.where((todo) => todo.userId == widget.user.username).toList();
                 

                  if (userTodos.isEmpty) {


                    return Center(
                      child: Text('No To-Dos yet.'),
                    );
                  }

                  return ListView.builder(
                    itemCount: userTodos.length,
                    itemBuilder: (context, index) {
                      final todo = userTodos[index];
                      return ListTile(
                        title: Text(todo.title),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(todo.isCompleted ? Icons.check_box : Icons.check_box_outline_blank),
                              onPressed: () => _toggleTodoCompletion(todo),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteTodo(todo),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
