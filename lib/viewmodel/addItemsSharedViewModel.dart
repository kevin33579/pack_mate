part of 'viewmodel.dart';

class AddItemsSharedViewModel {
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

    _calculateUsageCount().then((usageCount) async {
      final sharedItemsSnapshot = await _firestore
          .collection('parties')
          .doc(partyId)
          .collection('sharedItems')
          .get();

      final personalItemIds =
          sharedItemsSnapshot.docs.map((doc) => doc.id).toSet();

      _firestore.collection('items').snapshots().listen((snapshot) {
        final List<Item> itemsList = [];

        // Filter items that are not in personalItems
        for (var doc in snapshot.docs) {
          final id = doc.id;
          if (!personalItemIds.contains(id)) {
            final data = doc.data() as Map<String, dynamic>;
            itemsList.add(Item(
              id: id,
              name: data['name'] ?? '',
              total: data['total'] ?? 1,
              isChecked: false,
            ));
          }
        }

        // Sort the filtered items
        final sortedItems = quickSort(itemsList, usageCount);

        // Convert sorted list back to map
        final sortedItemsMap = {for (var item in sortedItems) item.id: item};
        _itemsController.add(sortedItemsMap);
        onUpdate(sortedItemsMap);
      });
    }).catchError((error) {
      print("Error calculating usage count: $error");
    });
  }

  Future<Map<String, int>> _calculateUsageCount() async {
    final Map<String, int> usageCount = {};

    try {
      //Get the current party's isCooking and isCamping values
      final currentPartyDoc =
          await _firestore.collection('parties').doc(partyId).get();
      if (!currentPartyDoc.exists) {
        throw Exception("Current party not found");
      }

      final currentData = currentPartyDoc.data()!;
      final isCooking = currentData['isCooking'] as bool? ?? false;
      final isCamping = currentData['isCamping'] as bool? ?? false;

      //Find parties with the same isCooking and isCamping values
      final partiesSnapshot = await _firestore.collection('parties').get();
      final matchingParties = partiesSnapshot.docs.where((partyDoc) {
        final data = partyDoc.data();
        return data['isCooking'] == isCooking && data['isCamping'] == isCamping;
      });

      //Calculate usageCount for matching parties
      for (var partyDoc in matchingParties) {
        final sharedItemsSnapshot = await _firestore
            .collection('parties')
            .doc(partyDoc.id)
            .collection('sharedItems')
            .get();

        for (var itemDoc in sharedItemsSnapshot.docs) {
          final itemId = itemDoc.id;
          usageCount[itemId] = (usageCount[itemId] ?? 0) + 1;
        }
      }
    } catch (e) {
      print("Error in _calculateUsageCount: $e");
    }

    return usageCount;
  }

  /// Quick Sort algorithm for sorting items by usage count (descending order)
  List<Item> quickSort(List<Item> items, Map<String, int> usageCount) {
    if (items.length <= 1) return items;

    final pivot = items[items.length ~/ 2];
    final pivotCount = usageCount[pivot.id] ?? 0;

    final greater =
        items.where((item) => (usageCount[item.id] ?? 0) > pivotCount).toList();
    final equal = items
        .where((item) => (usageCount[item.id] ?? 0) == pivotCount)
        .toList();
    final less =
        items.where((item) => (usageCount[item.id] ?? 0) < pivotCount).toList();

    return quickSort(greater, usageCount) + equal + quickSort(less, usageCount);
  }

  void addNewItem(BuildContext context) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String itemName = '';
        return AlertDialog(
          title: const Text('Add New Shared Item'),
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
        _firestore.collection('sharedItems').add({
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
          .collection('sharedItems')
          .doc(item.id)
          .set({
        'name': item.name,
        'total': item.total,
        'isChecked': false,
      }).then((_) {
        print("Item '${item.name}' saved successfully.");

        _updateUsageSharedCount(item.id);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to save item '${item.name}': $error")),
        );
      });
    }

    Navigator.pop(context, selectedItems);
  }

  void _updateUsageSharedCount(String itemId) async {
    final itemDoc =
        await _firestore.collection('sharedItems').doc(itemId).get();
    if (itemDoc.exists) {
      final currentUsageCount = itemDoc.data()?['usageCount'] ?? 0;

      _firestore.collection('sharedItems').doc(itemId).update({
        'usageCount': currentUsageCount + 1,
      }).then((_) {
        print("Updated usageCount for item ID $itemId successfully.");
      }).catchError((error) {
        print("Failed to update usageCount for item ID $itemId: $error");
      });
    } else {
      print("Item not found with ID $itemId");
    }
  }

  void dispose() {
    _itemsController.close();
  }
}
