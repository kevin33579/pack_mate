part of 'view.dart';

class JoinParty extends StatefulWidget {
  static const String routeName = '/joinparty';

  @override
  State<JoinParty> createState() => _JoinPartyState();
}

class _JoinPartyState extends State<JoinParty> {
  final TextEditingController _partyCodeController = TextEditingController();
  bool _isLoading = false;

  void _joinParty() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final partyCode = _partyCodeController.text.trim();
    if (partyCode.isEmpty) {
      _showAlert('Party Code cannot be empty');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final partySnapshot = await FirebaseFirestore.instance
          .collection('parties')
          .where('partyCode', isEqualTo: partyCode)
          .get();

      if (partySnapshot.docs.isEmpty) {
        _showAlert('Party not found');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final partyDoc = partySnapshot.docs.first;
      final partyId = partyDoc.id;

      final memberSnapshot = await FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('members')
          .doc(user.uid)
          .get();

      if (memberSnapshot.exists) {
        _showAlert('You are already a member of this party');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (!userDoc.exists) {
        _showAlert('User data not found');
        setState(() {
          _isLoading = false;
        });
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

      await FirebaseFirestore.instance
          .collection('parties')
          .doc(partyId)
          .collection('members')
          .doc(user.uid)
          .set(memberData);

      _showAlert('Successfully joined the party');
    } catch (error) {
      print("Error joining party: $error");
      _showAlert('Failed to join party');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAlert(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Join Party'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _partyCodeController,
              decoration: InputDecoration(
                labelText: 'Enter Party Code',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _isLoading ? null : _joinParty,
              child: _isLoading ? CircularProgressIndicator() : Text('Join'),
            ),
          ],
        ),
      ),
    );
  }
}
