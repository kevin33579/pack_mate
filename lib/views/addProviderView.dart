part of 'view.dart';

class AddProvider extends StatefulWidget {
  final String itemName;
  final String itemId;
  final String partyId;

  AddProvider({
    required this.itemName,
    required this.itemId,
    required this.partyId,
  });

  @override
  _AddProviderState createState() => _AddProviderState();
}

class _AddProviderState extends State<AddProvider> {
  final AddProviderViewModel viewModel = AddProviderViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.fetchMemberNames(widget.partyId);
    setState(() {}); // Trigger the rebuild when the names are fetched
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Provider'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: viewModel.selectedName != null &&
                    viewModel.totalController.text.isNotEmpty
                ? () => viewModel.saveProvider(
                      partyId: widget.partyId,
                      itemId: widget.itemId,
                      context: context,
                    )
                : null,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Item: ${widget.itemName}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            TextField(
              controller: viewModel.totalController,
              decoration: const InputDecoration(labelText: 'Total'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Name'),
              items: viewModel.memberNames.map((name) {
                return DropdownMenuItem<String>(
                  value: name,
                  child: Text(name),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  viewModel.selectedName = newValue;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
