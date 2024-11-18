part of 'viewmodel.dart';

class HomePageViewModel {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<List<DocumentSnapshot>> getUserParties() {
    final User? user = _auth.currentUser;
    if (user == null) {
      return Stream.empty();
    }

    final String userId = user.uid;

    return FirebaseFirestore.instance
        .collection('parties')
        .snapshots()
        .asyncMap((snapshot) async {
      List<DocumentSnapshot> userParties = [];

      for (var partyDoc in snapshot.docs) {
        final memberDoc =
            await partyDoc.reference.collection('members').doc(userId).get();

        if (memberDoc.exists) {
          userParties.add(partyDoc);
        }
      }

      return userParties;
    });
  }

  void finishParty(String partyId, BuildContext context) {
    FirebaseFirestore.instance
        .collection('parties')
        .doc(partyId)
        .update({'isFinish': true}).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Party marked as finished!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to finish party: $error')),
      );
    });
  }
}
