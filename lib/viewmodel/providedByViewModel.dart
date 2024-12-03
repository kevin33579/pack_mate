part of 'viewmodel.dart';

class ProvidedByViewModel {
  final TextEditingController totalController = TextEditingController();
  int? totalMax;
  int? totalRemaining;

  Stream<List<Map<String, dynamic>>> getProviders(
      String partyId, String itemId) {
    return FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('sharedItems')
        .doc(itemId)
        .collection('provideBy')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  ...doc.data(),
                })
            .toList());
  }

  void fetchTotalValues(
      String partyId, String itemId, VoidCallback onUpdate) async {
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

  void editProvider(
    BuildContext context, {
    required String partyId,
    required String itemId,
    required String providerId,
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
                totalRemaining != null
                    ? DropdownButtonFormField<int>(
                        decoration: const InputDecoration(labelText: 'Total'),
                        items: List.generate(
                          totalRemaining!,
                          (index) => DropdownMenuItem(
                            value: index + 1,
                            child: Text((index + 1).toString()),
                          ),
                        ),
                        onChanged: (int? newValue) {
                          setState(() {
                            totalController.text = newValue.toString();
                          });
                        },
                      )
                    : const CircularProgressIndicator(),
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
                  .collection('provideBy')
                  .doc(providerId)
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

  void deleteProvider(
    BuildContext context, {
    required String partyId,
    required String itemId,
    required String providerId,
  }) {
    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('sharedItems')
        .doc(itemId)
        .collection('provideBy')
        .doc(providerId)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete provider: $error')),
      );
    });
  }
}
