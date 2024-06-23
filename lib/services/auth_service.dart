import 'package:hive/hive.dart';
import 'package:my_project/models/user.dart';

class AuthService {
  final Box<User> _userBox;
  User? _loggedInUser;

  AuthService(this._userBox);

  void registerUser(String username, String password)  {
    var user = User(username: username, password: password);
       
     _userBox.add(user);
  }

  User? authenticateUser(String username, String password) {
    try {
      var user = _userBox.values.firstWhere(
        (user) => user.username == username && user.password == password,
        
      );
      _loggedInUser = user;
      return user;
    } catch (e) {
      _loggedInUser = null;
      return null;
    }
  }

  User? getLoggedInUser() {
    return _loggedInUser;
  }

  void logout() {
    _loggedInUser = null;
  }
}
