part of 'view.dart';

class Party extends StatefulWidget {
  static const String routeName = '/party';

  final String partyId;

  Party({
    required this.partyId,
  });

  @override
  State<Party> createState() => _PartyState();
}

class _PartyState extends State<Party> with SingleTickerProviderStateMixin {
  final PartyViewModel viewModel = PartyViewModel();

  @override
  void initState() {
    super.initState();
    viewModel.initializeTabController(this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Group Items'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              viewModel.showAddItemDialog(context, partyId: widget.partyId);
            },
          ),
        ],
        bottom: TabBar(
          controller: viewModel.tabController,
          tabs: const [
            Tab(text: 'Personal'),
            Tab(text: 'Shared'),
          ],
        ),
      ),
      body: TabBarView(
        controller: viewModel.tabController,
        children: [
          ItemList(type: 'Personal', partyId: widget.partyId),
          ItemList(type: 'Shared', partyId: widget.partyId),
        ],
      ),
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
