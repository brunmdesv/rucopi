import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'theme/theme_provider.dart';
import 'pages/login_page.dart';
import 'pages/dashboard_home_page.dart';
import 'pages/solicitacoes_route.dart';
import 'pages/configuracoes_route.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = GoRouter(
      initialLocation: '/home',
      redirect: (context, state) {
        final session = Supabase.instance.client.auth.currentSession;
        final loggingIn = state.uri.toString() == '/login';
        if (session == null && !loggingIn) return '/login';
        if (session != null && loggingIn) return '/home';
        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) =>
              LoginPage(key: ValueKey(DateTime.now().millisecondsSinceEpoch)),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => DashboardHomePage(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          ),
        ),
        GoRoute(
          path: '/solicitacoes',
          builder: (context, state) => SolicitacoesRoute(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          ),
        ),
        GoRoute(
          path: '/configuracoes',
          builder: (context, state) => ConfiguracoesRoute(
            key: ValueKey(DateTime.now().millisecondsSinceEpoch),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp.router(
      title: 'Dashboard Rucopi',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: _router,
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR'), Locale('en', 'US')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
