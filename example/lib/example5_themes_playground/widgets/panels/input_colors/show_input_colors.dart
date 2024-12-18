import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';

import '../../../../shared/const/app_color.dart';
import '../../../../shared/controllers/theme_controller.dart';
import '../../shared/color_name_value.dart';
import '../../shared/color_picker_inkwell.dart';

// Display the colors in currently selected input color scheme, including
// their name and color code.
//
// Allow user to edit the colors, if we are we are viewing the last color
// scheme, which is the custom color scheme.
class ShowInputColors extends StatelessWidget {
  const ShowInputColors({
    super.key,
    required this.controller,
  });

  final ThemeController controller;

  // Return true if the color is light, meaning it needs dark text for contrast.
  static bool _isLight(final Color color) =>
      FlexSchemeOnColors.estimateErrorBrightness(color) == Brightness.light;

  // On color used when a theme color property does not have a theme onColor.
  static Color _onColor(final Color color) =>
      _isLight(color) ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    // Used to enable & disable color selection on the color boxes.
    // We can only pick colors when custom theme is selected, which is
    // last index in out list of color schemes.
    final bool isCustomTheme =
        (AppColor.schemes.length - 1) == controller.schemeIndex;
    // Are colors swapped?
    final bool swapLight = controller.swapPrimaryAndSecondaryLightColors;
    final bool swapDark = controller.swapPrimaryAndSecondaryDarkColors;
    // Show the input color values
    final bool showInputColor = controller.showSchemeInputColors;

    // Size of theme color presentation boxes
    const double boxWidth = 135;
    final double boxHeight = showInputColor ? 110 : 70;

    // Theme values...
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final bool isLight = theme.brightness == Brightness.light;
    final bool useMaterial3 = theme.useMaterial3;
    // These color values are also used if picking is cancelled to restore
    // previous color selection.
    final Color primary = colorScheme.primary;
    final Color primaryContainer = colorScheme.primaryContainer;
    final Color secondary = colorScheme.secondary;
    final Color secondaryContainer = colorScheme.secondaryContainer;
    final Color tertiary = colorScheme.tertiary;
    final Color tertiaryContainer = colorScheme.tertiaryContainer;
    final Color error = colorScheme.error;
    final Color errorContainer = colorScheme.errorContainer;

    // Get controller input colors, if we are using the to dark
    final FlexSchemeColor inputColor = isLight || controller.useToDarkMethod
        ? AppColor.scheme(controller).light
        : AppColor.scheme(controller).dark;

    // But error input dark mode colors also when we use toDark
    final FlexSchemeColor inputErrColor = isLight
        ? AppColor.scheme(controller).light
        : AppColor.scheme(controller).dark;

    // Input errorColors
    final Color inputErrorColor = inputErrColor.error ??
        (isLight ? FlexColor.materialLightError : FlexColor.materialDarkError);
    final Color inputOnErrorColor = _onColor(inputErrorColor);
    final Color inputErrorContainerColor = inputErrColor.errorContainer ??
        (isLight
            ? FlexColor.lightErrorContainer(inputErrorColor)
            : FlexColor.darkErrorContainer(inputErrorColor));
    final Color inputOnErrorContainerColor = _onColor(inputErrorContainerColor);

