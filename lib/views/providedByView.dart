part of 'view.dart';

class ProvidedBy extends StatelessWidget {
  final String partyId;
  final String itemId;
  final String itemName;

  ProvidedBy({
    required this.partyId,
    required this.itemId,
    required this.itemName,
  });

  Stream<List<Map<String, dynamic>>> _getProviders() {
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

  void _editProvider(BuildContext context, String providerId,
      String currentName, int currentTotal) {
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
        title: Text("Edit"),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: totalController,
                  decoration: InputDecoration(labelText: 'Total'),
                  keyboardType: TextInputType.number,
                ),
              ],
            );
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
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
            child: Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteProvider(BuildContext context, String providerId) {
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
        SnackBar(content: Text('Provider deleted successfully')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete provider: $error')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Providers'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddProvider(
                    itemId: itemId,
                    partyId: partyId,
                    itemName: itemName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getProviders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No providers found."));
          }

          final providers = snapshot.data!;
          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              final providerId = provider['id'];
              final providerName = provider['name'] ?? 'Unknown';
              final providerTotal = provider['total'] ?? 0;

              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    providerName,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Total: $providerTotal'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editProvider(
                            context, providerId, providerName, providerTotal);
                      } else if (value == 'delete') {
                        _deleteProvider(context, providerId);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
