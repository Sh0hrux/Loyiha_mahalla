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
                  return const SliverFillRemaining(
                    child: EmptyStateWidget(
                      icon: Icons.people_outline,
                      title: 'Xodimlar yo\'q',
                      subtitle: 'Hozircha xodimlar ro\'yxati bo\'sh',
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
                          onCallPhone: () => _launchPhone(xodim.phone),
                          onSendEmail: xodim.email != null
                              ? () => _launchEmail(xodim.email!)
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
    );
  }
}

class _XodimCard extends StatelessWidget {
  final dynamic xodim;
  final VoidCallback onCallPhone;
  final VoidCallback? onSendEmail;

  const _XodimCard({
    required this.xodim,
    required this.onCallPhone,
    this.onSendEmail,
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
      child: Padding(
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
                      backgroundColor: AppTheme.accentColor.withOpacity(0.1),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
