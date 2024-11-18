part of 'viewmodel.dart';

class ItemListViewModel {
  String? userRole;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final ItemServices itemServices = ItemServices();

  // Get user role
  void getUserRole(String partyId, Function(String?) onRoleFetched) async {
    final user = auth.currentUser;
    if (user != null) {
      final memberDoc = await FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('members')
          .doc(user.uid)
          .get();

      if (memberDoc.exists) {
        onRoleFetched(memberDoc['role']);
      } else {
        onRoleFetched(null);
      }
    } else {
      onRoleFetched(null);
    }
  }

  // Get items
  Stream<List<DocumentSnapshot>> getItems(String type, String partyId) {
    final user = auth.currentUser;

    if (type == 'Personal' && user != null) {
      return FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('members')
          .doc(user.uid)
          .collection('personalItems')
          .snapshots()
          .map((snapshot) => snapshot.docs);
    } else {
      return FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('sharedItems')
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }
  }

  // Edit item total
  void editItemTotal(
    BuildContext context,
    String itemId,
    int currentTotal,
    String partyId, {
    bool isPersonal = false,
  }) {
    final totalController =
        TextEditingController(text: currentTotal.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Edit Total"),
        content: TextField(
          controller: totalController,
          decoration: InputDecoration(labelText: 'Total'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newTotal =
                  int.tryParse(totalController.text.trim()) ?? currentTotal;

              itemServices.updateItemTotal(
                itemId: itemId,
                newTotal: newTotal,
                partyId: partyId,
                isPersonal: isPersonal,
                onSuccess: () {
                  Navigator.pop(context);
                },
                onError: (error) {
                  print(error);
                },
              );
            },
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  // Delete item
  void deleteItem(String itemId, BuildContext context, String partyId,
      {bool isPersonal = false}) {
    itemServices.deleteItem(
      itemId: itemId,
      partyId: partyId,
      isPersonal: isPersonal,
      onSuccess: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully')),
        );
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item: $error')),
        );
      },
    );
  }

  // Update item checked
  void updateItemChecked({
    required String partyId,
    required String itemId,
    required bool isChecked,
  }) {
    final user = auth.currentUser;
    if (user != null) {
      itemServices.updateItemChecked(
        partyId: partyId,
        itemId: itemId,
        userId: user.uid,
        isChecked: isChecked,
        onError: (error) {
          print("Failed to update isChecked: $error");
        },
      );
    }
  }
}
