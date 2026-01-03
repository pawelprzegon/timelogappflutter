import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timelogappflutter/features/admin/ui/theme_accent_picker.dart';
import '../state/admin_controller.dart';
import '../../home/state/interaction_controller.dart';
import '../../home/state/interaction_state.dart';


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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(interactionProvider.notifier).state = InteractionState.admin;
    });
    //Dlaczego addPostFrameCallback?
    // Bo ref w initState działa, ale UI jeszcze się “montuje”. Ten callback gwarantuje, że robisz to po pierwszym renderze (bez dziwnych edge-case).
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

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          ref.read(interactionProvider.notifier).state = InteractionState.idle;
        }
      },
      child: Scaffold(
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
      
              const AccentPicker(),
            ],
          ),
        ),
      ),
    );
  }
}
