import 'package:clubz/core/providers/providers.dart';
import 'package:clubz/core/res/app_constants.dart';
import 'package:clubz/core/res/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The main widget for the flutter app.
class App extends ConsumerStatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  ConsumerState<App> createState() => _AppState();
}

class _AppState extends ConsumerState<App> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    ref.read(profileStateProvider);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      // Refresh current profile data when app is resumed.
      case AppLifecycleState.resumed:
        ref.read(profileStateProvider.notifier).getProfile();
        break;
      case AppLifecycleState.paused:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.hidden:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRoutes.router,
      title: 'Clubz',
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        switchTheme: SwitchThemeData(
            thumbColor: MaterialStateProperty.all(Colors.white),
            trackColor: MaterialStateProperty.resolveWith((states) =>
                states.contains(MaterialState.selected) ? Colors.white : null)),
        primaryColor: Colors.white,
        primaryColorDark: Colors.white,
        brightness: Brightness.dark,
        colorScheme: const ColorScheme.dark(primary: Colors.white),
        textButtonTheme: const TextButtonThemeData(
          style: ButtonStyle(
            padding: MaterialStatePropertyAll(EdgeInsets.all(0)),
            textStyle: MaterialStatePropertyAll(
              TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.normal),
          bodyMedium: TextStyle(
              color: Colors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.normal),
          displayLarge: TextStyle(
              color: Colors.white, fontSize: 24.0, fontWeight: FontWeight.w700),
          displayMedium: TextStyle(
              color: Colors.white, fontSize: 18.0, fontWeight: FontWeight.w700),
          displaySmall: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
              fontWeight: FontWeight.normal),
          headlineMedium: TextStyle(
              color: Color(0xFF999999),
              fontSize: 40.0,
              fontWeight: FontWeight.w500),
          titleMedium: TextStyle(color: Colors.white, fontSize: 18.0),
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.white,
        ),
        scaffoldBackgroundColor: AppConstants.colorScaffoldBackground,
      ),
    );
  }
}
