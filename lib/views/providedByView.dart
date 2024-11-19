part of 'view.dart';

class ProvidedBy extends StatelessWidget {
  final String partyId;
  final String itemId;
  final String itemName;

  ProvidedBy({
    required this.partyId,
    required this.itemId,
    required this.itemName,
  });

  final ProvidedByViewModel viewModel = ProvidedByViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers'),
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
                  builder: (context) => AddProvider(
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
        stream: viewModel.getProviders(partyId, itemId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No providers found."));
          }

          final providers = snapshot.data!;
          return ListView.builder(
            itemCount: providers.length,
            itemBuilder: (context, index) {
              final provider = providers[index];
              final providerId = provider['id'];
              final providerName = provider['name'] ?? 'Unknown';
              final providerTotal = provider['total'] ?? 0;

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(
                    providerName,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Total: $providerTotal'),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        viewModel.editProvider(
                          context,
                          partyId: partyId,
                          itemId: itemId,
                          providerId: providerId,
                          currentName: providerName,
                          currentTotal: providerTotal,
                        );
                      } else if (value == 'delete') {
                        viewModel.deleteProvider(
                          context,
                          partyId: partyId,
                          itemId: itemId,
                          providerId: providerId,
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
