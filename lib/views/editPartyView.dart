part of 'view.dart';

class EditParty extends StatefulWidget {
  static const String routeName = '/edit-party';
  final String partyId;
  final String partyName;
  final String mountName;
  final String partyCode;
  final String startDate;
  final String endDate;
  final bool isCamping;
  final bool isCooking;

  EditParty({
    required this.partyId,
    required this.partyName,
    required this.mountName,
    required this.partyCode,
    required this.startDate,
    required this.endDate,
    required this.isCamping,
    required this.isCooking,
  });

  @override
  _EditPartyState createState() => _EditPartyState();
}

class _EditPartyState extends State<EditParty> {
  final _formKey = GlobalKey<FormState>();
  final EditPartyViewModel viewModel = EditPartyViewModel();

  late TextEditingController _partyNameController;
  late TextEditingController _mountNameController;
  late TextEditingController _partyCodeController;

  @override
  void initState() {
    super.initState();
    viewModel.initialize(
      partyId: widget.partyId,
      partyName: widget.partyName,
      mountName: widget.mountName,
      partyCode: widget.partyCode,
      startDateString: widget.startDate,
      endDateString: widget.endDate,
      isCamping: widget.isCamping,
      isCooking: widget.isCooking,
    );

    _partyNameController = TextEditingController(text: widget.partyName);
    _mountNameController = TextEditingController(text: widget.mountName);
    _partyCodeController = TextEditingController(text: widget.partyCode);
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _mountNameController.dispose();
    _partyCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Party'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _partyNameController,
                decoration: InputDecoration(labelText: 'Party Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a party name';
                  }
                  return null;
                },
                onChanged: (value) => viewModel.partyName = value,
              ),
              TextFormField(
                controller: _mountNameController,
                decoration: InputDecoration(labelText: 'Mount Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a mount name';
                  }
                  return null;
                },
                onChanged: (value) => viewModel.mountName = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Start Date'),
                readOnly: true,
                onTap: () => viewModel.selectDate(
                  context: context,
                  isStartDate: true,
                  onDateSelected: (date) {
                    setState(() {});
                  },
                ),
                controller: TextEditingController(
                  text: DateFormat('d MMM yyyy').format(viewModel.startDate),
                ),
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'End Date'),
                readOnly: true,
                onTap: () => viewModel.selectDate(
                  context: context,
                  isStartDate: false,
                  onDateSelected: (date) {
                    setState(() {});
                  },
                ),
                controller: TextEditingController(
                  text: DateFormat('d MMM yyyy').format(viewModel.endDate),
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: viewModel.isCamping,
                    onChanged: (value) {
                      setState(() {
                        viewModel.isCamping = value ?? false;
                      });
                    },
                  ),
                  Text('Are you camping?'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: viewModel.isCooking,
                    onChanged: (value) {
                      setState(() {
                        viewModel.isCooking = value ?? false;
                      });
                    },
                  ),
                  Text('Are you cooking?'),
                ],
              ),
              TextFormField(
                controller: _partyCodeController,
                decoration: InputDecoration(labelText: 'Party Code'),
                onChanged: (value) => viewModel.partyCode = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    viewModel.updateParty(
                      onSuccess: () => Navigator.pop(context),
                      onError: (error) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Failed to update party: $error')),
                        );
                      },
                    );
                  }
                },
                child: Text('Update Party'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
