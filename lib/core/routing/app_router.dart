import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/presentation/login_page.dart';
import '../../features/editor/presentation/editor_page.dart';
import '../../features/profile/presentation/profile_view_page.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshStream = GoRouterRefreshStream(
    Supabase.instance.client.auth.onAuthStateChange,
  );

  final router = GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshStream,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;

      // Mevzu burada: Hem normal path'e hem de fragment'a (hash sonrası) bakıyoruz!
      final path = state.uri.path;
      final fragment = state.uri.fragment;

      final isGoingToLogin = path == '/login';

      // Eğer yol VEYA parça /p/ ile başlıyorsa bu bir halka açık profildir!
      final isPublicProfile =
          path.startsWith('/p/') || fragment.startsWith('/p/');

      if (isPublicProfile) {
        return null; // Misafir, dokunma geçsin!
      }

      if (session == null && !isGoingToLogin) {
        return '/login';
      }

      if (session != null && isGoingToLogin) {
        return '/editor';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/editor', builder: (context, state) => const EditorPage()),
      GoRoute(
        path: '/p/:uid',
        builder: (context, state) {
          final uid = state.pathParameters['uid']!;
          return ProfileViewPage(uid: uid);
        },
      ),
    ],
  );

  ref.onDispose(() {
    refreshStream.dispose();
    router.dispose();
  });

  return router;
});
