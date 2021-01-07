import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';

void main() {
  //****************************************************************************
  // FlexColorScheme.toTheme unit tests.
  //
  // The ".toTheme" is the core function of `FlexColorScheme` to return a
  // ThemeData object from the defined color scheme.
  // Below we test that its key properties as as expected.
  //****************************************************************************
  group('FCS7: WITH FlexColorScheme.toTheme ', () {
    debugDefaultTargetPlatformOverride = null;
    TestWidgetsFlutterBinding.ensureInitialized();

    // themeLight = Default material light scheme colors.
    final ThemeData themeLight = const FlexColorScheme(
      brightness: Brightness.light,
      primary: FlexColor.materialLightPrimary,
      primaryVariant: FlexColor.materialLightPrimaryVariant,
      secondary: FlexColor.materialLightSecondary,
      secondaryVariant: FlexColor.materialLightSecondaryVariant,
    ).toTheme;
    // themeDark = Default material dark scheme colors.
    final ThemeData themeDark = const FlexColorScheme(
      brightness: Brightness.dark,
      primary: FlexColor.materialDarkPrimary,
      primaryVariant: FlexColor.materialDarkPrimaryVariant,
      secondary: FlexColor.materialDarkSecondary,
      secondaryVariant: FlexColor.materialDarkSecondaryVariant,
      // For the dark theme to be equal to ThemeData.from colorscheme dark we
      // have to override the computed onError color for the standard Material
      // dark error color. This is because the Material standard defines
      // the onColor for the used error color in the dark theme to Black instead
      // of white, which the Flutter brightness calculation algorithm says
      // it should use and that FlexColorScheme uses by default.
      // I don't know why they chose black for the text on the error color in
      // ColorScheme.dark, the white color that gets chosen based on their
      // own algorithm actually looks better. In Any case we just have to
      // specify the onError color then FlexColorScheme.toTheme uses that
      // instead of calculating from its default dark scheme error color.
      onError: Colors.black,
    ).toTheme;

    test(
        'FCS7.01: GIVEN a FlexColorScheme theme with Material scheme light '
        'colors EXPECT .colorScheme equality with ColorScheme.light().', () {
      expect(themeLight.colorScheme, const ColorScheme.light());
    });
    test(
        'FCS7.02: GIVEN a FlexColorScheme theme with Material scheme dark '
        'colors EXPECT .colorScheme equality with ColorScheme.dark().', () {
      expect(themeDark.colorScheme, const ColorScheme.dark());
    });

    //**************************************************************************
    // Test defaults and null input resulting in expected theme values.
    //**************************************************************************
    test(
        'FCS7.03: GIVEN a FlexColorScheme theme with Material scheme light '
        'colors EXPECT appbar theme color to be primary color.', () {
      expect(themeLight.appBarTheme.color, themeLight.colorScheme.primary);
    });

    test(
        'FCS7.04: GIVEN a FlexColorScheme theme with Material scheme dark '
        'colors EXPECT appbar theme color to be surface color.', () {
      expect(themeDark.appBarTheme.color, themeDark.colorScheme.surface);
    });

    test(
        'FCS7.05: GIVEN a FlexColorScheme theme with null VisualDensity input '
        'EXPECT VisualDensity().', () {
      expect(themeLight.visualDensity, const VisualDensity());
    });
    test(
        'FCS7.06: GIVEN a FlexColorScheme theme with null Typography input '
        'EXPECT Typography.material2018.', () {
      expect(themeLight.typography,
          Typography.material2018(platform: defaultTargetPlatform));
    });

    //**************************************************************************
    // Test result of some customizations that fixes ThemeData.from color
    // scheme compliance gaps.
    //**************************************************************************

    test(
        'FCS7.07: GIVEN a FlexColorScheme theme with Material scheme light '
        'colors EXPECT toggleableActiveColor equality with '
        'colorScheme.secondary.', () {
      expect(
        themeLight.toggleableActiveColor,
        themeLight.colorScheme.secondary,
      );
    });
    test(
        'FCS7.08: GIVEN a FlexColorScheme theme with Material scheme dark '
        'colors EXPECT toggleableActiveColor equality with '
        'colorScheme.secondary.', () {
      expect(
        themeDark.toggleableActiveColor,
        themeDark.colorScheme.secondary,
      );
    });
    final MaterialColor lightSwatch =
        FlexColorScheme.createPrimarySwatch(themeLight.colorScheme.primary);
    final MaterialColor darkSwatch =
        FlexColorScheme.createPrimarySwatch(themeDark.colorScheme.primary);

    test(
        'FCS7.09: GIVEN a FlexColorScheme theme with Material scheme light '
        'colors EXPECT primaryColorDark equality with '
        'createPrimarySwatch(primaryColor)[800].', () {
      expect(
        themeLight.primaryColorDark,
        lightSwatch[800],
      );
    });
    test(
        'FCS7.10: GIVEN a FlexColorScheme theme with Material scheme dark '
        'colors EXPECT primaryColorDark equality with '
        'createPrimarySwatch(primaryColor)[700].', () {
      expect(
        themeDark.primaryColorDark,
        darkSwatch[700],
      );
    });

    test(
        'FCS7.11: GIVEN a FlexColorScheme theme with Material scheme light '
        'colors EXPECT primaryColorLight equality with '
        'createPrimarySwatch(primaryColor)[100].', () {
      expect(
        themeLight.primaryColorLight,
        lightSwatch[100],
      );
    });
    test(
        'FCS7.12: GIVEN a FlexColorScheme theme with Material scheme dark '
        'colors EXPECT primaryColorLight equality with '
        'createPrimarySwatch(primaryColor)[100].', () {
      expect(
        themeDark.primaryColorLight,
        darkSwatch[100],
      );
    });

    test(
        'FCS7.13: GIVEN a FlexColorScheme theme with Material scheme light '
        'colors EXPECT secondaryHeaderColor equality with '
        'createPrimarySwatch(primaryColor)[50].', () {
      expect(
        themeLight.secondaryHeaderColor,
        lightSwatch[50],
      );
    });
    test(
        'FCS7.14: GIVEN a FlexColorScheme theme with Material scheme dark '
        'colors EXPECT secondaryHeaderColor equality with '
        'createPrimarySwatch(primaryColor)[50].', () {
      expect(
        themeDark.secondaryHeaderColor,
        darkSwatch[50],
      );
    });

    test(
        'FCS7.15: GIVEN a FlexColorScheme theme with Material scheme light '
        'colors EXPECT buttonColor equality with '
        'colorScheme.primary.', () {
      expect(
        themeLight.buttonColor,
        themeLight.colorScheme.primary,
      );
    });
    test(
        'FCS7.16: GIVEN a FlexColorScheme theme with Material scheme dark '
        'colors EXPECT buttonColor equality with '
        'colorScheme.primary.', () {
      expect(
        themeDark.buttonColor,
        themeDark.colorScheme.primary,
      );
    });

    //**************************************************************************
    // FlexColorScheme.light & dark factory tests. With MEDIUM surface branding.
    //
    // Test result with custom features like surface, appbar, tab bar options.
    //**************************************************************************

    final ThemeData tLightM = FlexColorScheme.light(
      colors: FlexColor.schemes[FlexScheme.material].light,
      surfaceStyle: FlexSurface.medium,
      appBarStyle: FlexAppBarStyle.material,
      appBarElevation: 1,
      // ignore: avoid_redundant_argument_values
      tabBarStyle: FlexTabBarStyle.forAppBar,
    ).toTheme;

    final ThemeData tDarkM = FlexColorScheme.dark(
      colors: FlexColor.schemes[FlexScheme.material].dark,
      surfaceStyle: FlexSurface.medium,
      appBarStyle: FlexAppBarStyle.primary,
      appBarElevation: 3,
      // ignore: avoid_redundant_argument_values
      tabBarStyle: FlexTabBarStyle.forAppBar,
    ).toTheme;

    test(
        'FCS7.17: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
        'WITH FlexAppBarStyle.material EXPECT appbar theme color '
        'FlexColor.materialLightSurface.', () {
      expect(tLightM.appBarTheme.color, FlexColor.materialLightSurface);
    });
    test(
        'FCS7.18: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
        'WITH FlexAppBarStyle.primary EXPECT appbar theme color '
        'colorScheme.primary.', () {
      expect(tDarkM.appBarTheme.color, tDarkM.colorScheme.primary);
    });

    test(
        'FCS7.19: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
        'WITH appBarElevation: 1 EXPECT appbar theme elevation 1.', () {
      expect(tLightM.appBarTheme.elevation, 1);
    });
    test(
        'FCS7.20: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
        'WITH appBarElevation: 3 EXPECT appbar theme elevation 3.', () {
      expect(tDarkM.appBarTheme.elevation, 3);
    });

    test(
        'FCS7.21: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
        'WITH FlexSurface.medium EXPECT surface Color(0xfffdfdfe).', () {
      expect(tLightM.colorScheme.surface, const Color(0xfffdfdfe));
    });
    test(
        'FCS7.22: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
        'WITH FlexSurface.medium EXPECT surface Color(0xff17151a).', () {
      expect(tDarkM.colorScheme.surface, const Color(0xff17151a));
    });

    test(
        'FCS7.23: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
        'WITH FlexSurface.medium EXPECT background Color(0xfff6f3fc).', () {
      expect(tLightM.colorScheme.background, const Color(0xfff6f3fc));
    });
    test(
        'FCS7.24: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
        'WITH FlexSurface.medium EXPECT background Color(0xff1d1922).', () {
      expect(tDarkM.colorScheme.background, const Color(0xff1d1922));
    });

    test(
        'FCS7.25: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
        'WITH FlexSurface.medium EXPECT scaffold '
        'background Color(0xffffffff).', () {
      expect(tLightM.scaffoldBackgroundColor, const Color(0xffffffff));
    });
    test(
        'FCS7.26: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
        'WITH FlexSurface.medium EXPECT scaffold '
        'background Color(0xff121212).', () {
      expect(tDarkM.scaffoldBackgroundColor, const Color(0xff121212));
    });

    test(
        'FCS7.27: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
        'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.material EXPECT '
        'indicator color black87.', () {
      expect(tLightM.indicatorColor, Colors.black87);
    });
    test(
        'FCS7.28: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
        'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.primary EXPECT '
        'indicator color black87.', () {
      expect(tDarkM.indicatorColor, Colors.black87);
    });

    test(
        'FCS7.29: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
        'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.material EXPECT '
        'TabBarTheme.labelColor black87.', () {
      expect(tLightM.tabBarTheme.labelColor, Colors.black87);
    });
    test(
        'FCS7.30: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
        'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.primary EXPECT '
        'TabBarTheme.labelColor black87.', () {
      expect(tDarkM.tabBarTheme.labelColor, Colors.black87);
    });

    test(
        'FCS7.31: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
        'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.material EXPECT '
        'TabBarTheme.unselectedLabelColor onSurface.withOpacity(0.6).', () {
      expect(tLightM.tabBarTheme.unselectedLabelColor,
          tLightM.colorScheme.onSurface.withOpacity(0.6));
    });
    test(
        'FCS7.32: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
        'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.primary EXPECT '
        'TabBarTheme.unselectedLabelColor black87.withOpacity(0.7)', () {
      expect(tDarkM.tabBarTheme.unselectedLabelColor,
          Colors.black87.withOpacity(0.7));
    });
  });

  //**************************************************************************
  // FlexColorScheme.light & dark factory tests. With HEAVY surface branding.
  //
  // Test result with custom features like surface, appbar, tab bar options.
  //**************************************************************************

  final ThemeData tLightH = FlexColorScheme.light(
    colors: FlexColor.schemes[FlexScheme.material].light,
    surfaceStyle: FlexSurface.heavy,
    appBarStyle: FlexAppBarStyle.background,
    appBarElevation: 2,
    tabBarStyle: FlexTabBarStyle.forBackground,
  ).toTheme;

  final ThemeData tDarkH = FlexColorScheme.dark(
    colors: FlexColor.schemes[FlexScheme.material].dark,
    surfaceStyle: FlexSurface.heavy,
    appBarStyle: FlexAppBarStyle.background,
    appBarElevation: 4,
    tabBarStyle: FlexTabBarStyle.forBackground,
  ).toTheme;

  test(
      'FCS7.17: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
      'WITH FlexAppBarStyle.background EXPECT appbar theme color '
      'colorScheme.background.', () {
    expect(tLightH.appBarTheme.color, tLightH.colorScheme.background);
  });
  test(
      'FCS7.18: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
      'WITH FlexAppBarStyle.background EXPECT appbar theme color '
      'colorScheme.background.', () {
    expect(tDarkH.appBarTheme.color, tDarkH.colorScheme.background);
  });

  test(
      'FCS7.19: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
      'WITH appBarElevation: 2 EXPECT appbar theme elevation 2.', () {
    expect(tLightH.appBarTheme.elevation, 2);
  });
  test(
      'FCS7.20: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
      'WITH appBarElevation: 4 EXPECT appbar theme elevation 4.', () {
    expect(tDarkH.appBarTheme.elevation, 4);
  });

  test(
      'FCS7.21: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
      'WITH FlexSurface.heavy EXPECT surface Color(0xfffaf8fe).', () {
    expect(tLightH.colorScheme.surface, const Color(0xfffaf8fe));
  });
  test(
      'FCS7.22: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
      'WITH FlexSurface.heavy EXPECT surface Color(0xff1e1a23).', () {
    expect(tDarkH.colorScheme.surface, const Color(0xff1e1a23));
  });

  test(
      'FCS7.23: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
      'WITH FlexSurface.heavy EXPECT background Color(0xfff0e9fb).', () {
    expect(tLightH.colorScheme.background, const Color(0xfff0e9fb));
  });
  test(
      'FCS7.24: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
      'WITH FlexSurface.heavy EXPECT background Color(0xff272030).', () {
    expect(tDarkH.colorScheme.background, const Color(0xff272030));
  });

  test(
      'FCS7.25: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
      'WITH FlexSurface.heavy EXPECT scaffold '
      'background Color(0xfffdfdfe).', () {
    expect(tLightH.scaffoldBackgroundColor, const Color(0xfffdfdfe));
  });
  test(
      'FCS7.26: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
      'WITH FlexSurface.heavy EXPECT scaffold '
      'background Color(0xff151416).', () {
    expect(tDarkH.scaffoldBackgroundColor, const Color(0xff151416));
  });

  test(
      'FCS7.27: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
      'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.material EXPECT '
      'indicator color primary.', () {
    expect(tLightH.indicatorColor, tLightH.colorScheme.primary);
  });
  test(
      'FCS7.28: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
      'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.primary EXPECT '
      'indicator color primary.', () {
    expect(tDarkH.indicatorColor, tDarkH.colorScheme.primary);
  });

  test(
      'FCS7.29: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
      'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.material EXPECT '
      'TabBarTheme.labelColor primary.', () {
    expect(tLightH.tabBarTheme.labelColor, tLightH.colorScheme.primary);
  });
  test(
      'FCS7.30: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
      'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.primary EXPECT '
      'TabBarTheme.labelColor primary.', () {
    expect(tDarkH.tabBarTheme.labelColor, tDarkH.colorScheme.primary);
  });

  test(
      'FCS7.31: GIVEN a FlexColorScheme.light theme FROM scheme "material" '
      'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.material EXPECT '
      'TabBarTheme.unselectedLabelColor onSurface.withOpacity(0.6).', () {
    expect(tLightH.tabBarTheme.unselectedLabelColor,
        tLightH.colorScheme.onSurface.withOpacity(0.6));
  });
  test(
      'FCS7.32: GIVEN a FlexColorScheme.dark theme FROM scheme "material" '
      'WITH FlexTabBarStyle.forAppBar and FlexAppBarStyle.primary EXPECT '
      'TabBarTheme.unselectedLabelColor onSurface.withOpacity(0.6)', () {
    expect(tDarkH.tabBarTheme.unselectedLabelColor,
        tDarkH.colorScheme.onSurface.withOpacity(0.6));
  });
}