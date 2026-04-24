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
      final isGoingToLogin = state.uri.path == '/login';
      final isPublicProfile = state.matchedLocation.startsWith('/p/');
      // Açık profilleri herkes görebilir, oturum zorunluluğunu bypass et
      if (isPublicProfile) return null;

      // Oturum yok ve login'e gitmiyorsa login'e at
      if (session == null && !isGoingToLogin) {
        return '/login';
      }

      // Oturum varsa ve login'e gitmeye çalışıyorsa editor'e at
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
