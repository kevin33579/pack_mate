part of 'viewmodel.dart';

class AddCarrierViewModel {
  final TextEditingController totalController = TextEditingController();
  List<String> memberNames = [];
  String? selectedName;

  int? totalMax;
  int? totalRemaining;

  void fetchMemberNamesExcludingCarried({
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
          .collection('carriedBy')
          .get()
          .then((carriedBySnapshot) {
        final carriedNames =
            carriedBySnapshot.docs.map((doc) => doc['name'] as String).toList();

        memberNames = allMemberNames
            .where((name) => !carriedNames.contains(name))
            .toList();

        onUpdate();
      }).catchError((error) {
        debugPrint("Error fetching provided names: $error");
      });
    }).catchError((error) {
      debugPrint("Error fetching member names: $error");
    });
  }

  /// Fetch totalMax dan totalRemaining values dari item
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
            .collection('carriedBy')
            .get()
            .then((carriersSnapshot) {
          int totalCarried = carriersSnapshot.docs.fold<int>(
            0,
            (sum, doc) => sum + (doc['total'] as int),
          );

          totalRemaining = (totalMax ?? 0) - totalCarried;
          onUpdate();
        }).catchError((error) {
          debugPrint("Error fetching total provided: $error");
        });
      }
    }).catchError((error) {
      debugPrint("Error fetching totalMax: $error");
    });
  }

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

  void dispose() {
    totalController.dispose();
  }
}
