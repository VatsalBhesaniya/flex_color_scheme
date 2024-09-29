import 'package:flutter/material.dart';

import '../../../../shared/const/app.dart';
import '../../../../shared/controllers/theme_controller.dart';
import '../../../../shared/utils/link_text_span.dart';
import '../../../../shared/widgets/universal/list_tile_reveal.dart';
import '../../../../shared/widgets/universal/showcase_material.dart';
import '../../../../shared/widgets/universal/slider_list_tile_reveal.dart';
import '../../shared/color_scheme_popup_menu.dart';
import 'chip_blend_colors_toggle_buttons.dart';

class ChipPanel extends StatelessWidget {
  const ChipPanel(this.controller, {super.key});
  final ThemeController controller;

  static final Uri _fcsFlutterIssue115827 = Uri(
    scheme: 'https',
    host: 'github.com',
    path: 'flutter/flutter/issues/115827',
  );

  static final Uri _fcsChipUmbrellaIssue115364 = Uri(
    scheme: 'https',
    host: 'github.com',
    path: 'flutter/flutter/issues/115364',
  );

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool useMaterial3 = theme.useMaterial3;
    final TextStyle spanTextStyle = theme.textTheme.bodySmall!;
    final TextStyle linkStyle = theme.textTheme.bodySmall!.copyWith(
        color: theme.colorScheme.primary, fontWeight: FontWeight.bold);

    // The most common logic for enabling Playground controls.
    final bool enableControl =
        controller.useSubThemes && controller.useFlexColorScheme;

    // Get effective platform default global radius.
    final double? effectiveRadius = App.effectiveRadius(controller);

    final String chipRadiusDefaultLabel =
        controller.chipBorderRadius == null && effectiveRadius == null
            ? '8 dp'
            : controller.chipBorderRadius == null &&
                    controller.defaultRadius != null
                ? 'global ${effectiveRadius!.toStringAsFixed(0)} dp'
                : '';

    final String selectedColor = controller.chipSchemeColor == null
        ? 'primary'
        : controller.chipSchemeColor!.name;

    // Paddings for the two column control layouts.
    const EdgeInsetsDirectional paddingStartColumn =
        EdgeInsetsDirectional.only(start: 16, end: 8);
    final EdgeInsetsDirectional paddingEndColumn =
        EdgeInsetsDirectional.only(start: 8, end: useMaterial3 ? 24 : 16);

