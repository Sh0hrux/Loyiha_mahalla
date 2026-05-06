import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../app/theme.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              AppTheme.secondaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: currentUser.when(
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Foydalanuvchi topilmadi'));
            }

            final isAdmin = user.role == 'admin';

            return CustomScrollView(
              slivers: [
                // Gradient AppBar
                SliverAppBar(
                  expandedHeight: 200,
                  floating: false,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: const BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                      ),
                      child: SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Assalomu aleykum,',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user.fullName.isNotEmpty ? user.fullName : 'Foydalanuvchi',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      isAdmin ? Icons.admin_panel_settings : Icons.person,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      isAdmin ? 'Admin' : 'Fuqaro',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    // Notifications Icon
                    Container(
                      margin: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        icon: Stack(
                          children: [
                            const Icon(
                              Icons.notifications_outlined,
                              size: 28,
                            ),
                            // Badge for unread notifications
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 8,
                                  minHeight: 8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              title: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [Color(0xFFF59E0B), Color(0xFFEF4444)],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Bildirishnomalar'),
                                ],
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.notifications_off_outlined,
                                    size: 64,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Hozircha bildirishnomalar yo\'q',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[600],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Yangi arizalar, muammolar va e\'lonlar haqida bu yerda xabar olasiz',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text(
                                    'Yopish',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    // Profile Icon
                    Container(
                      margin: const EdgeInsets.only(right: 12),
                      child: IconButton(
                        icon: const Icon(
                          Icons.person_outline,
                          size: 28,
                        ),
                        onPressed: () {
                          context.push('/profile');
                        },
                      ),
                    ),
                  ],
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        // Section Title
                        Row(
                          children: [
                            Container(
                              width: 4,
                              height: 24,
                              decoration: BoxDecoration(
                                gradient: AppTheme.primaryGradient,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Xizmatlar',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Fuqaro uchun menyular
                        if (!isAdmin) ...[
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              _ModernMenuCard(
                                icon: Icons.description_outlined,
                                title: 'Arizalar',
                                subtitle: 'Ariza yuborish',
                                gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                onTap: () {
                                  context.push('/arizalar');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.report_problem_outlined,
                                title: 'Muammo bildirish',
                                subtitle: 'Muammo yuborish',
                                gradientColors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                                onTap: () {
                                  context.push('/muammolar');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.calendar_today_outlined,
                                title: 'Online navbat',
                                subtitle: 'Navbat band qilish',
                                gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                                onTap: () {
                                  context.push('/navbatlar');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.campaign_outlined,
                                title: 'E\'lonlar',
                                subtitle: 'Yangiliklar',
                                gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                                onTap: () {
                                  context.push('/elonlar');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.info_outline,
                                title: 'Mahalla haqida',
                                subtitle: 'Ma\'lumot',
                                gradientColors: const [Color(0xFF06B6D4), Color(0xFF0891B2)],
                                onTap: () {
                                  context.push('/mahalla-info');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.people_outline,
                                title: 'Xodimlar',
                                subtitle: 'Xodimlar ro\'yxati',
                                gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                onTap: () {
                                  context.push('/xodimlar');
                                },
                              ),
                            ],
                          ),
                        ],

                        // Admin uchun menyular
                        if (isAdmin) ...[
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.9,
                            children: [
                              _ModernMenuCard(
                                icon: Icons.dashboard_outlined,
                                title: 'Dashboard',
                                subtitle: 'Umumiy ko\'rinish',
                                gradientColors: const [Color(0xFF3B82F6), Color(0xFF2563EB)],
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Dashboard - Tez orada')),
                                  );
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.description_outlined,
                                title: 'Arizalar',
                                subtitle: 'Boshqarish',
                                gradientColors: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
                                onTap: () {
                                  context.push('/arizalar');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.report_problem_outlined,
                                title: 'Muammolar',
                                subtitle: 'Boshqarish',
                                gradientColors: const [Color(0xFFEF4444), Color(0xFFDC2626)],
                                onTap: () {
                                  context.push('/muammolar');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.campaign_outlined,
                                title: 'E\'lonlar',
                                subtitle: 'Boshqarish',
                                gradientColors: const [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                                onTap: () {
                                  context.push('/elonlar');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.people_outline,
                                title: 'Xodimlar',
                                subtitle: 'Boshqarish',
                                gradientColors: const [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                                onTap: () {
                                  context.push('/xodimlar');
                                },
                              ),
                              _ModernMenuCard(
                                icon: Icons.bar_chart_outlined,
                                title: 'Hisobotlar',
                                subtitle: 'Statistika va tahlil',
                                gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
                                onTap: () {
                                  context.push('/admin/hisobotlar');
                                },
                              ),
                            ],
                          ),
                        ],

                        const SizedBox(height: 32),

                        // Logout Button
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                              width: 1.5,
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await ref.read(currentUserProvider.notifier).signOut();
                                if (context.mounted) {
                                  context.go('/login');
                                }
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout_outlined,
                                      color: Colors.red[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Chiqish',
                                      style: TextStyle(
                                        color: Colors.red[600],
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Text('Xatolik: $error'),
          ),
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 28,
                  color: color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// Modern Menu Card with Gradient
class _ModernMenuCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final VoidCallback onTap;

  const _ModernMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.onTap,
  });

  @override
  State<_ModernMenuCard> createState() => _ModernMenuCardState();
}

class _ModernMenuCardState extends State<_ModernMenuCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: widget.gradientColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.gradientColors[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              _controller.forward().then((_) => _controller.reverse());
              widget.onTap();
            },
            onTapDown: (_) => _controller.forward(),
            onTapUp: (_) => _controller.reverse(),
            onTapCancel: () => _controller.reverse(),
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      widget.icon,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
