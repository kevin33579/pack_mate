part of 'viewmodel.dart';

class CarriedByViewModel {
  Stream<List<Map<String, dynamic>>> getCarriers(
      String partyId, String itemId) {
    return FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('sharedItems')
        .doc(itemId)
        .collection('carriedBy')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  void editCarrier(
    BuildContext context, {
    required String partyId,
    required String itemId,
    required String carrierId,
    required String currentName,
    required int currentTotal,
  }) {
    final totalController =
        TextEditingController(text: currentTotal.toString());
    String? selectedName;
    List<String> memberNames = [];

    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('members')
        .get()
        .then((snapshot) {
      memberNames =
          snapshot.docs.map((doc) => doc['firstName'] as String).toList();
      if (selectedName == null) selectedName = currentName;
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: totalController,
                  decoration: const InputDecoration(labelText: 'Total'),
                  keyboardType: TextInputType.number,
                ),
              ],
            );
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = selectedName ?? currentName;
              final newTotal =
                  int.tryParse(totalController.text.trim()) ?? currentTotal;

              FirebaseFirestore.instance
                  .collection('parties')
                  .doc(partyId)
                  .collection('sharedItems')
                  .doc(itemId)
                  .collection('carriedBy')
                  .doc(carrierId)
                  .update({
                'name': newName,
                'total': newTotal,
              }).then((_) => Navigator.pop(context));
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void deleteCarrier(
    BuildContext context, {
    required String partyId,
    required String itemId,
    required String carrierId,
  }) {
    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('sharedItems')
        .doc(itemId)
        .collection('carriedBy')
        .doc(carrierId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Carrier deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete carrier: $error')),
      );
    });
  }
}
