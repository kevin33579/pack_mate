part of 'view.dart';

class ItemList extends StatefulWidget {
  final String type;
  final String partyId;

  ItemList({required this.type, required this.partyId});

  @override
  _ItemListState createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final ItemListViewModel vm = ItemListViewModel();

  @override
  void initState() {
    super.initState();
    vm.getUserRole(widget.partyId, (role) {
      setState(() {
        vm.userRole = role;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DocumentSnapshot>>(
      stream: vm.getItems(widget.type, widget.partyId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text("No items found."));
        }

        final items = snapshot.data!;
        return ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final itemId = item.id;
            final itemData = item.data() as Map<String, dynamic>;
            final isChecked = itemData['isChecked'] ?? false;

            return ListTile(
              title: Text('${itemData['name']}'),
              subtitle: Text('Total: ${itemData['total']}'),
              trailing: widget.type == 'Shared'
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProvidedBy(
                                  partyId: widget.partyId,
                                  itemId: itemId,
                                  itemName: itemData['name'],
                                ),
                              ),
                            );
                          },
                          child: Text('provider'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CarriedBy(
                                  partyId: widget.partyId,
                                  itemId: itemId,
                                  itemName: itemData['name'],
                                ),
                              ),
                            );
                          },
                          child: Text('carrier'),
                        ),
                        if (vm.userRole == 'leader')
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                vm.editItemTotal(context, itemId,
                                    itemData['total'] ?? 0, widget.partyId);
                              } else if (value == 'delete') {
                                vm.deleteItem(itemId, context, widget.partyId);
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'edit',
                                child: Text('Edit Total'),
                              ),
                              PopupMenuItem(
                                value: 'delete',
                                child: Text('Delete Item'),
                              ),
                            ],
                          ),
                      ],
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Checkbox(
                          value: isChecked,
                          onChanged: (bool? value) {
                            vm.updateItemChecked(
                              partyId: widget.partyId,
                              itemId: itemId,
                              isChecked: value ?? false,
                            );
                          },
                        ),
                        PopupMenuButton<String>(
                          onSelected: (value) {
                            if (value == 'edit') {
                              vm.editItemTotal(context, itemId,
                                  itemData['total'] ?? 0, widget.partyId,
                                  isPersonal: true);
                            } else if (value == 'delete') {
                              vm.deleteItem(itemId, context, widget.partyId,
                                  isPersonal: true);
                            }
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'edit',
                              child: Text('Edit Total'),
                            ),
                            PopupMenuItem(
                              value: 'delete',
                              child: Text('Delete Item'),
                            ),
                          ],
                        ),
                      ],
                    ),
            );
          },
        );
      },
    );
  }
}
