part of 'viewmodel.dart';

class EditPartyViewModel {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late String partyId;
  late String partyName;
  late String mountName;
  late String partyCode;
  late DateTime startDate;
  late DateTime endDate;
  late bool isCamping;
  late bool isCooking;

  void initialize({
    required String partyId,
    required String partyName,
    required String mountName,
    required String partyCode,
    required String startDateString,
    required String endDateString,
    required bool isCamping,
    required bool isCooking,
  }) {
    this.partyId = partyId;
    this.partyName = partyName;
    this.mountName = mountName;
    this.partyCode = partyCode;
    this.startDate = DateFormat('d MMM yyyy').parse(startDateString);
    this.endDate = DateFormat('d MMM yyyy').parse(endDateString);
    this.isCamping = isCamping;
    this.isCooking = isCooking;
  }

  void selectDate({
    required BuildContext context,
    required bool isStartDate,
    required Function(DateTime) onDateSelected,
  }) {
    showDatePicker(
      context: context,
      initialDate: isStartDate ? startDate : endDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    ).then((pickedDate) {
      if (pickedDate != null) {
        onDateSelected(pickedDate);
        if (isStartDate) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      }
    });
  }

  void updateParty({
    required Function(String) onError,
    required Function() onSuccess,
  }) {
    final startDateString = DateFormat('d MMM yyyy').format(startDate);
    final endDateString = DateFormat('d MMM yyyy').format(endDate);

    _firestore.collection('parties').doc(partyId).update({
      'partyName': partyName,
      'mountName': mountName,
      'startDate': startDateString,
      'endDate': endDateString,
      'isCamping': isCamping,
      'isCooking': isCooking,
      'partyCode': partyCode,
    }).then((_) {
      onSuccess();
    }).catchError((error) {
      onError(error.toString());
    });
  }
}
