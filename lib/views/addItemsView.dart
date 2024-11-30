part of 'view.dart';

class AddItems extends StatefulWidget {
  final String userId;
  final String partyId;

  const AddItems({required this.userId, required this.partyId, Key? key})
      : super(key: key);

  @override
  _AddItemsState createState() => _AddItemsState();
}

class _AddItemsState extends State<AddItems> {
  final AddItemsViewModel _viewModel = AddItemsViewModel();
  Map<String, Item> items = {};

  @override
  void initState() {
    super.initState();
    _viewModel.initialize(widget.partyId, widget.userId,
        onUpdate: (updatedItems) {
      setState(() {
        items = updatedItems;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Personal Items'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _viewModel.saveSelectedItems(items, context);
            },
          ),
        ],
      ),
      body: StreamBuilder<Map<String, Item>>(
        stream: _viewModel.itemsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final items = snapshot.data!;
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(children: [
                const Center(
                  child: Text(
                    "No items available to add.",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _viewModel.addNewItem(context);
                  },
                  child: const Text("Add New Item"),
                ),
              ]),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items.values.elementAt(index);
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text(item.name),
                          subtitle: Text('Total: ${item.total}'),
                          trailing: Checkbox(
                            value: item.isChecked,
                            onChanged: (bool? value) {
                              setState(() {
                                item.isChecked = value ?? false;
                              });
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    _viewModel.addNewItem(context);
                  },
                  child: const Text("Add New Item"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
