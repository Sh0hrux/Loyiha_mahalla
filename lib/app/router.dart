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
import '../features/xodimlar/presentation/pages/yangi_xodim_page.dart';
import '../features/xodimlar/data/models/xodim_model.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/admin/presentation/pages/admin_dashboard_page.dart';
import '../features/users/presentation/pages/foydalanuvchilar_page.dart';
import '../features/admin/presentation/pages/hisobotlar_page.dart';
import '../features/eslatma/presentation/pages/eslatmalar_page.dart';
import '../features/eslatma/presentation/pages/eslatma_detail_page.dart';
import '../features/eslatma/presentation/pages/yangi_eslatma_page.dart';

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

      print('🔵 Router redirect:');
      print('   path=$path');
      print('   isLoading=$isLoading');
      print('   isLoggedIn=$isLoggedIn');
      print('   isAdmin=$isAdmin');
      print('   isProfileComplete=$isProfileComplete');
      print('   user=${user?.id}');

      // Show splash while loading
      if (isLoading) {
        print('   ➡️ Loading, staying on splash');
        if (!isGoingToSplash) return '/splash';
        return null;
      }

      // Not logged in - allow only auth pages
      if (!isLoggedIn) {
        print('   ➡️ Not logged in');
        if (isGoingToLogin || isGoingToSignUp || isGoingToForgotPassword) {
          print('   ➡️ Allowing auth page');
          return null;
        }
        print('   ➡️ Redirecting to /login');
        return '/login';
      }

      // Logged in but profile incomplete
      if (!isProfileComplete) {
        print('   ➡️ Profile incomplete');
        if (isGoingToCompleteProfile) return null;
        print('   ➡️ Redirecting to /complete-profile');
        return '/complete-profile';
      }

      // Profile complete - redirect from auth pages
      if (isGoingToLogin || isGoingToSignUp || isGoingToForgotPassword || isGoingToCompleteProfile || isGoingToSplash) {
        final destination = isAdmin ? '/admin/dashboard' : '/home';
        print('   ➡️ Profile complete, redirecting to: $destination');
        return destination;
      }

      // Admin access control
      if (isGoingToAdmin && !isAdmin) {
        print('   ➡️ Non-admin trying to access admin, redirecting to /home');
        return '/home';
      }

      // Redirect admin from home to dashboard
      if (isAdmin && path == '/home') {
        print('   ➡️ Admin on home, redirecting to /admin/dashboard');
        return '/admin/dashboard';
      }

      print('   ➡️ No redirect needed');
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
      GoRoute(
        path: '/yangi-xodim',
        builder: (context, state) {
          final xodim = state.extra as XodimModel?;
          return YangiXodimPage(xodim: xodim);
        },
      ),

      // Profile Route
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfilePage(),
      ),

      // Eslatma Routes
      GoRoute(
        path: '/eslatmalar',
        builder: (context, state) => const EslatmalarPage(),
      ),
      GoRoute(
        path: '/eslatma-detail/:id',
        builder: (context, state) {
          final eslatmaId = state.pathParameters['id']!;
          return EslatmaDetailPage(eslatmaId: eslatmaId);
        },
      ),
      GoRoute(
        path: '/yangi-eslatma',
        builder: (context, state) => const YangiEslatmaPage(),
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
      GoRoute(
        path: '/admin/hisobotlar',
        builder: (context, state) => const HisobotlarPage(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sahifa topilmadi: ${state.matchedLocation}'),
      ),
    ),
  );
});
