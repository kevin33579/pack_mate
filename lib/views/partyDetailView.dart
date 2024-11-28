part of 'view.dart';

class PartyDetail extends StatelessWidget {
  static const String routeName = '/party-detail';

  final String partyId;
  final String partyName;
  final String mountName;
  final String partyCode;
  final String startDate;
  final String endDate;
  final bool isCamping;
  final bool isCooking;

  const PartyDetail({
    Key? key,
    required this.partyId,
    required this.partyName,
    required this.mountName,
    required this.partyCode,
    required this.startDate,
    required this.endDate,
    required this.isCamping,
    required this.isCooking,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Party Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Party Name', partyName),
            _buildDetailRow('Mount Name', mountName),
            _buildDetailRow(
              'Start Date',
              DateFormat('d MMM yyyy').format(DateTime.parse(startDate)),
            ),
            _buildDetailRow(
              'End Date',
              DateFormat('d MMM yyyy').format(DateTime.parse(endDate)),
            ),
            _buildDetailRow('Camping', isCamping ? 'Yes' : 'No'),
            _buildDetailRow('Cooking', isCooking ? 'Yes' : 'No'),
            _buildDetailRow('Party Code', partyCode),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
