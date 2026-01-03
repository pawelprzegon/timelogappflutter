import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/mode_controller.dart';

class ModeToggle extends ConsumerWidget {
  const ModeToggle({super.key, required this.isEnabled});
  final bool isEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(modeProvider);

    int toIndex(Mode m) => switch (m) {
      Mode.qr => 1,
      Mode.pin => 0,
    };

    Mode fromIndex(int i) => switch (i) {
      1 => Mode.qr,
      _ => Mode.pin,
    };

    final selectedIndex = toIndex(mode);

    return AbsorbPointer(
      absorbing: !isEnabled,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.55,
        child: _FullWidthSegmented(
          height: 80,
          radius: 20,
          selectedIndex: selectedIndex,
          onChanged: (i) => ref.read(modeProvider.notifier).state = fromIndex(i),
          items: const [
            _SegItem(icon: Icons.dialpad, text: 'PIN'),
            _SegItem(icon: Icons.qr_code, text: 'QR'),
          ],
        ),
      ),
    );
  }
}

class _SegItem {
  const _SegItem({required this.icon, required this.text});
  final IconData icon;
  final String text;
}

class _FullWidthSegmented extends StatelessWidget {
  const _FullWidthSegmented({
    required this.items,
    required this.selectedIndex,
    required this.onChanged,
    this.height = 60,
    this.radius = 20,
  });

  final List<_SegItem> items;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final borderColor = theme.colorScheme.outlineVariant;
    final selectedBg = theme.colorScheme.primaryContainer.withValues(alpha: 0.35);
    final selectedFg = theme.colorScheme.onSurface;
    final normalFg = theme.colorScheme.onSurface.withValues(alpha: 0.85);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: Row(
            children: List.generate(items.length, (i) {
              final isSelected = i == selectedIndex;
              final item = items[i];

              return Expanded(
                child: _SegmentCell(
                  height: height,
                  isSelected: isSelected,
                  showLeftDivider: i != 0,
                  dividerColor: borderColor,
                  backgroundColor: isSelected ? selectedBg : Colors.transparent,
                  foregroundColor: isSelected ? selectedFg : normalFg,
                  icon: item.icon,
                  text: item.text,
                  onTap: () => onChanged(i),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _SegmentCell extends StatelessWidget {
  const _SegmentCell({
    required this.height,
    required this.isSelected,
    required this.showLeftDivider,
    required this.dividerColor,
    required this.backgroundColor,
    required this.foregroundColor,
    required this.icon,
    required this.text,
    required this.onTap,
  });

  final double height;
  final bool isSelected;
  final bool showLeftDivider;
  final Color dividerColor;
  final Color backgroundColor;
  final Color foregroundColor;
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: showLeftDivider
              ? Border(left: BorderSide(color: dividerColor, width: 1))
              : null,
        ),
        child: SizedBox(
          height: height,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: isSelected ? 26 : 18, color: foregroundColor),
                const SizedBox(width: 10),
                Text(
                  text,
                  style: TextStyle(
                    fontSize: isSelected ? 26.0 : 18.0,
                    color: foregroundColor,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
