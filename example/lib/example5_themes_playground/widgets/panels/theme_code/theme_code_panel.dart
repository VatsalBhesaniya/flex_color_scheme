import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../../shared/controllers/theme_controller.dart';
import '../../../../shared/widgets/universal/list_tile_reveal.dart';
import '../../../../shared/widgets/universal/responsive_two_widgets.dart';
import '../../../../shared/widgets/universal/switch_list_tile_reveal.dart';
import '../../../../shared/widgets/universal/syntax_highlighter.dart';
import '../../../theme/theme_values.dart';
import '../../../utils/generate_theme_dart_code.dart';
import '../../../utils/import_export_playground_settings.dart';
import '../../dialogs/delete_settings_data.dart';
import '../../dialogs/import_settings_dialog.dart';
import 'show_code_theme_colors.dart';

/// Show the code for the currently configured FlexColorScheme theme setup.
///
/// Used by in a panel to show the code next to settings panels.
/// As theme settings are configured and changed, the generated setup code
/// is updated and can be copied to the clipboard at any point.
class ThemeCodePanel extends StatefulWidget {
  const ThemeCodePanel(this.controller, {super.key});

  final ThemeController controller;

  @override
  State<ThemeCodePanel> createState() => _ThemeCodePanelState();
}

class _ThemeCodePanelState extends State<ThemeCodePanel> {
  String playgroundConfig = '';
  String resultLog = '';

  @override
  void initState() {
    super.initState();
  }

