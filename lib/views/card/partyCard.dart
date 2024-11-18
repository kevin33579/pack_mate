part of 'card.dart';

class PartyCard extends StatelessWidget {
  final String partyName;
  final String startDate;
  final String endDate;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onFinish;
  final VoidCallback onPressed;

  const PartyCard({
    Key? key,
    required this.partyName,
    required this.startDate,
    required this.endDate,
    required this.onEdit,
    required this.onDelete,
    required this.onFinish,
    required this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      child: ListTile(
        title: Text(partyName),
        subtitle: Text('Start date: $startDate\nEnd date: $endDate'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                onPressed();
              },
              child: Text('See items'),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'Edit') {
                  onEdit();
                } else if (value == 'Delete') {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Delete Party'),
                        content:
                            Text('Are you sure you want to delete $partyName?'),
                        actions: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              onDelete();
                              Navigator.of(context).pop();
                            },
                            child: Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );
                } else if (value == 'Finish') {
                  onFinish(); // Call onFinish when "Finish" is selected
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
