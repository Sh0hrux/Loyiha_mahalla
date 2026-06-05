import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/elon_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../app/theme.dart';

class ElonlarPage extends ConsumerWidget {
  const ElonlarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;

    if (currentUser == null) {
      return const Scaffold(
        body: Center(child: Text('Foydalanuvchi topilmadi')),
      );
    }

    final isAdmin = currentUser.role == 'admin';
    final elonlarAsync =
        isAdmin ? ref.watch(allElonlarProvider) : ref.watch(activeElonlarProvider);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.secondaryColor.withValues(alpha: 0.05),
              AppTheme.primaryColor.withValues(alpha: 0.05),
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
                  'E\'lonlar',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
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
            elonlarAsync.when(
              data: (elonlar) {
                if (elonlar.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.campaign_outlined,
                      title: 'E\'lonlar yo\'q',
                      subtitle: isAdmin
                          ? 'Hali hech qanday e\'lon yaratilmagan'
                          : 'Hozircha e\'lonlar yo\'q',
                      onActionPressed:
                          isAdmin ? () => context.push('/yangi-elon') : null,
                      actionLabel: isAdmin ? 'E\'lon yaratish' : null,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final elon = elonlar[index];
                        return _ModernElonCard(
                          elon: elon,
                          isAdmin: isAdmin,
                          onTap: () {
                            context.push('/elon/${elon.id}');
                          },
                          onToggleStatus: isAdmin
                              ? () async {
                                  await ref
                                      .read(updateElonProvider.notifier)
                                      .toggleStatus(elon.id, !elon.isActive);
                                }
                              : null,
                          onDelete: isAdmin
                              ? () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('O\'chirish'),
                                      content: const Text(
                                          'E\'lonni o\'chirmoqchimisiz?'),
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
                                        .read(updateElonProvider.notifier)
                                        .deleteElon(elon.id);
                                  }
                                }
                              : null,
                        );
                      },
                      childCount: elonlar.length,
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
                    ref.invalidate(
                        isAdmin ? allElonlarProvider : activeElonlarProvider);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAdmin
          ? Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFA855F7)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D8B5CF6),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/yangi-elon'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add),
                label: const Text('E\'lon yaratish'),
              ),
            )
          : null,
    );
  }
}

class _ModernElonCard extends StatelessWidget {
  final dynamic elon;
  final bool isAdmin;
  final VoidCallback onTap;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onDelete;

  const _ModernElonCard({
    required this.elon,
    required this.isAdmin,
    required this.onTap,
    this.onToggleStatus,
    this.onDelete,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Muhim':
        return const Color(0xFFEF4444);
      case 'Tadbir':
        return const Color(0xFF8B5CF6);
      case 'Oddiy':
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Muhim':
        return Icons.priority_high;
      case 'Tadbir':
        return Icons.event;
      case 'Oddiy':
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor(elon.category);
    final categoryIcon = _getCategoryIcon(elon.category);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image (if exists)
              if (elon.imageUrl != null)
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(20)),
                  child: Image.network(
                    elon.imageUrl!,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 180,
                        color: Colors.grey[200],
                        child: const Icon(Icons.image, size: 50),
                      );
                    },
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and Date
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                categoryColor,
                                categoryColor.withValues(alpha: 0.7),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                categoryIcon,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                elon.category,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('dd.MM.yyyy').format(elon.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Title
                    Text(
                      elon.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Content preview
                    Text(
                      elon.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Admin controls
                    if (isAdmin) ...[
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Active status
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: elon.isActive
                                  ? Colors.green.withValues(alpha: 0.1)
                                  : Colors.grey.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              elon.isActive ? 'Faol' : 'Nofaol',
                              style: TextStyle(
                                fontSize: 11,
                                color: elon.isActive ? Colors.green : Colors.grey,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Spacer(),
                          // Toggle button
                          IconButton(
                            onPressed: onToggleStatus,
                            icon: Icon(
                              elon.isActive
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              size: 20,
                            ),
                            tooltip: elon.isActive ? 'Yashirish' : 'Ko\'rsatish',
                          ),
                          // Delete button
                          IconButton(
                            onPressed: onDelete,
                            icon: const Icon(
                              Icons.delete_outline,
                              size: 20,
                              color: Colors.red,
                            ),
                            tooltip: 'O\'chirish',
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
