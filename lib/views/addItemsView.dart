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
  Map<String, Item> recommendedItems = {};
  Map<String, Item> otherItems = {};

  @override
  void initState() {
    super.initState();
    _viewModel.initialize(widget.partyId, widget.userId,
        onUpdate: (updatedItems) {
      setState(() {
        recommendedItems = updatedItems['recommended']!;
        otherItems = updatedItems['other']!;
        print("Updated recommended items count: ${recommendedItems.length}");
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
            icon: const Icon(Icons.add),
            onPressed: () {
              _viewModel.addNewItem(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              _viewModel.saveSelectedRecommendedItems(
                  recommendedItems, context);
              _viewModel.saveSelectedItems(otherItems, context);

              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Recommended Items Section
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Recommended Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  if (recommendedItems.isEmpty)
                    const Center(child: Text("No recommended items available."))
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: recommendedItems.length,
                        itemBuilder: (context, index) {
                          final item = recommendedItems.values
                              .toList()[index]; // Convert map to list
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
                ],
              ),
            ),
          ),
          // Other Items Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Other Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                if (otherItems.isEmpty)
                  const Center(child: Text("No other items available."))
                else
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: otherItems.length,
                    itemBuilder: (context, index) {
                      final item = otherItems.values.elementAt(index);
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }
}
