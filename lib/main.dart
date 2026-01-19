import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'pages/home_page.dart';
import 'package:go_router/go_router.dart';
import 'pages/profile_view_page.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

void main() async {
  //firebase baslttik
  WidgetsFlutterBinding.ensureInitialized();

  usePathUrlStrategy();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Neo Card',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}

// router ayarlari
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const AuthWrapper()),

    // profil sayfası
    GoRoute(
      path: '/p/:uid',
      builder: (context, state) {
        final String uidFromUrl = state.pathParameters['uid']!;

        return ProfileViewPage(uid: uidFromUrl);
      },
    ),
  ],
);

// Kullanıcı içeride mi değil mi ona karar veriyoz
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // sayfa açildiğinda hayalet girişi tetikliyor
    _authService.signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: _authService.authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage(uid: snapshot.data!.uid);
        }

        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 20),
                Text("Kimlik Oluşturuluyor..."),
              ],
            ),
          ),
        );
      },
    );
  }
}
