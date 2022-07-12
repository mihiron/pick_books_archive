import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:pick_books/presentation/pages/auth/sign_in_page.dart';
import 'package:pick_books/presentation/res/theme.dart';
import 'package:pick_books/presentation/widgets/have_scroll_bar_behavior.dart';
import 'package:pick_books/utils/provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Pick Books',
      useInheritedMediaQuery: true,
      scrollBehavior: const HaveScrollBarBehavior(),
      theme: getAppTheme(),
      darkTheme: getAppThemeDark(),
      navigatorKey: ref.watch(navigatorKeyProvider),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ja', 'JP'),
      ],
      home: SignInPage(),
    );
  }
}
