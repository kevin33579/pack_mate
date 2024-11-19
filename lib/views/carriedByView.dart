part of 'view.dart';

class CarriedBy extends StatelessWidget {
  final String partyId;
  final String itemId;
  final String itemName;

  final CarriedByViewModel viewModel = CarriedByViewModel();

  CarriedBy({
    required this.partyId,
    required this.itemId,
    required this.itemName,
  });

  @override
  Widget build(BuildContext context) {
    viewModel.initialize(partyId: partyId, itemId: itemId);

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
        stream: viewModel.providersStream,
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
