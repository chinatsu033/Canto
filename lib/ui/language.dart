import 'package:flutter/material.dart';
import '../l10n/gen/app_localizations.dart';
import '../src/controller.dart';
import '../src/theme.dart';

/// Languages offered in the picker, shown in their own script.
const languageOptions = <(String, String)>[
  ('zh', '简体中文'),
  ('zh_Hant', '繁體中文（台灣）'),
  ('zh_Hant_HK', '繁體中文（香港）'),
  ('en', 'English'),
  ('ja', '日本語'),
  ('ko', '한국어'),
  ('fr', 'Français'),
  ('de', 'Deutsch'),
  ('es', 'Español'),
  ('pt', 'Português (Brasil)'),
  ('it', 'Italiano'),
  ('ru', 'Русский'),
  ('ar', 'العربية'),
  ('th', 'ไทย'),
  ('vi', 'Tiếng Việt'),
  ('id', 'Bahasa Indonesia'),
  ('ms', 'Bahasa Melayu'),
  ('tr', 'Türkçe'),
  ('hi', 'हिन्दी'),
];

Future<void> showLanguagePicker(BuildContext context, CantoController c) {
  final l = AppLocalizations.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      Widget tile(String? tag, String label) => ListTile(
            dense: true,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(controlRadius)),
            selected: c.localeTag == tag,
            selectedTileColor: cs.primary.withValues(alpha: .10),
            title: Text(label),
            trailing: c.localeTag == tag ? Icon(Icons.check, color: cs.primary) : null,
            onTap: () {
              c.setLocaleTag(tag);
              Navigator.of(ctx).pop();
            },
          );
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * .8),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
              child: Text(l.language, style: Theme.of(ctx).textTheme.titleMedium),
            ),
            Flexible(
              child: ListView(shrinkWrap: true, padding: const EdgeInsets.symmetric(horizontal: 8), children: [
                tile(null, l.followSystem),
                for (final (tag, name) in languageOptions) tile(tag, name),
              ]),
            ),
          ]),
        ),
      );
    },
  );
}

/// Small rounded-square language button (mobile top bar).
class LanguageButton extends StatelessWidget {
  final CantoController controller;
  const LanguageButton({super.key, required this.controller});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 12, 0),
      child: Tooltip(
        message: AppLocalizations.of(context).language,
        child: Material(
          color: cs.surfaceContainer,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => showLanguagePicker(context, controller),
            child: SizedBox(width: 36, height: 32, child: Icon(Icons.translate, size: 18, color: cs.onSurfaceVariant)),
          ),
        ),
      ),
    );
  }
}
