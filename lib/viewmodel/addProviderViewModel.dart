part of 'viewmodel.dart';

class AddProviderViewModel {
  final TextEditingController totalController = TextEditingController();
  List<String> memberNames = [];
  String? selectedName;

  /// Fetches member names from Firestore and updates memberNames list
  void fetchMemberNames(String partyId) {
    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('members')
        .get()
        .then((snapshot) {
      memberNames =
          snapshot.docs.map((doc) => doc['firstName'] as String).toList();
    }).catchError((error) {
      debugPrint("Error fetching member names: $error");
    });
  }

  /// Saves provider data to Firestore under the 'provideBy' collection
  void saveProvider({
    required String partyId,
    required String itemId,
    required BuildContext context,
  }) {
    if (selectedName != null && totalController.text.isNotEmpty) {
      // Fetch the userId for the selected name
      FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('members')
          .where('firstName', isEqualTo: selectedName)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String userId = snapshot.docs.first.id;

          // Prepare provider data
          final providerData = {
            'name': selectedName,
            'total': int.parse(totalController.text),
          };

          // Save provider data to Firestore
          FirebaseFirestore.instance
              .collection('parties')
              .doc(partyId)
              .collection('sharedItems')
              .doc(itemId)
              .collection('provideBy')
              .doc(userId)
              .set(providerData)
              .then((_) {
            Navigator.pop(context);
          }).catchError((error) {
            debugPrint("Error saving provider: $error");
          });
        } else {
          debugPrint("User ID not found for selected name.");
        }
      }).catchError((error) {
        debugPrint("Error fetching user ID: $error");
      });
    }
  }

  /// Disposes of the controller to free up resources
  void dispose() {
    totalController.dispose();
  }
}
