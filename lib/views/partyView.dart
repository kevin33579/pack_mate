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
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _showAddItemDialog() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('parties')
        .doc(widget.partyId)
        .collection('members')
        .doc(user.uid)
        .get()
        .then((userDoc) {
      bool isLeader = userDoc.data()?['role'] == 'leader';

      if (isLeader) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Add Item"),
              content: Text("Would you like to add a personal or shared item?"),
              actions: [
                ElevatedButton(
                  child: Text("Personal"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddItems(
                          userId: user.uid,
                          partyId: widget.partyId,
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: Text("Shared"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddItemsShared(
                          userId: user.uid,
                          partyId: widget.partyId,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddItems(
              userId: user.uid,
              partyId: widget.partyId,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Group Items'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _showAddItemDialog,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: 'Personal'),
            Tab(text: 'Shared'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ItemList(type: 'Personal', partyId: widget.partyId),
          ItemList(type: 'Shared', partyId: widget.partyId),
        ],
      ),
    );
  }
}