  // Handle delete storage event.
  Future<void> _handleDeleteStorage(BuildContext context) async {
    final bool? reset = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return const DeleteSettingsDataDialog();
      },
    );
    if (reset ?? false) {
      await widget.controller.resetAllToDefaults(deleteLocalData: true);
      setState(() {
        playgroundConfig = '';
      });
    }
  }

  // Handle import settings request.
  Future<void> _handleImportRequest(BuildContext context) async {
    final bool? import = await showDialog<bool?>(
      context: context,
      builder: (BuildContext context) {
        return const ImportSettingsDialog();
      },
    );
    if (import ?? false) {
      if (context.mounted) await _handleImportPlaygroundTheme(context);
    }
  }

  // Handle clipboard copy event.
  //
  // Shows a snackbar with a message and copies the data to the clipboard.
  Future<void> _handleCopyEvent(
    BuildContext context,
    String clipBoardData,
    String message,
  ) async {
    final double? width = MediaQuery.sizeOf(context).width > 800 ? 700 : null;
    final ClipboardData data = ClipboardData(text: clipBoardData);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        width: width,
        content: Text(message),
        duration: const Duration(milliseconds: 2000),
      ),
    );
    await Clipboard.setData(data);
  }

  // Handle clipboard paste event.
  //
  // Copies plain text from the clipboard and set it as the playgroundConfig.
  Future<void> _handlePasteEvent() async {
    final ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data != null) {
      setState(() {
        playgroundConfig = data.text ?? '';
      });
    }
  }

  // Handle export playground theme event.
  Future<void> _handleExportPlaygroundTheme(BuildContext context) async {
    try {
      final String data = await exportPlaygroundSettings(widget.controller);
      if (context.mounted) {
        unawaited(
          _handleCopyEvent(
            context,
            data,
            'Themes Playground configuration copied to the clipboard!',
          ),
        );
        setState(() {
          playgroundConfig = data;
        });
      }
    } on Exception catch (error, stackTrace) {
      debugPrintStack(
        label: 'Error exporting playground theme data: $error',
        stackTrace: stackTrace,
      );
      if (context.mounted) {
        final double? width =
            MediaQuery.sizeOf(context).width > 800 ? 700 : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: width,
            content: Text('Unable to export playground settings, $error'),
            duration: const Duration(milliseconds: 2000),
          ),
        );
      }
    }
  }

  // Handle import playground theme event.
  Future<void> _handleImportPlaygroundTheme(BuildContext context) async {
    try {
      if (playgroundConfig.isNotEmpty) {
        resultLog = await importPlaygroundSettings(
          widget.controller,
          settings: playgroundConfig,
        );
        setState(() {});
      }
    } on Exception catch (error, stackTrace) {
      debugPrintStack(
        label: 'Error importing playground theme data: $error',
        stackTrace: stackTrace,
      );
      // Date time now formatted as string dd.MM.yyyy HH:mm:ss
      final String importDate =
          DateFormat('dd.MM.yyyy HH:mm:ss').format(DateTime.now());
      setState(() {
        resultLog = 'Failed to decode JSON at $importDate, error:\n$error';
      });
      if (context.mounted) {
        final double? width =
            MediaQuery.sizeOf(context).width > 800 ? 700 : null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            width: width,
            content: Text('Unable to import playground settings, $error'),
            duration: const Duration(milliseconds: 2000),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final String code = generateThemeDartCode(widget.controller);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 8),
        ResponsiveTwoWidgets(builder: (BuildContext context, bool isRow) {
          return RowOrColumn(
            firstWidget: ListTileReveal(
              contentPadding: ThemeValues.tilePaddingStart(context, isRow),
              title: const Text('Copy theme code'),
              subtitleReveal: const Text(
                'When you are happy with your theme design, you can copy the '
                'produced API configuration code. Paste it into your Flutter '
                'app and when used together with the FlexColorScheme package, '
                'your app gets the same theme.\n',
              ),
              trailing: Tooltip(
                message: 'Copy code',
                child: IconButton(
                  onPressed: () {
                    unawaited(_handleCopyEvent(
                      context,
                      code,
                      'FlexColorScheme setup code copied to the clipboard!',
                    ));
                  },
                  icon: const Icon(Icons.copy),
                ),
              ),
              onTap: () {
                unawaited(_handleCopyEvent(
                  context,
                  code,
                  'FlexColorScheme setup code copied to the clipboard!',
                ));
              },
            ),
            lastWidget: SwitchListTileReveal(
              contentPadding: ThemeValues.tilePaddingEnd(context, isRow),
              title: const Text('Separate file'),
              subtitleReveal: const Text(
                'Turn ON to get theme definitions '
                'intended for a separate file instead of using the '
                'theme definitions in your MaterialApp setup directly.\n',
              ),
              value: widget.controller.codeForFile,
              onChanged: widget.controller.setCodeForFile,
            ),
            isRow: isRow,
          );
        }),
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.all(16),
          child: SelectableText.rich(
            TextSpan(
              style: GoogleFonts.firaMono(fontSize: 12),
              children: <TextSpan>[
                DartSyntaxHighlighter(
                  SyntaxHighlighterStyle.harmonized(context),
                ).format(code),
              ],
            ),
          ),
        ),
        const Divider(height: 1),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: ShowCodeThemeColors(),
        ),
        const ListTileReveal(
          dense: true,
          title: Text('CodeTheme is a ThemeData ThemeExtension'),
          subtitleReveal: Text(
            'The above colors have been added as a custom theme '
            'extension to ThemeData. Light and dark mode CodeTheme change '
            'with theme mode and is accessed via Theme.of(context). The '
            'extension colors are also using Material-3 color harmonization '
            'with active theme. When you change theme you can see that '
            'these semantic CodeTheme colors are often automatically '
            'slightly adjusted towards the overall theme colors. '
            'This CodeTheme is used as a ThemeExtension example in the '
            'Themes Playground app. It also demonstrates how to use '
            'Material-3 color harmonization of custom theme colors in '
            'Flutter.\n'
            '\n'
            'The used icon colors for the theme topic buttons and icon on '
            'Settings panels headers, are using the '
            'same color harmonization. When you change themes you can '
            'notice that they also change color temperature to fit better '
            'with the ambient colors in the theme\n',
          ),
        ),
        const SizedBox(height: 16),
        ...switch (widget.controller.canImportExportThemeData()) {
          true => <Widget>[
              const SizedBox(height: 8),
              const Divider(height: 1),
              ListTileReveal(
                title: const Text('Export and Import Playground Settings'),
                subtitleReveal: Text(
                  'With this feature you can export '
                  'the current theme settings from the Themes Playground '
                  'app to a JSON string into the staging area below. '
                  'You can then paste this JSON string into a file and e.g. '
                  'keep the file in your project. The Themes Playground '
                  'settings can then be re-imported here if you need to '
                  "make design changes to your application's theme.\n"
                  '\n'
                  'Latest import log is shown below:\n'
                  '\n'
                  '$resultLog',
                ),
                tileColor: theme.colorScheme.surfaceContainer,
              ),
              const Divider(height: 1),
              const SizedBox(height: 8),
              ResponsiveTwoWidgets(builder: (BuildContext context, bool isRow) {
                return RowOrColumn(
                  firstWidget: ListTileReveal(
                    dense: true,
                    contentPadding:
                        ThemeValues.tilePaddingStart(context, isRow),
                    title: const Text('Export settings'),
                    subtitleReveal: const Text(
                      'Export theme settings to JSON to the staging '
                      'area below. Exported Settings are automatically put in '
                      'the clipboard as a string. You can '
                      'paste this JSON into a file and keep it with your '
                      'project. The settings can then be pasted and '
                      're-imported here if you need to make design '
                      'changes to your theme.',
                    ),
                    trailing: Tooltip(
                      message: 'Export settings',
                      child: IconButton(
                        onPressed: () {
                          unawaited(_handleExportPlaygroundTheme(context));
                        },
                        icon: const Icon(Icons.logout),
                      ),
                    ),
                    onTap: () {
                      unawaited(_handleExportPlaygroundTheme(context));
                    },
                  ),
                  lastWidget: ListTileReveal(
                    dense: true,
                    contentPadding: ThemeValues.tilePaddingEnd(context, isRow),
                    title: const Text('Copy settings'),
                    subtitleReveal: const Text(
                      'Copy theme settings from the staging area below '
                      'to the clipboard. When you export settings they are '
                      'also automatically copied to the clipboard.',
                    ),
                    trailing: Tooltip(
                      message: 'Copy settings',
                      child: IconButton(
                        onPressed: () {
                          unawaited(_handleCopyEvent(
                            context,
                            playgroundConfig,
                            'Themes Playground configuration copied to the '
                            'clipboard!',
                          ));
                        },
                        icon: const Icon(Icons.copy),
                      ),
                    ),
                    onTap: () {
                      unawaited(_handleCopyEvent(
                        context,
                        playgroundConfig,
                        'Themes Playground configuration copied to the '
                        'clipboard!',
                      ));
                    },
                  ),
                  isRow: isRow,
                );
              }),
              ResponsiveTwoWidgets(builder: (BuildContext context, bool isRow) {
                return RowOrColumn(
                  firstWidget: ListTileReveal(
                    dense: true,
                    contentPadding:
                        ThemeValues.tilePaddingStart(context, isRow),
                    title: const Text('Paste settings'),
                    subtitleReveal: const Text(
                      'Paste Themes Playground JSON settings from '
                      'clipboard data to the staging area below. '
                      'You can then import the staged settings '
                      'to set them as you current theme settings.',
                    ),
                    trailing: Tooltip(
                      message: 'Paste settings',
                      child: IconButton(
                        onPressed: () async {
                          await _handlePasteEvent();
                        },
                        icon: const Icon(Icons.paste),
                      ),
                    ),
                    onTap: () async {
                      await _handlePasteEvent();
                    },
                  ),
                  lastWidget: ListTileReveal(
                    dense: true,
                    enabled: playgroundConfig.isNotEmpty,
                    contentPadding: ThemeValues.tilePaddingEnd(context, isRow),
                    title: const Text('Import settings'),
                    subtitleReveal: const Text(
                      'Import theme settings exported previously from '
                      'the below paste input staging area.',
                    ),
                    trailing: Tooltip(
                      message: 'Import settings',
                      child: IconButton(
                        onPressed: () async {
                          await _handleImportRequest(context);
                        },
                        icon: const Icon(Icons.login),
                      ),
                    ),
                    onTap: () async {
                      await _handleImportRequest(context);
                    },
                  ),
                  isRow: isRow,
                );
              }),
              ResponsiveTwoWidgets(builder: (BuildContext context, bool isRow) {
                return RowOrColumn(
                  firstWidget: ListTileReveal(
                    dense: true,
                    enabled: playgroundConfig.isNotEmpty,
                    contentPadding:
                        ThemeValues.tilePaddingStart(context, isRow),
                    title: const Text('Clear staging area'),
                    subtitleReveal: const Text(
                      'This action only clears the staging area below '
                      'where you export, paste '
                      'and copy theme settings data from, it is not '
                      'destructive, just a way to clear the area.',
                    ),
                    trailing: IconButton(
                      icon: const Tooltip(
                        message: 'Clear staging area',
                        child: Icon(Icons.refresh),
                      ),
                      onPressed: () {
                        setState(() {
                          playgroundConfig = '';
                        });
                      },
                    ),
                    onTap: () {
                      setState(() {
                        playgroundConfig = '';
                      });
                    },
                  ),
                  lastWidget: ListTileReveal(
                    dense: true,
                    contentPadding: ThemeValues.tilePaddingEnd(context, isRow),
                    title: const Text('Delete local storage'),
                    subtitleReveal: const Text(
                      'All persisted theme settings in the local storage will '
                      'be deleted!\n'
                      '\n'
                      'This is useful for purging all keys from the local '
                      'storage including any invalid keys from older '
                      'Playground versions or invalid data inserted via '
                      'invalid JSON import keys.\n',
                    ),
                    trailing: IconButton(
                      icon: const Tooltip(
                        message: 'Delete local data',
                        child: Icon(Icons.delete),
                      ),
                      onPressed: () async {
                        await _handleDeleteStorage(context);
                      },
                    ),
                    onTap: () async {
                      await _handleDeleteStorage(context);
                    },
                  ),
                  isRow: isRow,
                );
              }),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Row(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: playgroundConfig.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'Staging import/export area is empty',
                                  ),
                                ),
                              )
                            : SelectableText(
                                playgroundConfig,
                                style: GoogleFonts.firaMono(fontSize: 11)
                                    .copyWith(color: theme.colorScheme.primary),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          false => <Widget>[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Card(
                  margin: EdgeInsets.zero,
                  child: Text(
                    'Playground theme export not supported with '
                    'current storage solution.',
                  ),
                ),
              ),
            ],
        },
        const SizedBox(height: 8),
      ],
    );
  }
}
