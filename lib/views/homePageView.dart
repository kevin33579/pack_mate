part of 'view.dart';

class HomePage extends StatefulWidget {
  static const String routeName = '/homepage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HomePageViewModel vm = HomePageViewModel();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Your Party'),
          actions: [
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () async {
                await Navigator.pushNamed(context, AddParty.routeName);
                setState(() {});
              },
            ),
          ],
          leading: null,
        ),
        body: StreamBuilder<List<DocumentSnapshot>>(
          stream: vm.getUserParties(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text("No parties found."));
            }

            final parties = snapshot.data!;
            return ListView.builder(
              itemCount: parties.length,
              itemBuilder: (context, index) {
                final party = parties[index];
                final partyId = party.id;
                final partyName = party['partyName'] ?? 'Unnamed Party';
                final mountName = party['mountName'] ?? 'Unnamed Mount';
                final startDate = party['startDate'] ?? 'No Start Date';
                final endDate = party['endDate'] ?? 'No End Date';
                final partyCode = party['partyCode'] ?? 'No Party Code';
                final isCamping = party['isCamping'] ?? false;
                final isCooking = party['isCooking'] ?? false;

                return PartyCard(
                  key: ValueKey(partyId),
                  partyName: partyName,
                  startDate: startDate,
                  endDate: endDate,
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditParty(
                          partyId: partyId,
                          partyName: partyName,
                          mountName: mountName,
                          partyCode: partyCode,
                          startDate: startDate,
                          endDate: endDate,
                          isCamping: isCamping,
                          isCooking: isCooking,
                        ),
                      ),
                    );
                  },
                  onDelete: () async {
                    await FirebaseFirestore.instance
                        .collection('parties')
                        .doc(partyId)
                        .delete();
                  },
                  onFinish: () {
                    vm.finishParty(partyId, context);
                  },
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Party(partyId: partyId),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
        floatingActionButton: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, JoinParty.routeName);
          },
          child: Text('Join Party'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
      ),
    );
  }
}
