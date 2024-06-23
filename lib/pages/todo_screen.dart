import 'package:flutter/material.dart';

import 'package:my_project/services/auth_service.dart';
import 'package:my_project/models/user.dart';
import 'package:my_project/models/todo.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:my_project/pages/login_screen.dart';


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
                      final todo = box.getAt(index) as Todo;
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
