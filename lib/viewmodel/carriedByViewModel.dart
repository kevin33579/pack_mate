part of 'viewmodel.dart';

class CarriedByViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String partyId;
  late String itemId;

  final StreamController<List<Map<String, dynamic>>> _providersController =
      StreamController<List<Map<String, dynamic>>>.broadcast();

  Stream<List<Map<String, dynamic>>> get providersStream =>
      _providersController.stream;

  void initialize({required String partyId, required String itemId}) {
    this.partyId = partyId;
    this.itemId = itemId;

    // Listen to Firestore updates for carriers
    _firestore
        .collection('parties')
        .doc(partyId)
        .collection('sharedItems')
        .doc(itemId)
        .collection('carriedBy')
        .snapshots()
        .listen((snapshot) {
      List<Map<String, dynamic>> allProviders = snapshot.docs.map((doc) {
        return doc.data();
      }).toList();
      _providersController.add(allProviders);
    });
  }

  void dispose() {
    _providersController.close();
  }
}
