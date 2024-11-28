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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carriers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
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
        stream: viewModel.getCarriers(partyId, itemId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No carriers found."));
          }

          final carriers = snapshot.data!;
          return ListView.builder(
            itemCount: carriers.length,
            itemBuilder: (context, index) {
              final carrier = carriers[index];
              final carrierId = carrier['id'];
              final carrierName = carrier['name'] ?? 'Unknown';
              final carrierTotal = carrier['total'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    carrierName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Total: $carrierTotal'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        viewModel.editCarrier(context,
                            partyId: partyId,
                            itemId: itemId,
                            carrierId: carrierId,
                            currentName: carrierName,
                            currentTotal: carrierTotal);
                      } else if (value == 'delete') {
                        viewModel.deleteCarrier(
                          context,
                          partyId: partyId,
                          itemId: itemId,
                          carrierId: carrierId,
                        );
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
