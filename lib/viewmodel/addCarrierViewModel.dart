part of 'viewmodel.dart';

class AddCarrierViewModel {
  final TextEditingController totalController = TextEditingController();
  List<String> memberNames = [];
  String? selectedName;

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

  /// Menyimpan data carrier ke Firestore
  void saveCarrier({
    required String partyId,
    required String itemId,
    required BuildContext context,
  }) {
    if (selectedName == null || totalController.text.isEmpty) return;

    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('members')
        .where('firstName', isEqualTo: selectedName)
        .get()
        .then((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        String userId = snapshot.docs.first.id;

        final carrierData = {
          'name': selectedName,
          'total': int.parse(totalController.text),
        };

        FirebaseFirestore.instance
            .collection('parties')
            .doc(partyId)
            .collection('sharedItems')
            .doc(itemId)
            .collection('carriedBy')
            .doc(userId)
            .set(carrierData)
            .then((_) {
          Navigator.pop(context);
        }).catchError((error) {
          debugPrint("Error saving carrier: $error");
        });
      } else {
        debugPrint("User ID not found for selected name.");
      }
    }).catchError((error) {
      debugPrint("Error fetching user ID: $error");
    });
  }

  /// Membersihkan resource controller
  void dispose() {
    totalController.dispose();
  }
}
