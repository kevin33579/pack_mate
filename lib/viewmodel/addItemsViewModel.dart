part of 'viewmodel.dart';

class AddItemsViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String partyId;
  late String userId;

  final StreamController<Map<String, Item>> _itemsController =
      StreamController<Map<String, Item>>.broadcast();

  Stream<Map<String, Item>> get itemsStream => _itemsController.stream;

  void initialize(
    String partyId,
    String userId, {
    required Function(Map<String, Item>) onUpdate,
  }) {
    this.partyId = partyId;
    this.userId = userId;

    _firestore.collection('items').snapshots().listen((snapshot) {
      final Map<String, Item> updatedItems = {};
      for (var doc in snapshot.docs) {
        final id = doc.id;
        final data = doc.data() as Map<String, dynamic>;
        updatedItems[id] = Item(
          id: id,
          name: data['name'] ?? '',
          total: data['total'] ?? 1,
          isChecked: false,
        );
      }
      _itemsController.add(updatedItems);
      onUpdate(updatedItems);
    });
  }

  void addNewItem(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String itemName = '';
        return AlertDialog(
          title: const Text('Add New Item'),
          content: TextField(
            onChanged: (value) {
              itemName = value;
            },
            decoration: const InputDecoration(hintText: "Enter item name"),
          ),
          actions: [
            ElevatedButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            ElevatedButton(
              child: const Text('Add'),
              onPressed: () {
                Navigator.pop(context, itemName);
              },
            ),
          ],
        );
      },
    ).then((newItemName) {
      if (newItemName != null && newItemName.isNotEmpty) {
        _firestore.collection('items').add({
          'name': newItemName,
          'total': 1,
          'isChecked': false,
        }).then((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Item '$newItemName' added successfully!")),
          );
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to add item: $error")),
          );
        });
      }
    });
  }

  void saveSelectedItems(Map<String, Item> items, BuildContext context) {
    final selectedItems = items.values.where((item) => item.isChecked).toList();

    for (final item in selectedItems) {
      _firestore
          .collection('parties')
          .doc(partyId)
          .collection('members')
          .doc(userId)
          .collection('personalItems')
          .doc(item.id)
          .set({
        'name': item.name,
        'total': item.total,
        'isChecked': false,
      }).then((_) {
        print("Item '${item.name}' saved successfully.");
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save item '${item.name}': $error")),
        );
      });
    }

    Navigator.pop(context, selectedItems);
  }

  void dispose() {
    _itemsController.close();
  }
}
