part of 'view.dart';

class AddParty extends StatefulWidget {
  static const String routeName = '/addparty';

  @override
  State<AddParty> createState() => _AddPartyState();
}

class _AddPartyState extends State<AddParty> {
  final AddPartyViewModel viewModel = AddPartyViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Party'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          ElevatedButton(
            onPressed: () => viewModel.saveParty(context),
            child: const Text('Save'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: viewModel.partyNameController,
                decoration: const InputDecoration(labelText: 'Party Name'),
              ),
              TextField(
                controller: viewModel.mountNameController,
                decoration: const InputDecoration(labelText: 'Mount Name'),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Start Date'),
                readOnly: true,
                onTap: () => viewModel.selectDate(context, true, (date) {
                  setState(() {});
                }),
                controller: TextEditingController(
                  text: viewModel.startDate != null
                      ? DateFormat('d MMM yyyy').format(viewModel.startDate!)
                      : '',
                ),
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'End Date'),
                readOnly: true,
                onTap: () => viewModel.selectDate(context, false, (date) {
                  setState(() {});
                }),
                controller: TextEditingController(
                  text: viewModel.endDate != null
                      ? DateFormat('d MMM yyyy').format(viewModel.endDate!)
                      : '',
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: viewModel.isPressedCamping,
                    onChanged: (value) {
                      setState(() {
                        viewModel.isPressedCamping = value ?? false;
                      });
                    },
                  ),
                  const Text('Are you camping?'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: viewModel.isPressedCooking,
                    onChanged: (value) {
                      setState(() {
                        viewModel.isPressedCooking = value ?? false;
                      });
                    },
                  ),
                  const Text('Are you cooking?'),
                ],
              ),
              TextField(
                controller: viewModel.partyCodeController,
                decoration: const InputDecoration(labelText: 'Party Code'),
              ),
            ],
          ),
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
