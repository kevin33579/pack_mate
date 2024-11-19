part of 'viewmodel.dart';

class PartyViewModel {
  late TabController tabController;

  void initializeTabController(TickerProvider vsync) {
    tabController = TabController(length: 2, vsync: vsync);
  }

  void showAddItemDialog(
    BuildContext context, {
    required String partyId,
  }) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
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
              title: const Text("Add Item"),
              content: const Text(
                  "Would you like to add a personal or shared item?"),
              actions: [
                ElevatedButton(
                  child: const Text("Personal"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddItems(
                          userId: user.uid,
                          partyId: partyId,
                        ),
                      ),
                    );
                  },
                ),
                ElevatedButton(
                  child: const Text("Shared"),
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddItemsShared(
                          userId: user.uid,
                          partyId: partyId,
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
              partyId: partyId,
            ),
          ),
        );
      }
    });
  }

  void dispose() {
    tabController.dispose();
  }
}
