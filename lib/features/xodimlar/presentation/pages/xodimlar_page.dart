import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/xodim_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import '../../../../app/theme.dart';

class XodimlarPage extends ConsumerWidget {
  const XodimlarPage({super.key});

  Future<void> _launchPhone(String phone) async {
    final Uri uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(scheme: 'mailto', path: email);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isAdmin = currentUser?.role == 'admin';
    
    final xodimlarAsync = isAdmin
        ? ref.watch(allXodimlarProvider)
        : ref.watch(activeXodimlarProvider);

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
        child: CustomScrollView(
          slivers: [
            // AppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Xodimlar',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
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
            xodimlarAsync.when(
              data: (xodimlar) {
                if (xodimlar.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.people_outline,
                      title: 'Xodimlar yo\'q',
                      subtitle: isAdmin
                          ? 'Yangi xodim qo\'shish uchun + tugmasini bosing'
                          : 'Hozircha xodimlar ro\'yxati bo\'sh',
                      onActionPressed:
                          isAdmin ? () => context.push('/yangi-xodim') : null,
                      actionLabel: isAdmin ? 'Xodim qo\'shish' : null,
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final xodim = xodimlar[index];
                        return _XodimCard(
                          xodim: xodim,
                          isAdmin: isAdmin,
                          onCallPhone: () => _launchPhone(xodim.phone),
                          onSendEmail: xodim.email != null
                              ? () => _launchEmail(xodim.email!)
                              : null,
                          onEdit: isAdmin
                              ? () => context.push('/yangi-xodim',
                                  extra: xodim)
                              : null,
                          onDelete: isAdmin
                              ? () => _deleteXodim(context, ref, xodim)
                              : null,
                        );
                      },
                      childCount: xodimlar.length,
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
                        isAdmin ? allXodimlarProvider : activeXodimlarProvider);
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
                  colors: [Color(0xFF3B82F6), Color(0xFF2563EB)],
                ),
                borderRadius: BorderRadius.all(Radius.circular(16)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x4D3B82F6),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: () => context.push('/yangi-xodim'),
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(Icons.add),
                label: const Text('Xodim qo\'shish'),
              ),
            )
          : null,
    );
  }

  Future<void> _deleteXodim(
      BuildContext context, WidgetRef ref, dynamic xodim) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('O\'chirish'),
        content: Text(
          '${xodim.fullName} ni o\'chirmoqchimisiz?',
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Yo\'q'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Ha, o\'chirish'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(deleteXodimProvider.notifier).deleteXodim(xodim.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Xodim muvaffaqiyatli o\'chirildi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Xatolik: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }
}

class _XodimCard extends StatelessWidget {
  final dynamic xodim;
  final bool isAdmin;
  final VoidCallback onCallPhone;
  final VoidCallback? onSendEmail;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _XodimCard({
    required this.xodim,
    required this.isAdmin,
    required this.onCallPhone,
    this.onSendEmail,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Photo
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: xodim.photoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.network(
                            xodim.photoUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                size: 40,
                                color: Colors.white,
                              );
                            },
                          ),
                        )
                      : const Icon(
                          Icons.person,
                          size: 40,
                          color: Colors.white,
                        ),
                ),
                const SizedBox(width: 16),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        xodim.fullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          xodim.position,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.phone,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            xodim.phone,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                            ),
                          ),
                        ],
                      ),
                      if (xodim.email != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.email,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                xodim.email!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[700],
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isAdmin && !xodim.isActive) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Faol emas',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Actions
                Column(
                  children: [
                    IconButton(
                      onPressed: onCallPhone,
                      icon: const Icon(Icons.phone),
                      color: AppTheme.successColor,
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.successColor.withOpacity(0.1),
                      ),
                    ),
                    if (onSendEmail != null)
                      IconButton(
                        onPressed: onSendEmail,
                        icon: const Icon(Icons.email),
                        color: AppTheme.accentColor,
                        style: IconButton.styleFrom(
                          backgroundColor:
                              AppTheme.accentColor.withOpacity(0.1),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Admin Actions
          if (isAdmin && (onEdit != null || onDelete != null)) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  if (onEdit != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Tahrirlash'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(color: AppTheme.primaryColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: 12),
                  if (onDelete != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline, size: 18),
                        label: const Text('O\'chirish'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
