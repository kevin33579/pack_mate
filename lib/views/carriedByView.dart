part of 'view.dart';

class CarriedBy extends StatelessWidget {
  final String partyId;
  final String itemId;
  final String itemName;

  CarriedBy(
      {required this.partyId, required this.itemId, required this.itemName});

  Stream<List<Map<String, dynamic>>> _getProviders() {
    return FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .collection('sharedItems')
        .doc(itemId)
        .collection('carriedBy')
        .snapshots()
        .asyncMap((snapshot) async {
      List<Map<String, dynamic>> allProviders = [];

      for (var doc in snapshot.docs) {
        var userData = doc.data();
        if (userData != null) {
          allProviders.add(userData);
        }
      }

      return allProviders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Carrier'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCarrier(
                    itemId: itemId,
                    partyId: partyId,
                    itemName: itemName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getProviders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No carriers found."));
          }

          final carriers = snapshot.data!;
          return ListView.builder(
            itemCount: carriers.length,
            itemBuilder: (context, index) {
              var carrier = carriers[index];
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    carrier['name'] ?? 'Unknown',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Total: ${carrier['total'] ?? 0}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
