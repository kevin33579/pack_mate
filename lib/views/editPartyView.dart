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
  late TextEditingController _partyNameController;
  late TextEditingController _mountNameController;
  late TextEditingController _partyCodeController;
  DateTime? _startDate;
  DateTime? _endDate;
  bool isPressedCamping = false;
  bool isPressedCooking = false;

  @override
  void initState() {
    super.initState();
    _partyNameController = TextEditingController(text: widget.partyName);
    _mountNameController = TextEditingController(text: widget.mountName);
    _partyCodeController = TextEditingController(text: widget.partyCode);
    _startDate = DateFormat('d MMM yyyy').parse(widget.startDate);
    _endDate = DateFormat('d MMM yyyy').parse(widget.endDate);
    isPressedCamping = widget.isCamping;
    isPressedCooking = widget.isCooking;
  }

  @override
  void dispose() {
    _partyNameController.dispose();
    _mountNameController.dispose();
    _partyCodeController.dispose();
    super.dispose();
  }

  void _selectDate(BuildContext context, bool isStartDate) {
    showDatePicker(
      context: context,
      initialDate: isStartDate
          ? _startDate ?? DateTime.now()
          : _endDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((picked) {
      if (picked != null) {
        setState(() {
          if (isStartDate) {
            _startDate = picked;
          } else {
            _endDate = picked;
          }
        });
      }
    });
  }

  void _updateParty() {
    if (_formKey.currentState!.validate()) {
      // Format dates as "7 Nov 2024"
      final String startDateString = _startDate != null
          ? DateFormat('d MMM yyyy').format(_startDate!)
          : '';
      final String endDateString =
          _endDate != null ? DateFormat('d MMM yyyy').format(_endDate!) : '';

      FirebaseFirestore.instance
          .collection('parties')
          .doc(widget.partyId)
          .update({
        'partyName': _partyNameController.text,
        'mountName': _mountNameController.text,
        'startDate': startDateString,
        'endDate': endDateString,
        'isCamping': isPressedCamping,
        'isCooking': isPressedCooking,
        'partyCode': _partyCodeController.text,
      }).then((_) {
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update party: $error')),
        );
      });
    }
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
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Start Date',
                ),
                readOnly: true,
                onTap: () => _selectDate(context, true),
                controller: TextEditingController(
                  text: _startDate != null
                      ? DateFormat('d MMM yyyy').format(_startDate!)
                      : '',
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'End Date',
                ),
                readOnly: true,
                onTap: () => _selectDate(context, false),
                controller: TextEditingController(
                  text: _endDate != null
                      ? DateFormat('d MMM yyyy').format(_endDate!)
                      : '',
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: isPressedCamping,
                    onChanged: (bool? value) {
                      setState(() {
                        isPressedCamping = value ?? false;
                      });
                    },
                  ),
                  Text('Are you camping?'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: isPressedCooking,
                    onChanged: (bool? value) {
                      setState(() {
                        isPressedCooking = value ?? false;
                      });
                    },
                  ),
                  Text('Are you cooking?'),
                ],
              ),
              TextFormField(
                controller: _partyCodeController,
                decoration: InputDecoration(labelText: 'Party Code'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateParty,
                child: Text('Update Party'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
