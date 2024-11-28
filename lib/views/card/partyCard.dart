part of 'card.dart';

class PartyCard extends StatefulWidget {
  final String partyId;
  final String userId;
  final String partyName;
  final String startDate;
  final String endDate;
  final String mountName;
  final String partyCode;
  final bool isCamping;
  final bool isCooking;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onFinish;
  final VoidCallback onPressed;
  final HomePageViewModel viewModel;

  const PartyCard({
    Key? key,
    required this.partyId,
    required this.userId,
    required this.partyName,
    required this.startDate,
    required this.endDate,
    required this.mountName,
    required this.partyCode,
    required this.isCamping,
    required this.isCooking,
    required this.onEdit,
    required this.onDelete,
    required this.onFinish,
    required this.onPressed,
    required this.viewModel,
  }) : super(key: key);

  @override
  _PartyCardState createState() => _PartyCardState();
}

class _PartyCardState extends State<PartyCard> {
  String role = 'member';

  @override
  void initState() {
    super.initState();
    widget.viewModel.getUserRole(widget.partyId, widget.userId, (fetchedRole) {
      setState(() {
        role = fetchedRole;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        title: Text(widget.partyName),
        subtitle: Text(
            'Start date: ${widget.startDate}\nEnd date: ${widget.endDate}'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: widget.onPressed,
              child: Text('See items'),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  widget.onEdit();
                } else if (value == 'Delete') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Party'),
                        content: Text(
                            'Are you sure you want to delete ${widget.partyName}?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              widget.onDelete();
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (value == 'Finish') {
                  widget.onFinish();
                } else if (value == 'Info') {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PartyDetail(
                        partyId: widget.partyId,
                        partyName: widget.partyName,
                        mountName: widget.mountName,
                        partyCode: widget.partyCode,
                        startDate: widget.startDate,
                        endDate: widget.endDate,
                        isCamping: widget.isCamping,
                        isCooking: widget.isCooking,
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (BuildContext context) {
                if (role == 'leader') {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'Finish',
                      child: ListTile(
                        leading: Icon(Icons.check),
                        title: Text('Finish Party'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit'),
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'Delete',
                      child: ListTile(
                        leading: Icon(Icons.delete),
                        title: Text('Delete'),
                      ),
                    ),
                  ];
                } else {
                  return <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'Info',
                      child: ListTile(
                        leading: Icon(Icons.info),
                        title: Text('Info'),
                      ),
                    ),
                  ];
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
