part of 'viewmodel.dart';

class LoginViewModel {
  void loginUser(usernameController, passwordController, context, route) {
    FirebaseAuth.instance
        .signInWithEmailAndPassword(
      email: usernameController.text,
      password: passwordController.text,
    )
        .then((userCredential) {
      print("User logged in: ${userCredential.user?.uid}");
      Navigator.pushReplacementNamed(context, route);
    }).catchError((error) {
      print("Login error: $error");
    });
  }
}
