import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/eslatma_model.dart';
import '../providers/eslatma_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../app/theme.dart';

class EslatmaDetailPage extends ConsumerStatefulWidget {
  final String eslatmaId;

  const EslatmaDetailPage({
    super.key,
    required this.eslatmaId,
  });

  @override
  ConsumerState<EslatmaDetailPage> createState() => _EslatmaDetailPageState();
}

class _EslatmaDetailPageState extends ConsumerState<EslatmaDetailPage> {
  @override
  void initState() {
    super.initState();
    // Auto mark as read when opened
    Future.microtask(() {
      ref.read(eslatmaNotifierProvider.notifier).markAsRead(widget.eslatmaId);
    });
  }

  Color _getTypeColor(EslatmaModel eslatma) {
    final colorHex = eslatma.typeColor.replaceAll('#', '');
    return Color(int.parse('FF$colorHex', radix: 16));
  }

  Future<void> _deleteEslatma(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('O\'chirish'),
        content: const Text('Bu eslatmani o\'chirishni xohlaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Yo\'q'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Ha'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(eslatmaNotifierProvider.notifier).deleteEslatma(widget.eslatmaId);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eslatma o\'chirildi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _shareEslatma(EslatmaModel eslatma) {
    final text = '''
${eslatma.title}

${eslatma.message}

Turi: ${eslatma.type.label}
Yuborgan: ${eslatma.adminName}
Sana: ${DateFormat('dd.MM.yyyy HH:mm').format(eslatma.createdAt)}
''';

    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Eslatma matn buferiga ko\'chirildi'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eslatmaAsync = ref.watch(eslatmaByIdProvider(widget.eslatmaId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eslatma'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          eslatmaAsync.when(
            data: (eslatma) => eslatma != null
                ? PopupMenuButton(
                    icon: const Icon(Icons.more_vert),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        onTap: () => _shareEslatma(eslatma),
                        child: const Row(
                          children: [
                            Icon(Icons.share),
                            SizedBox(width: 12),
                            Text('Ulashish'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        onTap: () => _deleteEslatma(context),
                        child: const Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red),
                            SizedBox(width: 12),
                            Text('O\'chirish', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: eslatmaAsync.when(
        data: (eslatma) {
          if (eslatma == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Eslatma topilmadi',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          final typeColor = _getTypeColor(eslatma);
          final dateFormat = DateFormat('dd MMMM yyyy, HH:mm', 'uz');

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header banner
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        typeColor,
                        typeColor.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              eslatma.type.emoji,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              eslatma.type.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Title
                      Text(
                        eslatma.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),

                      // Urgent indicator
                      if (eslatma.isUrgent) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.errorColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.priority_high,
                                size: 16,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'SHOSHILINCH ESLATMA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Message
                      Text(
                        eslatma.message,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Divider
                      const Divider(),
                      const SizedBox(height: 16),

                      // Info cards
                      _InfoCard(
                        icon: Icons.person,
                        label: 'Yuboruvchi',
                        value: eslatma.adminName,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _InfoCard(
                        icon: Icons.access_time,
                        label: 'Sana va vaqt',
                        value: dateFormat.format(eslatma.createdAt),
                        color: Colors.green,
                      ),
                      if (eslatma.expiresAt != null) ...[
                        const SizedBox(height: 12),
                        _InfoCard(
                          icon: Icons.event,
                          label: 'Amal qilish muddati',
                          value: dateFormat.format(eslatma.expiresAt!),
                          color: eslatma.isExpired
                              ? AppTheme.errorColor
                              : Colors.orange,
                          isExpired: eslatma.isExpired,
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Status badges
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          if (eslatma.isNew)
                            Chip(
                              avatar: const Icon(
                                Icons.fiber_new,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Yangi eslatma',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.green,
                            ),
                          if (eslatma.isRead)
                            Chip(
                              avatar: Icon(
                                Icons.check_circle,
                                size: 18,
                                color: Colors.grey.shade600,
                              ),
                              label: Text(
                                'O\'qilgan',
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                              backgroundColor: Colors.grey.shade200,
                            ),
                          if (eslatma.isExpired)
                            Chip(
                              avatar: const Icon(
                                Icons.event_busy,
                                size: 18,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Muddati o\'tgan',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: AppTheme.errorColor,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Xatolik: $error'),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isExpired;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.isExpired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isExpired ? AppTheme.errorColor : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          if (isExpired)
            const Icon(
              Icons.warning,
              color: AppTheme.errorColor,
              size: 20,
            ),
        ],
      ),
    );
  }
}
