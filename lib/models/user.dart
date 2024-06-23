import 'package:hive/hive.dart';

part 'user.g.dart';

  
@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  late String username;

  @HiveField(1)
  late String password;

    User({required this.username, required this.password});

  @override
  String toString() {
    return 'User{username: $username, password: $password}';
  }
}