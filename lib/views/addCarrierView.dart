part of 'view.dart';

class AddCarrier extends StatefulWidget {
  final String itemName;
  final String itemId;
  final String partyId;

  AddCarrier({
    required this.itemName,
    required this.itemId,
    required this.partyId,
  });

  @override
  _AddCarrierState createState() => _AddCarrierState();
}

class _AddCarrierState extends State<AddCarrier> {
  final AddCarrierViewModel viewModel = AddCarrierViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.fetchMemberNames(widget.partyId);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Carrier'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: viewModel.selectedName != null &&
                    viewModel.totalController.text.isNotEmpty
                ? () => viewModel.saveCarrier(
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
