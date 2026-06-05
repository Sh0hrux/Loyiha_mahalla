import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/eslatma_model.dart';
import '../providers/eslatma_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_state_widget.dart';
import '../../../../app/theme.dart';

class EslatmalarPage extends ConsumerStatefulWidget {
  const EslatmalarPage({super.key});

  @override
  ConsumerState<EslatmalarPage> createState() => _EslatmalarPageState();
}

class _EslatmalarPageState extends ConsumerState<EslatmalarPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _markAllAsRead() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tasdiqlash'),
        content: const Text('Barcha eslatmalarni o\'qilgan deb belgilaysizmi?'),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Yo\'q'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            child: const Text('Ha'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final notifier = ref.read(eslatmaNotifierProvider.notifier);
      final userId = ref.read(userEslatmalarProvider).value?.first.userId;
      if (userId != null) {
        await notifier.markAllAsRead(userId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Barcha eslatmalar o\'qilgan deb belgilandi'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final eslatmalarAsync = ref.watch(userEslatmalarProvider);
    final unreadCountAsync = ref.watch(unreadEslatmalarCountProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Eslatmalar'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          // Unread badge
          unreadCountAsync.when(
            data: (count) => count > 0
                ? Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '$count yangi',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          // Mark all as read
          IconButton(
            icon: const Icon(Icons.done_all),
            onPressed: _markAllAsRead,
            tooltip: 'Barchasini o\'qilgan',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'O\'qilmagan'),
            Tab(text: 'Barchasi'),
          ],
        ),
      ),
      body: eslatmalarAsync.when(
        data: (eslatmalar) {
          if (eslatmalar.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.notifications_none,
              title: 'Eslatmalar yo\'q',
              message: 'Sizga hali hech qanday eslatma yuborilmagan',
            );
          }

          return TabBarView(
            controller: _tabController,
            children: [
              // O'qilmagan
              _buildEslatmaList(
                eslatmalar.where((e) => !e.isRead).toList(),
              ),
              // Barchasi
              _buildEslatmaList(eslatmalar),
            ],
          );
        },
        loading: () => const LoadingWidget(),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Xatolik: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEslatmaList(List<EslatmaModel> eslatmalar) {
    if (eslatmalar.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.check_circle_outline,
        title: 'Hamma o\'qilgan!',
        message: 'Sizda o\'qilmagan eslatmalar yo\'q',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(userEslatmalarProvider);
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: eslatmalar.length,
        itemBuilder: (context, index) {
          final eslatma = eslatmalar[index];
          return _EslatmaCard(eslatma: eslatma);
        },
      ),
    );
  }
}

class _EslatmaCard extends ConsumerWidget {
  final EslatmaModel eslatma;

  const _EslatmaCard({required this.eslatma});

  Color _getTypeColor() {
    final colorHex = eslatma.typeColor.replaceAll('#', '');
    return Color(int.parse('FF$colorHex', radix: 16));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dateFormat = DateFormat('dd.MM.yyyy HH:mm');

    return Dismissible(
      key: Key(eslatma.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('O\'chirish'),
            content: const Text('Eslatmani o\'chirishni xohlaysizmi?'),
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
      },
      onDismissed: (direction) {
        ref.read(eslatmaNotifierProvider.notifier).deleteEslatma(eslatma.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Eslatma o\'chirildi'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        elevation: eslatma.isRead ? 1 : 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: eslatma.isRead
                ? Colors.grey.shade300
                : _getTypeColor().withOpacity(0.5),
            width: eslatma.isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (!eslatma.isRead) {
              ref.read(eslatmaNotifierProvider.notifier).markAsRead(eslatma.id);
            }
            context.push('/eslatma-detail/${eslatma.id}');
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    // Type icon
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        eslatma.type.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Type and urgent
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                eslatma.type.label,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _getTypeColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (eslatma.isUrgent) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.errorColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'SHOSHILINCH',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            dateFormat.format(eslatma.createdAt),
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Unread indicator
                    if (!eslatma.isRead)
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),

                // Title
                Text(
                  eslatma.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: eslatma.isRead ? Colors.grey.shade700 : Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),

                // Message preview
                Text(
                  eslatma.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // Footer
                if (eslatma.expiresAt != null || eslatma.isNew) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (eslatma.isNew)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'YANGI',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (eslatma.isNew && eslatma.expiresAt != null)
                        const SizedBox(width: 8),
                      if (eslatma.expiresAt != null)
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Muddati: ${dateFormat.format(eslatma.expiresAt!)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
