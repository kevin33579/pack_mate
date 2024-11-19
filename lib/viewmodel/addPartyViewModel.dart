part of 'viewmodel.dart';

class AddPartyViewModel {
  final TextEditingController partyNameController = TextEditingController();
  final TextEditingController mountNameController = TextEditingController();
  final TextEditingController partyCodeController = TextEditingController();

  bool isPressedCamping = false;
  bool isPressedCooking = false;
  DateTime? startDate;
  DateTime? endDate;

  void selectDate(
    BuildContext context,
    bool isStartDate,
    Function(DateTime?) onDateSelected,
  ) {
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((picked) {
      if (picked != null) {
        if (isStartDate) {
          startDate = picked;
        } else {
          endDate = picked;
        }
        onDateSelected(picked);
      }
    });
  }

  void saveParty(BuildContext context) {
    final String startDateString =
        startDate != null ? DateFormat('d MMM yyyy').format(startDate!) : '';
    final String endDateString =
        endDate != null ? DateFormat('d MMM yyyy').format(endDate!) : '';

    final String partyName = partyNameController.text.trim();
    final String mountName = mountNameController.text.trim();
    final String partyCode = partyCodeController.text.trim();

    if (partyCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Party Code cannot be empty')),
      );
      return;
    }

    FirebaseFirestore.instance
        .collection('parties')
        .where('partyCode', isEqualTo: partyCode)
        .get()
        .then((querySnapshot) {
      if (querySnapshot.docs.isNotEmpty) {
        // Party code already exists
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Party Code already exists')),
        );
        return;
      }

      // If Party Code is unique, proceed to save
      final User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user is logged in')),
        );
        return;
      }

      final String userId = currentUser.uid;

      FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get()
          .then((userDoc) {
        if (!userDoc.exists) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User details not found')),
          );
          return;
        }

        final userData = userDoc.data()!;
        final memberData = {
          'firstName': userData['firstName'] ?? '',
          'lastName': userData['lastName'] ?? '',
          'phoneNumber': userData['phoneNumber'] ?? '',
          'email': userData['email'] ?? '',
          'role': 'leader',
        };

        final partyData = {
          'partyName': partyName,
          'mountName': mountName,
          'startDate': startDateString,
          'endDate': endDateString,
          'isCamping': isPressedCamping,
          'isCooking': isPressedCooking,
          'partyCode': partyCode,
          'isFinish': false,
          'sharedItems': [],
        };

        FirebaseFirestore.instance
            .collection('parties')
            .add(partyData)
            .then((partyRef) {
          partyRef.collection('members').doc(userId).set(memberData).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Party and member saved successfully!')),
            );
            Navigator.pop(context);
          }).catchError((e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to save member data: $e')),
            );
          });
        }).catchError((e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to save party: $e')),
          );
        });
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching user data: $e')),
        );
      });
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking Party Code: $e')),
      );
    });
  }

  void dispose() {
    partyNameController.dispose();
    mountNameController.dispose();
    partyCodeController.dispose();
  }
}
