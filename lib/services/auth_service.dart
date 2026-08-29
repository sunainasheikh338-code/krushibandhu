class AuthService {
  bool login(String mobile, String password) {
    if (mobile.isNotEmpty && password.isNotEmpty) {
      return true;
    }
    return false;
  }

  bool signup(
    String name,
    String mobile,
    String password,
  ) {
    if (name.isNotEmpty &&
        mobile.isNotEmpty &&
        password.isNotEmpty) {
      return true;
    }
    return false;
  }

  void logout() {
    print("User Logged Out");
  }
}