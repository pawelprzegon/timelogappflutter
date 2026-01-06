
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LabeltextfieldWidget extends ConsumerWidget {
  // 1. Definiujemy argumenty jako pola final
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final int TextInputMinLines;
  final int TextInputMaxLines;
  final void Function(String)? onChanged;
  final bool isPassword;
  final String? Function(String?)? validator;

  // 2. Dodajemy je do konstruktora (wymagane lub opcjonalne)
  const LabeltextfieldWidget({
    super.key,
    required this.label,          // Etykieta musi być zawsze podana
    this.hintText,                // Podpowiedź jest opcjonalna
    this.controller,              // Kontroler do obsługi tekstu
    this.keyboardType = TextInputType.text, // Domyślnie klawiatura tekstowa
    this.TextInputMinLines = 1,
    this.TextInputMaxLines = 1,
    this.onChanged,
    this.isPassword = false,      // Domyślnie zwykłe pole
    this.validator,               // Funkcja do walidacji danych
  });


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: Column(
        // Wyrównujemy tekst etykiety do lewej krawędzi
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Etykieta nad polem
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w300,
              color: theme.colorScheme.onSurface.withAlpha(150),
            ),
          ),

          TextFormField(
            controller: controller,
            minLines: TextInputMinLines,
            // Jeśli to hasło, maxLines musi wynosić 1
            maxLines: isPassword ? 1 : TextInputMaxLines,
            onChanged: onChanged,
            keyboardType: keyboardType,
            obscureText: isPassword,
            validator: validator,
            decoration: InputDecoration(
              hintText: hintText,
              // Pełna ramka dookoła pola
              border: const OutlineInputBorder(),
              // Wypełnienie tła (opcjonalnie, dla lepszej widoczności)
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            ),
          ),
        ],
      ),
    );
  }
}