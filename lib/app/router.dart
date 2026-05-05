import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/complete_profile_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/ariza/presentation/pages/arizalar_page.dart';
import '../features/ariza/presentation/pages/yangi_ariza_page.dart';
import '../features/ariza/presentation/pages/ariza_detail_page.dart';
import '../features/muammo/presentation/pages/muammolar_page.dart';
import '../features/muammo/presentation/pages/yangi_muammo_page.dart';
import '../features/navbat/presentation/pages/navbatlar_page.dart';
import '../features/navbat/presentation/pages/yangi_navbat_page.dart';
import '../features/elon/presentation/pages/elonlar_page.dart';
import '../features/elon/presentation/pages/yangi_elon_page.dart';
import '../features/elon/presentation/pages/elon_detail_page.dart';
import '../features/mahalla_info/presentation/pages/mahalla_info_page.dart';
import '../features/xodimlar/presentation/pages/xodimlar_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final currentUser = ref.watch(currentUserProvider);

  return GoRouter(
    initialLocation: '/login',
    redirect: (context, state) {
      final isLoading = currentUser is AsyncLoading;
      final isLoggedIn = currentUser.value != null;
      final isProfileComplete = currentUser.value?.fullName.isNotEmpty ?? false;

      final isGoingToLogin = state.matchedLocation == '/login';
      final isGoingToSignUp = state.matchedLocation == '/signup';
      final isGoingToForgotPassword = state.matchedLocation == '/forgot-password';
      final isGoingToCompleteProfile = state.matchedLocation == '/complete-profile';
      final isGoingToSplash = state.matchedLocation == '/splash';

      // Show loading splash screen
      if (isLoading && !isGoingToSplash) {
        return '/splash';
      }

      // Loading finished, redirect from splash
      if (!isLoading && isGoingToSplash) {
        if (!isLoggedIn) {
          return '/login';
        } else if (!isProfileComplete) {
          return '/complete-profile';
        } else {
          return '/home';
        }
      }

      // Not logged in
      if (!isLoggedIn) {
        if (isGoingToLogin || isGoingToSignUp || isGoingToForgotPassword) {
          return null;
        }
        return '/login';
      }

      // Logged in but profile incomplete
      if (!isProfileComplete) {
        if (isGoingToCompleteProfile) {
          return null;
        }
        return '/complete-profile';
      }

      // Logged in and profile complete
      if (isGoingToLogin || isGoingToSignUp || isGoingToForgotPassword || isGoingToCompleteProfile) {
        return '/home';
      }

      return null;
    },
    routes: [
      // Splash/Loading Route
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      // Auth Routes
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpPage(),
      ),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: '/complete-profile',
        builder: (context, state) => const CompleteProfilePage(),
      ),

      // Main Routes
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomePage(),
      ),

      // Ariza Routes
      GoRoute(
        path: '/arizalar',
        builder: (context, state) => const ArizalarPage(),
      ),
      GoRoute(
        path: '/yangi-ariza',
        builder: (context, state) => const YangiArizaPage(),
      ),
      GoRoute(
        path: '/ariza/:id',
        builder: (context, state) {
          final arizaId = state.pathParameters['id']!;
          return ArizaDetailPage(arizaId: arizaId);
        },
      ),

      // Muammo Routes
      GoRoute(
        path: '/muammolar',
        builder: (context, state) => const MuammolarPage(),
      ),
      GoRoute(
        path: '/yangi-muammo',
        builder: (context, state) => const YangiMuammoPage(),
      ),

      // Navbat Routes
      GoRoute(
        path: '/navbatlar',
        builder: (context, state) => const NavbatlarPage(),
      ),
      GoRoute(
        path: '/yangi-navbat',
        builder: (context, state) => const YangiNavbatPage(),
      ),

      // Elon Routes
      GoRoute(
        path: '/elonlar',
        builder: (context, state) => const ElonlarPage(),
      ),
      GoRoute(
        path: '/yangi-elon',
        builder: (context, state) => const YangiElonPage(),
      ),
      GoRoute(
        path: '/elon/:id',
        builder: (context, state) {
          final elonId = state.pathParameters['id']!;
          return ElonDetailPage(elonId: elonId);
        },
      ),

      // Mahalla Info Route
      GoRoute(
        path: '/mahalla-info',
        builder: (context, state) => const MahallaInfoPage(),
      ),

      // Xodimlar Route
      GoRoute(
        path: '/xodimlar',
        builder: (context, state) => const XodimlarPage(),
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // TODO: Add more routes for other features
      // - /muammo/:id (detail page)
      // - /hisobotlar
      // - /statistika
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sahifa topilmadi: ${state.matchedLocation}'),
      ),
    ),
  );
});
