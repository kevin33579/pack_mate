part of 'view.dart';

class ProvidedBy extends StatefulWidget {
  final String partyId;
  final String itemId;
  final String itemName;

  ProvidedBy({
    Key? key,
    required this.partyId,
    required this.itemId,
    required this.itemName,
  });

  @override
  State<ProvidedBy> createState() => _ProvidedByState();
}

class _ProvidedByState extends State<ProvidedBy> {
  final ProvidedByViewModel viewModel = ProvidedByViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.fetchTotalValues(
      widget.partyId,
      widget.itemId,
      () {
        setState(() {});
      },
    );
  }

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
                    itemId: widget.itemId,
                    partyId: widget.partyId,
                    itemName: widget.itemName,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: viewModel.getProviders(widget.partyId, widget.itemId),
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
                          partyId: widget.partyId,
                          itemId: widget.itemId,
                          providerId: providerId,
                          currentName: providerName,
                          currentTotal: providerTotal,
                        );
                      } else if (value == 'delete') {
                        viewModel.deleteProvider(
                          context,
                          partyId: widget.partyId,
                          itemId: widget.itemId,
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