    // Grab the card border from the theme card shape
    ShapeBorder? border = theme.cardTheme.shape;
    // If we had one, copy in a border side to it.
    if (border is RoundedRectangleBorder) {
      border = border.copyWith(
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      );
      // else
    } else {
      // If border was null, make one matching Card default, but with border
      // side, if it was not null, we leave it as it was.
      border ??= RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(useMaterial3 ? 12 : 4)),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      );
    }
    // Wrap this widget branch in a custom theme where card has a border outline
    // if it did not have one, but retains in ambient themed border radius.
    return Theme(
      data: theme.copyWith(
        cardTheme: CardTheme.of(context).copyWith(
          elevation: 0,
          shape: border,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 6,
        runSpacing: 6,
        children: <Widget>[
          // Primary color
          RepaintBoundary(
            key: const ValueKey<String>('input_primary'),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isCustomTheme ? 2 : 0,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: primary,
                  child: ColorPickerInkWellDialog(
                    color: primary,
                    onChanged: (Color color) {
                      if (isLight) {
                        swapLight
                            ? controller.setCustomSecondaryLight(color)
                            : controller.setCustomPrimaryLight(color);
                      } else {
                        swapDark
                            ? controller.setCustomSecondaryDark(color)
                            : controller.setCustomPrimaryDark(color);
                      }
                    },
                    recentColors: controller.recentColors,
                    onRecentColorsChanged: controller.setRecentColors,
                    wasCancelled: (bool cancelled) {
                      if (cancelled) {
                        if (isLight) {
                          swapLight
                              ? controller.setCustomSecondaryLight(primary)
                              : controller.setCustomPrimaryLight(primary);
                        } else {
                          swapDark
                              ? controller.setCustomSecondaryDark(primary)
                              : controller.setCustomPrimaryDark(primary);
                        }
                      }
                    },
                    enabled: isCustomTheme,
                    child: ColorNameValue(
                      key: ValueKey<String>('ipc primary $primary'),
                      color: primary,
                      textColor: colorScheme.onPrimary,
                      label: 'primary',
                      showInputColor: showInputColor,
                      inputColor: inputColor.primary,
                      inputTextColor: _onColor(inputColor.primary),
                      showMaterialName: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // PrimaryContainer color
          RepaintBoundary(
            key: const ValueKey<String>('input_primaryContainer'),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isCustomTheme ? 2 : 0,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: primaryContainer,
                  child: ColorPickerInkWellDialog(
                    color: primaryContainer,
                    onChanged: (Color color) {
                      if (isLight) {
                        swapLight
                            ? controller.setCustomSecondaryContainerLight(color)
                            : controller.setCustomPrimaryContainerLight(color);
                      } else {
                        swapDark
                            ? controller.setCustomSecondaryContainerDark(color)
                            : controller.setCustomPrimaryContainerDark(color);
                      }
                    },
                    recentColors: controller.recentColors,
                    onRecentColorsChanged: controller.setRecentColors,
                    wasCancelled: (bool cancelled) {
                      if (cancelled) {
                        if (isLight) {
                          swapLight
                              ? controller.setCustomSecondaryContainerLight(
                                  primaryContainer)
                              : controller.setCustomPrimaryContainerLight(
                                  primaryContainer);
                        } else {
                          swapDark
                              ? controller.setCustomSecondaryContainerDark(
                                  primaryContainer)
                              : controller.setCustomPrimaryContainerDark(
                                  primaryContainer);
                        }
                      }
                    },
                    enabled: isCustomTheme,
                    child: ColorNameValue(
                      key: ValueKey<String>('ipc primaryContainer '
                          '$primaryContainer'),
                      color: primaryContainer,
                      textColor: colorScheme.onPrimaryContainer,
                      label: 'primaryContainer',
                      showInputColor: showInputColor,
                      inputColor: inputColor.primaryContainer,
                      inputTextColor: _onColor(inputColor.primaryContainer),
                      showMaterialName: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Secondary color
          RepaintBoundary(
            key: const ValueKey<String>('input_secondary'),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isCustomTheme ? 2 : 0,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: secondary,
                  child: ColorPickerInkWellDialog(
                    color: secondary,
                    onChanged: (Color color) {
                      if (isLight) {
                        swapLight
                            ? controller.setCustomPrimaryLight(color)
                            : controller.setCustomSecondaryLight(color);
                      } else {
                        swapDark
                            ? controller.setCustomPrimaryDark(color)
                            : controller.setCustomSecondaryDark(color);
                      }
                    },
                    recentColors: controller.recentColors,
                    onRecentColorsChanged: controller.setRecentColors,
                    wasCancelled: (bool cancelled) {
                      if (cancelled) {
                        if (isLight) {
                          swapLight
                              ? controller.setCustomPrimaryLight(secondary)
                              : controller.setCustomSecondaryLight(secondary);
                        } else {
                          swapDark
                              ? controller.setCustomPrimaryDark(secondary)
                              : controller.setCustomSecondaryDark(secondary);
                        }
                      }
                    },
                    enabled: isCustomTheme,
                    child: ColorNameValue(
                      key: ValueKey<String>('ipc secondary $secondary'),
                      color: secondary,
                      textColor: colorScheme.onSecondary,
                      showInputColor: showInputColor,
                      label: 'secondary',
                      inputColor: inputColor.secondary,
                      inputTextColor: _onColor(inputColor.secondary),
                      showMaterialName: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // SecondaryContainer color
          RepaintBoundary(
            key: const ValueKey<String>('input_secondaryContainer'),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isCustomTheme ? 2 : 0,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: secondaryContainer,
                  child: ColorPickerInkWellDialog(
                    color: secondaryContainer,
                    onChanged: (Color color) {
                      if (isLight) {
                        swapLight
                            ? controller.setCustomPrimaryContainerLight(color)
                            : controller
                                .setCustomSecondaryContainerLight(color);
                      } else {
                        swapDark
                            ? controller.setCustomPrimaryContainerDark(color)
                            : controller.setCustomSecondaryContainerDark(color);
                      }
                    },
                    recentColors: controller.recentColors,
                    onRecentColorsChanged: controller.setRecentColors,
                    wasCancelled: (bool cancelled) {
                      if (cancelled) {
                        if (isLight) {
                          swapLight
                              ? controller.setCustomPrimaryContainerLight(
                                  secondaryContainer)
                              : controller.setCustomSecondaryContainerLight(
                                  secondaryContainer);
                        } else {
                          swapDark
                              ? controller.setCustomPrimaryContainerDark(
                                  secondaryContainer)
                              : controller.setCustomSecondaryContainerDark(
                                  secondaryContainer);
                        }
                      }
                    },
                    enabled: isCustomTheme,
                    child: ColorNameValue(
                      key: ValueKey<String>(
                          'ipc secondaryContainer $secondaryContainer'),
                      color: secondaryContainer,
                      textColor: colorScheme.onSecondaryContainer,
                      label: 'secondaryContainer',
                      showInputColor: showInputColor,
                      inputColor: inputColor.secondaryContainer,
                      inputTextColor: _onColor(inputColor.secondaryContainer),
                      showMaterialName: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tertiary color
          RepaintBoundary(
            key: const ValueKey<String>('input_tertiary'),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isCustomTheme ? 2 : 0,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: tertiary,
                  child: ColorPickerInkWellDialog(
                    color: tertiary,
                    onChanged: (Color color) {
                      if (isLight) {
                        controller.setCustomTertiaryLight(color);
                      } else {
                        controller.setCustomTertiaryDark(color);
                      }
                    },
                    recentColors: controller.recentColors,
                    onRecentColorsChanged: controller.setRecentColors,
                    wasCancelled: (bool cancelled) {
                      if (cancelled) {
                        if (isLight) {
                          controller.setCustomTertiaryLight(tertiary);
                        } else {
                          controller.setCustomTertiaryDark(tertiary);
                        }
                      }
                    },
                    enabled: isCustomTheme,
                    child: ColorNameValue(
                      key: ValueKey<String>('ipc tertiary $tertiary'),
                      color: tertiary,
                      textColor: colorScheme.onTertiary,
                      label: 'tertiary',
                      showInputColor: showInputColor,
                      inputColor: inputColor.tertiary,
                      inputTextColor: _onColor(inputColor.tertiary),
                      showMaterialName: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // TertiaryContainer color
          RepaintBoundary(
            key: const ValueKey<String>('input_tertiaryContainer'),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isCustomTheme ? 2 : 0,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: tertiaryContainer,
                  child: ColorPickerInkWellDialog(
                    color: tertiaryContainer,
                    onChanged: (Color color) {
                      if (isLight) {
                        controller.setCustomTertiaryContainerLight(color);
                      } else {
                        controller.setCustomTertiaryContainerDark(color);
                      }
                    },
                    recentColors: controller.recentColors,
                    onRecentColorsChanged: controller.setRecentColors,
                    wasCancelled: (bool cancelled) {
                      if (cancelled) {
                        if (isLight) {
                          controller.setCustomTertiaryContainerLight(
                              tertiaryContainer);
                        } else {
                          controller.setCustomTertiaryContainerDark(
                              tertiaryContainer);
                        }
                      }
                    },
                    enabled: isCustomTheme,
                    child: ColorNameValue(
                      key: ValueKey<String>(
                          'ipc tertiaryContainer $tertiaryContainer'),
                      color: tertiaryContainer,
                      textColor: colorScheme.onTertiaryContainer,
                      label: 'tertiaryContainer',
                      showInputColor: showInputColor,
                      inputColor: inputColor.tertiaryContainer,
                      inputTextColor: _onColor(inputColor.tertiaryContainer),
                      showMaterialName: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // New Error color
          RepaintBoundary(
            key: const ValueKey<String>('input_error'),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isCustomTheme ? 2 : 0,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: error,
                  child: ColorPickerInkWellDialog(
                    color: error,
                    onChanged: (Color color) {
                      if (isLight) {
                        controller.setCustomErrorLight(color);
                      } else {
                        controller.setCustomErrorDark(color);
                      }
                    },
                    recentColors: controller.recentColors,
                    onRecentColorsChanged: controller.setRecentColors,
                    wasCancelled: (bool cancelled) {
                      if (cancelled) {
                        if (isLight) {
                          controller.setCustomErrorLight(error);
                        } else {
                          controller.setCustomErrorDark(error);
                        }
                      }
                    },
                    enabled: isCustomTheme,
                    child: ColorNameValue(
                      key: ValueKey<String>('ipc error $error'),
                      color: error,
                      textColor: colorScheme.onError,
                      label: 'error',
                      showInputColor: showInputColor,
                      inputColor: inputErrorColor,
                      inputTextColor: inputOnErrorColor,
                      showMaterialName: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // New ErrorContainer color
          RepaintBoundary(
            key: const ValueKey<String>('input_errorContainer'),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: Card(
                margin: EdgeInsets.zero,
                elevation: isCustomTheme ? 2 : 0,
                clipBehavior: Clip.antiAlias,
                child: Material(
                  color: errorContainer,
                  child: ColorPickerInkWellDialog(
                    color: errorContainer,
                    onChanged: (Color color) {
                      if (isLight) {
                        controller.setCustomErrorContainerLight(color);
                      } else {
                        controller.setCustomErrorContainerDark(color);
                      }
                    },
                    recentColors: controller.recentColors,
                    onRecentColorsChanged: controller.setRecentColors,
                    wasCancelled: (bool cancelled) {
                      if (cancelled) {
                        if (isLight) {
                          controller
                              .setCustomErrorContainerLight(errorContainer);
                        } else {
                          controller
                              .setCustomErrorContainerDark(errorContainer);
                        }
                      }
                    },
                    enabled: isCustomTheme,
                    child: ColorNameValue(
                      key: ValueKey<String>(
                          'ipc errorContainer $errorContainer'),
                      color: errorContainer,
                      textColor: colorScheme.onErrorContainer,
                      label: 'errorContainer',
                      showInputColor: showInputColor,
                      inputColor: inputErrorContainerColor,
                      inputTextColor: inputOnErrorContainerColor,
                      showMaterialName: true,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
