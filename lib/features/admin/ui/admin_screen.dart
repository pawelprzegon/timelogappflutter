import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:timelogappflutter/features/admin/widgets/labelTextField_widget.dart';
import 'package:timelogappflutter/features/admin/widgets/theme_accent_picker.dart';
import '../state/admin_controller.dart';
import '../../home/state/interaction_controller.dart';
import '../../home/state/interaction_state.dart';
import '../widgets/wakelock_toogle.dart';
import '../widgets/kiosk_toogle.dart';


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
        appBar: AppBar(
          title: const Text('Admin'),
          actions: [
            Text('Logs'),
            IconButton(
                onPressed: () => context.push('/logger'),
                icon: Icon(Icons.history)
            )
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [

              Card(
                margin: EdgeInsets.all(5.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: const KioskToggle(),
                ),
              ),


              Card(
                margin: EdgeInsets.all(5.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: const WakelockToggle(),
                )
              ),

              Card(
                margin: EdgeInsets.all(5.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 10,
                    children: [
                      LabeltextfieldWidget(
                        label: 'Token urządzenia',
                        controller: _tokenCtrl,
                        hintText: 'Wklej token...',
                        onChanged: ctrl.setTokenLocal,
                      ),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          foregroundColor: Colors.black,
                        ),
                        onPressed: () async {
                          await ctrl.saveToken();
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Token zapisany')),
                          );
                        },
                        child: const Text('Zapisz token'),
                      ),
                    ],
                  ),
                ),
              ),

              Card(
                margin: EdgeInsets.all(5.0),
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 10,
                    children: [
                      LabeltextfieldWidget(
                        label: 'Komunikat offline',
                        controller: _offlineCtrl,
                        TextInputMinLines: 2,
                        TextInputMaxLines: 4,
                        hintText: 'Tekst wyświetlany, gdy brak połączenia...',
                        onChanged: ctrl.setOfflineLocal,
                      ),


                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                          foregroundColor: Colors.black,
                        ),
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
              ),

            ],
          ),
        ),
        bottomNavigationBar: Container(
          padding: const EdgeInsets.all(12),
          color: Colors.blueGrey.withValues(alpha: 0.1),
          child: const AccentPicker(),
        ),
      ),
    );
  }
}
