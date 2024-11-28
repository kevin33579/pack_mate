part of 'viewmodel.dart';

class AddProviderViewModel {
  final TextEditingController totalController = TextEditingController();
  List<String> memberNames = [];
  String? selectedName;

  int? totalMax;
  int? totalRemaining;

  /// Fetches member names from Firestore, excluding those already in provideBy
  void fetchMemberNamesExcludingProvided({
    required String partyId,
    required String itemId,
    required VoidCallback onUpdate,
  }) {
    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('members')
        .get()
        .then((membersSnapshot) {
      final allMemberNames = membersSnapshot.docs
          .map((doc) => doc['firstName'] as String)
          .toList();

      FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('sharedItems')
          .doc(itemId)
          .collection('provideBy')
          .get()
          .then((provideBySnapshot) {
        final providedNames =
            provideBySnapshot.docs.map((doc) => doc['name'] as String).toList();

        // Exclude names already in provideBy
        memberNames = allMemberNames
            .where((name) => !providedNames.contains(name))
            .toList();

        onUpdate();
      }).catchError((error) {
        debugPrint("Error fetching provided names: $error");
      });
    }).catchError((error) {
      debugPrint("Error fetching member names: $error");
    });
  }

  void fetchTotalValues(String partyId, String itemId, VoidCallback onUpdate) {
    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('sharedItems')
        .doc(itemId)
        .get()
        .then((sharedItemSnapshot) {
      if (sharedItemSnapshot.exists) {
        totalMax = sharedItemSnapshot['total'];

        FirebaseFirestore.instance
            .collection('parties')
            .doc(partyId)
            .collection('sharedItems')
            .doc(itemId)
            .collection('provideBy')
            .get()
            .then((providersSnapshot) {
          int totalProvided = providersSnapshot.docs.fold<int>(
            0,
            (sum, doc) => sum + (doc['total'] as int),
          );

          totalRemaining = (totalMax ?? 0) - totalProvided;
          onUpdate();
        }).catchError((error) {
          debugPrint("Error fetching total provided: $error");
        });
      }
    }).catchError((error) {
      debugPrint("Error fetching totalMax: $error");
    });
  }

  void saveProvider({
    required String partyId,
    required String itemId,
    required BuildContext context,
  }) {
    if (selectedName != null && totalController.text.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('members')
          .where('firstName', isEqualTo: selectedName)
          .get()
          .then((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          String userId = snapshot.docs.first.id;

          final providerData = {
            'name': selectedName,
            'total': int.parse(totalController.text),
          };

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

  void dispose() {
    totalController.dispose();
  }
}
