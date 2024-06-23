import 'package:hive/hive.dart';

part 'todo.g.dart';

@HiveType(typeId: 1)
class Todo extends HiveObject {
  @HiveField(0)
  String title;

  @HiveField(1)
  bool isCompleted;

  @HiveField(2)
  late String userId;

  Todo({
    required this.title,
    this.isCompleted = false,
    required this.userId,
  });

   @override
  String toString() {
    return 'Todo{title: $title, isCompleted: $isCompleted, userId: $userId}';
  }
}
