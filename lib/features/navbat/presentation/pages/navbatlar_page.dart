import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/navbat_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../app/theme.dart';

class NavbatlarPage extends ConsumerWidget {
  const NavbatlarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Foydalanuvchi topilmadi')),
      );
    }

    final isAdmin = currentUser.role == 'admin';
    final navbatlarAsync = isAdmin
        ? ref.watch(allNavbatlarProvider)
        : ref.watch(userNavbatlarProvider(currentUser.id));

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.successColor.withOpacity(0.05),
              AppTheme.accentColor.withOpacity(0.05),
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
                  'Online Navbat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
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
            navbatlarAsync.when(
              data: (navbatlar) {
                if (navbatlar.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.calendar_today_outlined,
                      title: 'Navbatlar yo\'q',
                      subtitle: isAdmin
                          ? 'Hali hech qanday navbat band qilinmagan'
                          : 'Siz hali navbat band qilmagansiz',
                      onActionPressed:
                          isAdmin ? null : () => context.push('/yangi-navbat'),
                      actionLabel: isAdmin ? null : 'Navbat band qilish',
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final navbat = navbatlar[index];
                        return _ModernNavbatCard(
                          navbat: navbat,
                          isAdmin: isAdmin,
                          onUpdateStatus: isAdmin
                              ? (status) async {
                                  await ref
                                      .read(updateNavbatStatusProvider.notifier)
                                      .updateStatus(
                                        navbatId: navbat.id,
                                        status: status,
                                      );
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Navbat holati o\'zgartirildi'),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  }
                                }
                              : null,
                          onCancel: isAdmin
                              ? null
                              : () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Bekor qilish'),
                                      content: const Text(
                                          'Navbatni bekor qilmoqchimisiz?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, false),
                                          child: const Text('Yo\'q'),
                                        ),
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context, true),
                                          child: const Text('Ha'),
                                        ),
                                      ],
                                    ),
                                  );

                                  if (confirm == true) {
                                    await ref
                                        .read(updateNavbatStatusProvider.notifier)
                                        .cancelNavbat(navbat.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Navbat bekor qilindi'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                    }
                                  }
                                },
                        );
                      },
                      childCount: navbatlar.length,
                    ),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: LoadingWidget(),
              ),
              error: (error, stack) => SliverFillRemaining(
                child: CustomErrorWidget(
                  message: error.toString(),
                  onRetry: () {
                    ref.invalidate(isAdmin
                        ? allNavbatlarProvider
                        : userNavbatlarProvider(currentUser.id));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? null
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF10B981), Color(0xFF059669)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D10B981),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/yangi-navbat'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add),
                label: const Text('Navbat band qilish'),
              ),
            ),
    );
  }
}

class _ModernNavbatCard extends StatelessWidget {
  final dynamic navbat;
  final bool isAdmin;
  final Function(String)? onUpdateStatus;
  final VoidCallback? onCancel;

  const _ModernNavbatCard({
    required this.navbat,
    required this.isAdmin,
    this.onUpdateStatus,
    this.onCancel,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'kutilmoqda':
        return const Color(0xFF3B82F6);
      case 'tasdiqlandi':
        return const Color(0xFF10B981);
      case 'bekor_qilindi':
        return const Color(0xFFEF4444);
      case 'tugallandi':
        return const Color(0xFF6B7280);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'kutilmoqda':
        return Icons.hourglass_empty_outlined;
      case 'tasdiqlandi':
        return Icons.check_circle_outline;
      case 'bekor_qilindi':
        return Icons.cancel_outlined;
      case 'tugallandi':
        return Icons.done_all_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor(navbat.status);
    final statusIcon = _getStatusIcon(navbat.status);
    final isPast = navbat.appointmentDate.isBefore(DateTime.now());

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusColor,
                            statusColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        statusIcon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('dd MMMM yyyy', 'uz')
                                .format(navbat.appointmentDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                navbat.timeSlot,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusColor.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Text(
                        navbat.statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
              ),
              const SizedBox(height: 16),

              // Purpose
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          navbat.purpose,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
              ),

              // User info (Admin only)
              if (isAdmin) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              navbat.userFullName,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 18,
                            color: AppTheme.primaryColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              navbat.userPhone,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[800],
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],

              // Admin Actions (Admin only)
              if (isAdmin &&
                  navbat.status != 'tugallandi' &&
                  navbat.status != 'bekor_qilindi') ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    if (navbat.status == 'kutilmoqda') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onUpdateStatus?.call('tasdiqlandi'),
                          icon: const Icon(Icons.check_circle, size: 18),
                          label: const Text('Tasdiqlash'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    if (navbat.status == 'tasdiqlandi') ...[
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => onUpdateStatus?.call('tugallandi'),
                          icon: const Icon(Icons.done_all, size: 18),
                          label: const Text('Tugallandi'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[700],
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onUpdateStatus?.call('bekor_qilindi'),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Bekor qilish'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Cancel button (User only, if not past and not cancelled)
              if (!isAdmin &&
                  !isPast &&
                  navbat.status != 'bekor_qilindi' &&
                  navbat.status != 'tugallandi') ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.cancel_outlined),
                    label: const Text('Bekor qilish'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
