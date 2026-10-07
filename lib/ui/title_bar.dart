import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../l10n/gen/app_localizations.dart';
import '../src/theme.dart';

/// Frameless desktop title bar: drag area, always-on-top, minimize, close.
class DesktopTitleBar extends StatefulWidget {
  const DesktopTitleBar({super.key});
  @override
  State<DesktopTitleBar> createState() => _DesktopTitleBarState();
}

class _DesktopTitleBarState extends State<DesktopTitleBar> {
  bool _pinned = true;

  @override
  void initState() {
    super.initState();
    windowManager.isAlwaysOnTop().then((v) => mounted ? setState(() => _pinned = v) : null).catchError((_) => null);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    Widget btn(IconData icon, String tip, VoidCallback onTap, {bool active = false}) => Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Tooltip(
            message: tip,
            child: Material(
              color: active ? cs.primary.withValues(alpha: .16) : cs.surfaceContainer,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: onTap,
                child: SizedBox(
                    width: 32, height: 28, child: Icon(icon, size: 16, color: active ? cs.primary : cs.onSurfaceVariant)),
              ),
            ),
          ),
        );
    return SizedBox(
      height: 40,
      child: Row(children: [
        Expanded(
          child: DragToMoveArea(
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 14),
              child: Text(l.appTitle,
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: cs.onSurfaceVariant)),
            ),
          ),
        ),
        btn(_pinned ? Icons.push_pin : Icons.push_pin_outlined, l.alwaysOnTop, () async {
          final v = !_pinned;
          await windowManager.setAlwaysOnTop(v);
          setState(() => _pinned = v);
        }, active: _pinned),
        btn(Icons.remove, l.minimize, () => windowManager.minimize()),
        btn(Icons.close, l.close, () => windowManager.close()),
        const SizedBox(width: 8),
      ]),
    );
  }
}

const desktopCornerRadius = cardRadius;
