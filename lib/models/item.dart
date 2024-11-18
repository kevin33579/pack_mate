part of 'models.dart';

class Item {
  final String id;
  final String name;
  final int total;
  bool isChecked;

  Item({
    required this.id,
    required this.name,
    required this.total,
    this.isChecked = false,
  });
}
