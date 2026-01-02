import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/admin_controller.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  late final TextEditingController _tokenCtrl;
  late final TextEditingController _offlineCtrl;

  bool _syncedOnce = false;

  @override
  void initState() {
    super.initState();
    _tokenCtrl = TextEditingController();
    _offlineCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _tokenCtrl.dispose();
    _offlineCtrl.dispose();
    super.dispose();
  }

  void _syncFromStateIfNeeded(AdminState state) {
    // Synchronizujemy kontrolery z providerem tylko raz po wczytaniu danych
    // (żeby nie nadpisywać tego, co user właśnie wpisuje).
    if (_syncedOnce) return;
    if (state.isLoading) return;

    _tokenCtrl.text = state.token;
    _offlineCtrl.text = state.offlineMessage;
    _syncedOnce = true;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminControllerProvider);
    final ctrl = ref.read(adminControllerProvider.notifier);

    _syncFromStateIfNeeded(state);

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Admin')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text('Token urządzenia'),
            const SizedBox(height: 8),
            TextField(
              controller: _tokenCtrl,
              onChanged: ctrl.setTokenLocal,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Wklej token...',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await ctrl.saveToken();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Token zapisany')),
                );
              },
              child: const Text('Zapisz token'),
            ),

            const Divider(height: 32),

            const Text('Komunikat offline'),
            const SizedBox(height: 8),
            TextField(
              controller: _offlineCtrl,
              minLines: 2,
              maxLines: 4,
              onChanged: ctrl.setOfflineLocal,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tekst wyświetlany, gdy brak połączenia...',
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () async {
                await ctrl.saveOfflineMessage();
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Komunikat offline zapisany')),
                );
              },
              child: const Text('Zapisz komunikat offline'),
            ),
          ],
        ),
      ),
    );
  }
}
