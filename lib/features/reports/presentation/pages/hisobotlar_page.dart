import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/reports_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../app/theme.dart';

class HisobotlarPage extends ConsumerWidget {
  const HisobotlarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overallStatsAsync = ref.watch(overallStatsProvider);
    final arizalarByStatusAsync = ref.watch(arizalarByStatusProvider);
    final muammolarByStatusAsync = ref.watch(muammolarByStatusProvider);
    final navbatlarByStatusAsync = ref.watch(navbatlarByStatusProvider);
    final dailyStatsAsync = ref.watch(dailyStatsProvider);
    final mostActiveUsersAsync = ref.watch(mostActiveUsersProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.accentColor.withOpacity(0.05),
              AppTheme.primaryColor.withOpacity(0.05),
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Modern AppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Hisobotlar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.pop(),
              ),
            ),

            // Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Overall Statistics
                    overallStatsAsync.when(
                      data: (stats) => _OverallStatsSection(stats: stats),
                      loading: () => const LoadingWidget(),
                      error: (error, _) => CustomErrorWidget(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(overallStatsProvider),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Arizalar by Status
                    const Text(
                      'Arizalar holati',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    arizalarByStatusAsync.when(
                      data: (stats) => _StatusStatsCard(
                        stats: stats,
                        color: const Color(0xFF6366F1),
                      ),
                      loading: () => const LoadingWidget(),
                      error: (error, _) => CustomErrorWidget(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(arizalarByStatusProvider),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Muammolar by Status
                    const Text(
                      'Muammolar holati',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    muammolarByStatusAsync.when(
                      data: (stats) => _StatusStatsCard(
                        stats: stats,
                        color: const Color(0xFFEF4444),
                      ),
                      loading: () => const LoadingWidget(),
                      error: (error, _) => CustomErrorWidget(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(muammolarByStatusProvider),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Navbatlar by Status
                    const Text(
                      'Navbatlar holati',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    navbatlarByStatusAsync.when(
                      data: (stats) => _StatusStatsCard(
                        stats: stats,
                        color: const Color(0xFF10B981),
                      ),
                      loading: () => const LoadingWidget(),
                      error: (error, _) => CustomErrorWidget(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(navbatlarByStatusProvider),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Daily Stats (Last 7 days)
                    const Text(
                      'Oxirgi 7 kun statistikasi',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    dailyStatsAsync.when(
                      data: (stats) => _DailyStatsCard(stats: stats),
                      loading: () => const LoadingWidget(),
                      error: (error, _) => CustomErrorWidget(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(dailyStatsProvider),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Most Active Users
                    const Text(
                      'Eng faol foydalanuvchilar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 12),
                    mostActiveUsersAsync.when(
                      data: (users) => _MostActiveUsersCard(users: users),
                      loading: () => const LoadingWidget(),
                      error: (error, _) => CustomErrorWidget(
                        message: error.toString(),
                        onRetry: () => ref.invalidate(mostActiveUsersProvider),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverallStatsSection extends StatelessWidget {
  final Map<String, dynamic> stats;

  const _OverallStatsSection({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total = stats['total'] as Map<String, dynamic>;
    final thisMonth = stats['thisMonth'] as Map<String, dynamic>;
    final thisWeek = stats['thisWeek'] as Map<String, dynamic>;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Umumiy statistika',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.description,
                title: 'Arizalar',
                count: total['arizalar'] ?? 0,
                color: const Color(0xFF6366F1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.warning,
                title: 'Muammolar',
                count: total['muammolar'] ?? 0,
                color: const Color(0xFFEF4444),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.calendar_today,
                title: 'Navbatlar',
                count: total['navbatlar'] ?? 0,
                color: const Color(0xFF10B981),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                icon: Icons.campaign,
                title: 'E\'lonlar',
                count: total['elonlar'] ?? 0,
                color: const Color(0xFF8B5CF6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                icon: Icons.people,
                title: 'Foydalanuvchilar',
                count: total['users'] ?? 0,
                color: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(child: SizedBox()),
          ],
        ),
        const SizedBox(height: 24),
        // This Month
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shu oy',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(
                    label: 'Arizalar',
                    count: thisMonth['arizalar'] ?? 0,
                    color: const Color(0xFF6366F1),
                  ),
                  _MiniStat(
                    label: 'Muammolar',
                    count: thisMonth['muammolar'] ?? 0,
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // This Week
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shu hafta',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _MiniStat(
                    label: 'Arizalar',
                    count: thisWeek['arizalar'] ?? 0,
                    color: const Color(0xFF6366F1),
                  ),
                  _MiniStat(
                    label: 'Muammolar',
                    count: thisWeek['muammolar'] ?? 0,
                    color: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int count;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;

  const _MiniStat({
    required this.label,
    required this.count,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}

class _StatusStatsCard extends StatelessWidget {
  final Map<String, int> stats;
  final Color color;

  const _StatusStatsCard({
    required this.stats,
    required this.color,
  });

  String _getStatusText(String status) {
    switch (status) {
      case 'yuborildi':
        return 'Yuborildi';
      case 'ko\'rilmoqda':
        return 'Ko\'rilmoqda';
      case 'bajarildi':
        return 'Bajarildi';
      case 'rad_etildi':
        return 'Rad etildi';
      case 'hal_qilindi':
        return 'Hal qilindi';
      case 'kutilmoqda':
        return 'Kutilmoqda';
      case 'tasdiqlandi':
        return 'Tasdiqlandi';
      case 'tugallandi':
        return 'Tugallandi';
      case 'bekor_qilindi':
        return 'Bekor qilindi';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = stats.values.fold<int>(0, (sum, count) => sum + count);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ...stats.entries.map((entry) {
            final percentage = total > 0 ? (entry.value / total * 100) : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getStatusText(entry.key),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: total > 0 ? entry.value / total : 0,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class _DailyStatsCard extends StatelessWidget {
  final List<Map<String, dynamic>> stats;

  const _DailyStatsCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: stats.map((dayStat) {
          final date = dayStat['date'] as DateTime;
          final arizalar = dayStat['arizalar'] as int;
          final muammolar = dayStat['muammolar'] as int;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    DateFormat('dd MMM', 'uz').format(date),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF6366F1),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        arizalar.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        muammolar.toString(),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFEF4444),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _MostActiveUsersCard extends StatelessWidget {
  final List<Map<String, dynamic>> users;

  const _MostActiveUsersCard({required this.users});

  @override
  Widget build(BuildContext context) {
    if (users.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Faol foydalanuvchilar yo\'q',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: users.asMap().entries.map((entry) {
          final index = entry.key;
          final user = entry.value;
          final fullName = user['fullName'] as String;
          final total = user['total'] as int;
          final arizalar = user['arizalar'] as int;
          final muammolar = user['muammolar'] as int;
          final navbatlar = user['navbatlar'] as int;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor,
                        AppTheme.primaryColor.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fullName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'A: $arizalar, M: $muammolar, N: $navbatlar',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    total.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
