part of 'services.dart';

class UsersServices {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void registerUser({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required String phoneNumber,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) {
    _auth
        .createUserWithEmailAndPassword(
      email: email,
      password: password,
    )
        .then((userCredential) {
      final userId = userCredential.user?.uid;
      if (userId == null) {
        onError("User ID is null after registration.");
        return;
      }

      _firestore.collection('users').doc(userId).set({
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phoneNumber': phoneNumber,
      }).then((_) {
        onSuccess(userId);
      }).catchError((error) {
        onError("Failed to save user data: $error");
      });
    }).catchError((error) {
      onError("Registration failed: $error");
    });
  }
}
