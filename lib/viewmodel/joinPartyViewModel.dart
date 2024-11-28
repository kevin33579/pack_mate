part of 'viewmodel.dart';

class JoinPartyViewModel {
  final TextEditingController partyCodeController = TextEditingController();
  bool isLoading = false;

  void joinParty(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _showAlert(context, 'No user is logged in');
      return;
    }

    final partyCode = partyCodeController.text.trim();
    if (partyCode.isEmpty) {
      _showAlert(context, 'Party Code cannot be empty');
      return;
    }

    isLoading = true;
    notifyListeners(context);

    FirebaseFirestore.instance
        .collection('parties')
        .where('partyCode', isEqualTo: partyCode)
        .get()
        .then((partySnapshot) {
      if (partySnapshot.docs.isEmpty) {
        _showAlert(context, 'Party not found');
        isLoading = false;
        notifyListeners(context);
        return;
      }

      final partyDoc = partySnapshot.docs.first;
      final partyId = partyDoc.id;

      FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('members')
          .doc(user.uid)
          .get()
          .then((memberSnapshot) {
        if (memberSnapshot.exists) {
          _showAlert(context, 'You are already a member of this party');
          isLoading = false;
          notifyListeners(context);
          return;
        }

        FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get()
            .then((userDoc) {
          if (!userDoc.exists) {
            _showAlert(context, 'User data not found');
            isLoading = false;
            notifyListeners(context);
            return;
          }

          final userData = userDoc.data()!;
          final memberData = {
            'email': userData['email'],
            'firstName': userData['firstName'],
            'lastName': userData['lastName'],
            'phoneNumber': userData['phoneNumber'],
            'role': 'member',
          };

          FirebaseFirestore.instance
              .collection('parties')
              .doc(partyId)
              .collection('members')
              .doc(user.uid)
              .set(memberData)
              .then((_) {
            _showAlert(context, 'Successfully joined the party');
            isLoading = false;
            notifyListeners(context);
          }).catchError((error) {
            print("Error adding member: $error");
            _showAlert(context, 'Failed to join party');
            isLoading = false;
            notifyListeners(context);
          });
        }).catchError((error) {
          print("Error fetching user data: $error");
          _showAlert(context, 'Failed to retrieve user data');
          isLoading = false;
          notifyListeners(context);
        });
      }).catchError((error) {
        print("Error checking membership: $error");
        _showAlert(context, 'Failed to verify membership');
        isLoading = false;
        notifyListeners(context);
      });
    }).catchError((error) {
      print("Error fetching party: $error");
      _showAlert(context, 'Failed to retrieve party data');
      isLoading = false;
      notifyListeners(context);
    });
  }

  void _showAlert(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void notifyListeners(BuildContext context) {
    if (context.mounted) {
      (context as Element).markNeedsBuild();
    }
  }

  void dispose() {
    partyCodeController.dispose();
  }
}
