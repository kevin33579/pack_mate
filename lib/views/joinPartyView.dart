part of 'view.dart';

class JoinParty extends StatefulWidget {
  static const String routeName = '/joinparty';

  @override
  State<JoinParty> createState() => _JoinPartyState();
}

class _JoinPartyState extends State<JoinParty> {
  final JoinPartyViewModel viewModel = JoinPartyViewModel();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Party'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: viewModel.partyCodeController,
              decoration: const InputDecoration(
                labelText: 'Enter Party Code',
              ),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: viewModel.isLoading
                  ? null
                  : () {
                      viewModel.joinParty(context);
                      setState(() {});
                    },
              child: viewModel.isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Join'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }
}
