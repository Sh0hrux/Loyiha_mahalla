import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/splash_screen.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/signup_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/complete_profile_page.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/data/models/user_model.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/ariza/presentation/pages/arizalar_page.dart';
import '../features/ariza/presentation/pages/yangi_ariza_page.dart';
import '../features/ariza/presentation/pages/ariza_detail_page.dart';
import '../features/muammo/presentation/pages/muammolar_page.dart';
import '../features/muammo/presentation/pages/yangi_muammo_page.dart';
import '../features/muammo/presentation/pages/muammo_detail_page.dart';
import '../features/navbat/presentation/pages/navbatlar_page.dart';
import '../features/navbat/presentation/pages/yangi_navbat_page.dart';
import '../features/navbat/presentation/pages/navbat_detail_page.dart';
import '../features/elon/presentation/pages/elonlar_page.dart';
import '../features/elon/presentation/pages/yangi_elon_page.dart';
import '../features/elon/presentation/pages/elon_detail_page.dart';
import '../features/mahalla_info/presentation/pages/mahalla_info_page.dart';
import '../features/xodimlar/presentation/pages/xodimlar_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/users/presentation/pages/foydalanuvchilar_page.dart';

// Router Provider
final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ValueNotifier<AsyncValue<UserModel?>>(const AsyncValue.loading());
  
  ref.listen<AsyncValue<UserModel?>>(currentUserProvider, (_, next) {
    notifier.value = next;
  });

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: notifier,
    redirect: (context, state) {
      // Get current user from provider
      final currentUserAsync = ref.read(currentUserProvider);
      
      final isLoading = currentUserAsync is AsyncLoading;
      final user = currentUserAsync.value;
      final isLoggedIn = user != null;
      final isProfileComplete = user?.fullName.isNotEmpty ?? false;
      final isAdmin = user?.role == 'admin';

      final path = state.matchedLocation;
      final isGoingToLogin = path == '/login';
      final isGoingToSignUp = path == '/signup';
      final isGoingToForgotPassword = path == '/forgot-password';
      final isGoingToCompleteProfile = path == '/complete-profile';
      final isGoingToSplash = path == '/splash';
      final isGoingToAdmin = path.startsWith('/admin');

      print('🔵 Router redirect: path=$path, isLoggedIn=$isLoggedIn, isAdmin=$isAdmin, isProfileComplete=$isProfileComplete'); // DEBUG

      // Show splash while loading
      if (isLoading) {
        if (!isGoingToSplash) return '/splash';
        return null;
      }

      // Not logged in - allow only auth pages
      if (!isLoggedIn) {
        if (isGoingToLogin || isGoingToSignUp || isGoingToForgotPassword || isGoingToSplash) {
          return null;
        }
        return '/login';
      }

      // Logged in but profile incomplete
      if (!isProfileComplete) {
        if (isGoingToCompleteProfile) return null;
        return '/complete-profile';
      }

      // Profile complete - redirect from auth pages
      if (isGoingToLogin || isGoingToSignUp || isGoingToForgotPassword || isGoingToCompleteProfile || isGoingToSplash) {
        final destination = isAdmin ? '/admin/dashboard' : '/home';
        print('🔵 Redirecting to: $destination'); // DEBUG
        return destination;
      }

      // Admin access control
      if (isGoingToAdmin && !isAdmin) {
        return '/home'; // Fuqaro can't access admin
      }

      // Redirect admin from home to dashboard
      if (isAdmin && path == '/home') {
        return '/admin/dashboard';
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
      GoRoute(
        path: '/muammo/:id',
        builder: (context, state) {
          final muammoId = state.pathParameters['id']!;
          return MuammoDetailPage(muammoId: muammoId);
        },
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
      GoRoute(
        path: '/navbat/:id',
        builder: (context, state) {
          final navbatId = state.pathParameters['id']!;
          return NavbatDetailPage(navbatId: navbatId);
        },
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

      // Admin Routes
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardPage(),
      ),
      GoRoute(
        path: '/admin/foydalanuvchilar',
        builder: (context, state) => const FoydalanuvchilarPage(),
      ),

      // TODO: Add more routes for other features
      // - /admin/reports (hisobotlar)
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sahifa topilmadi: ${state.matchedLocation}'),
      ),
    ),
  );
});
