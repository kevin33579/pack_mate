part of 'services.dart';

class ItemServices {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Update item total
  void updateItemTotal({
    required String itemId,
    required int newTotal,
    required String partyId,
    required bool isPersonal,
    required Function() onSuccess,
    required Function(String) onError,
  }) {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final collectionPath = isPersonal
          ? FirebaseFirestore.instance
              .collection('parties')
              .doc(partyId)
              .collection('members')
              .doc(user.uid)
              .collection('personalItems')
          : FirebaseFirestore.instance
              .collection('parties')
              .doc(partyId)
              .collection('sharedItems');

      collectionPath.doc(itemId).update({'total': newTotal}).then((_) {
        onSuccess();
      }).catchError((error) {
        onError(error.toString());
      });
    } catch (error) {
      onError(error.toString());
    }
  }

  // Delete item
  void deleteItem({
    required String itemId,
    required String partyId,
    required bool isPersonal,
    required Function() onSuccess,
    required Function(String) onError,
  }) {
    try {
      final user = auth.currentUser;
      if (user == null) {
        throw Exception("User not authenticated");
      }

      final collectionPath = isPersonal
          ? FirebaseFirestore.instance
              .collection('parties')
              .doc(partyId)
              .collection('members')
              .doc(user.uid)
              .collection('personalItems')
          : FirebaseFirestore.instance
              .collection('parties')
              .doc(partyId)
              .collection('sharedItems');

      collectionPath.doc(itemId).delete().then((_) {
        onSuccess();
      }).catchError((error) {
        onError(error.toString());
      });
    } catch (error) {
      onError(error.toString());
    }
  }

  // Update item isChecked
  void updateItemChecked({
    required String partyId,
    required String itemId,
    required String userId,
    required bool isChecked,
    required Function(String) onError,
  }) {
    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('members')
        .doc(userId)
        .collection('personalItems')
        .doc(itemId)
        .update({'isChecked': isChecked}).catchError((error) {
      onError(error.toString());
    });
  }
}