    final bool useBlend =
        // ignore: avoid_bool_literals_in_conditional_expressions
        controller.chipBlendColors ?? (useMaterial3 ? false : true);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 8),
        ColorSchemePopupMenu(
          enabled: enableControl,
          title: const Text('Chip color'),
          defaultLabel:
              useBlend ? 'primary with 80% surface alpha blend' : 'surface',
          defaultLabelM2: useBlend
              ? 'primary with 80% surface alpha blend'
              : 'primaryContainer',
          defaultDisabledLabel: 'surface',
          defaultDisabledLabelM2: 'Black opacity 12%',
          defaultDisabledLabelDarkM2: 'White opacity 12%',
          value: controller.chipSchemeColor,
          onChanged: controller.setChipSchemeColor,
        ),
        ColorSchemePopupMenu(
          enabled: enableControl,
          title: const Text('Selected Chip color'),
          defaultLabel: useBlend
              ? '$selectedColor with 59% surface alpha blend'
              : 'secondaryContainer',
          defaultDisabledLabel: 'secondaryContainer',
          defaultDisabledLabelM2: 'Black opacity 24%',
          defaultDisabledLabelDarkM2: 'White opacity 24%',
          value: controller.chipSelectedSchemeColor,
          onChanged: controller.setChipSelectedSchemeColor,
        ),
        ColorSchemePopupMenu(
          enabled: enableControl,
          title: const Text('Choice Chip selected color'),
          defaultLabel: useBlend
              ? '$selectedColor with 59% surface alpha blend'
              : 'secondaryContainer',
          defaultDisabledLabel: 'secondaryContainer',
          defaultDisabledLabelM2: 'Black opacity 24%',
          defaultDisabledLabelDarkM2: 'White opacity 24%',
          value: controller.chipSecondarySelectedSchemeColor,
          onChanged: controller.setChipSecondarySelectedSchemeColor,
        ),
        ChipBlendColorsToggleButtons(controller: controller),
        ColorSchemePopupMenu(
          enabled: enableControl,
          title: const Text('Chip delete icon color'),
          defaultLabel: 'onSurfaceVariant',
          // defaultLabelM2: 'primary with 80% surface alpha blend',
          defaultDisabledLabelM2: 'Black opacity 87%',
          defaultDisabledLabelDarkM2: 'White opacity 87%',
          value: controller.chipDeleteIconSchemeColor,
          onChanged: controller.setChipDeleteIconSchemeColor,
        ),
        SliderListTileReveal(
          enabled: enableControl,
          title: const Text('Border radius'),
          value: controller.chipBorderRadius,
          onChanged: controller.setChipBorderRadius,
          min: 0,
          max: 40,
          divisions: 40,
          valueDecimalPlaces: 0,
          valueHeading: 'RADIUS',
          valueUnitLabel: ' dp',
          valueDefaultLabel: chipRadiusDefaultLabel,
          valueDefaultDisabledLabel: useMaterial3 ? '8 dp' : 'stadium',
        ),
        SliderListTileReveal(
          enabled: enableControl,
          title: const Text('Font size'),
          value: controller.chipFontSize,
          onChanged: controller.setChipFontSize,
          min: 8,
          max: 20,
          divisions: 12,
          valueDecimalPlaces: 0,
          valueHeading: 'SIZE',
          valueUnitLabel: ' dp',
          valueDefaultLabel: '14',
          valueDefaultDisabledLabel: useMaterial3 ? '14' : '16',
        ),
        ListTileReveal(
          enabled: controller.useSubThemes && controller.useFlexColorScheme,
          title: const Text('Padding'),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SliderListTileReveal(
                contentPadding: paddingStartColumn,
                trailingWidth: 52,
                enabled: enableControl,
                value: controller.chipPaddingStart,
                onChanged: controller.setChipPaddingStart,
                min: 0,
                max: 32,
                divisions: 32,
                valueDecimalPlaces: 0,
                valueHeading: 'START',
                valueUnitLabel: ' dp',
                valueDefaultLabel: useMaterial3 ? '8' : '4',
              ),
            ),
            Expanded(
              child: SliderListTileReveal(
                contentPadding: paddingEndColumn,
                trailingWidth: 60,
                enabled: enableControl,
                value: controller.chipPaddingEnd,
                onChanged: controller.setChipPaddingEnd,
                min: 0,
                max: 32,
                divisions: 32,
                valueDecimalPlaces: 0,
                valueHeading: 'END',
                valueUnitLabel: ' dp',
                valueDefaultLabel: useMaterial3 ? '8' : '4',
              ),
            ),
          ],
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: SliderListTileReveal(
                contentPadding: paddingStartColumn,
                trailingWidth: 52,
                enabled: enableControl,
                value: controller.chipPaddingTop,
                onChanged: controller.setChipPaddingTop,
                min: 0,
                max: 32,
                divisions: 32,
                valueDecimalPlaces: 0,
                valueHeading: 'TOP',
                valueUnitLabel: ' dp',
                valueDefaultLabel: useMaterial3 ? '8' : '4',
              ),
            ),
            Expanded(
              child: SliderListTileReveal(
                contentPadding: paddingEndColumn,
                trailingWidth: 60,
                enabled: enableControl,
                value: controller.chipPaddingBottom,
                onChanged: controller.setChipPaddingBottom,
                min: 0,
                max: 32,
                divisions: 32,
                valueDecimalPlaces: 0,
                valueHeading: 'BOTTOM',
                valueUnitLabel: ' dp',
                valueDefaultLabel: useMaterial3 ? '8' : '4',
              ),
            ),
          ],
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: ChipShowcase(showOptions: true),
        ),
        ListTileReveal(
          dense: true,
          title: const Text('Known issues'),
          subtitleReveal: RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  style: spanTextStyle,
                  text: 'Prior to version 3.13 Flutter Chip theming had severe '
                      'theming limitations and M3 styling gaps. You could not '
                      'make themed Chips where Selected chips required a '
                      'different text '
                      'contrast than the normal Chips. It was not possible to '
                      'define different Chip text styles for such a setup. See '
                      'Flutter SDK ',
                ),
                LinkTextSpan(
                  style: linkStyle,
                  uri: _fcsFlutterIssue115827,
                  text: 'issue #115827',
                ),
                // _fcsChipUmbrellaIssue115364
                TextSpan(
                  style: spanTextStyle,
                  text: '.\n\n'
                      'Fixes have been made in Flutter 3.13 to '
                      'support this, but it is still unverified and not yet '
                      'available in current FCS version. Until it is verified '
                      'and supported, prefer theme colors that work with the '
                      'default Chip text contrast color. '
                      'The Chip has a few other known issues, for a list and '
                      'their status of check the umbrella ',
                ),
                LinkTextSpan(
                  style: linkStyle,
                  uri: _fcsChipUmbrellaIssue115364,
                  text: 'issue #115364',
                ),
                TextSpan(
                  style: spanTextStyle,
                  text: '. Most of them are solved in Flutter 3.13.\n',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
