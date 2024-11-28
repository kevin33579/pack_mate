part of 'services.dart';

class ItemServices {
  final FirebaseAuth auth = FirebaseAuth.instance;

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
        isPersonal
            ? _updateUsageCount(itemId)
            : _updateUsageSharedCount(itemId);
        onSuccess();
      }).catchError((error) {
        onError(error.toString());
      });
    } catch (error) {
      onError(error.toString());
    }
  }

  void _updateUsageCount(String itemId) async {
    final itemDoc =
        await FirebaseFirestore.instance.collection('items').doc(itemId).get();
    if (itemDoc.exists) {
      final currentUsageCount = itemDoc.data()?['usageCount'] ?? 0;

      FirebaseFirestore.instance.collection('items').doc(itemId).update({
        'usageCount': currentUsageCount - 1,
      }).then((_) {
        print("Updated usageCount for item ID $itemId successfully.");
      }).catchError((error) {
        print("Failed to update usageCount for item ID $itemId: $error");
      });
    } else {
      print("Item not found with ID $itemId");
    }
  }

  void _updateUsageSharedCount(String itemId) async {
    final itemDoc = await FirebaseFirestore.instance
        .collection('sharedItems')
        .doc(itemId)
        .get();
    if (itemDoc.exists) {
      final currentUsageCount = itemDoc.data()?['usageCount'] ?? 0;
      FirebaseFirestore.instance.collection('sharedItems').doc(itemId).update({
        'usageCount': currentUsageCount - 1,
      }).then((_) {
        print("Updated usageCount for item ID $itemId successfully.");
      }).catchError((error) {
        print("Failed to update usageCount for item ID $itemId: $error");
      });
    } else {
      print("Item not found with ID $itemId");
    }
  }

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
