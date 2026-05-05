import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/repositories/ariza_repository.dart';
import '../../data/models/ariza_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class ArizaDetailPage extends ConsumerStatefulWidget {
  final String arizaId;

  const ArizaDetailPage({
    super.key,
    required this.arizaId,
  });

  @override
  ConsumerState<ArizaDetailPage> createState() => _ArizaDetailPageState();
}

class _ArizaDetailPageState extends ConsumerState<ArizaDetailPage> {
  late Future<ArizaModel> _arizaFuture;

  @override
  void initState() {
    super.initState();
    _loadAriza();
  }

  void _loadAriza() {
    final repository = ArizaRepository();
    _arizaFuture = repository.getArizaById(widget.arizaId);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'yuborildi':
        return Colors.blue;
      case 'ko\'rilmoqda':
        return Colors.orange;
      case 'bajarildi':
        return Colors.green;
      case 'rad_etildi':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final isAdmin = currentUser?.role == 'admin';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ariza Tafsilotlari'),
      ),
      body: FutureBuilder<ArizaModel>(
        future: _arizaFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _loadAriza();
                });
              },
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Ariza topilmadi'));
          }

          final ariza = snapshot.data!;
          final statusColor = _getStatusColor(ariza.status);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadAriza();
              });
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Card
                  Card(
                    color: statusColor.withOpacity(0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: statusColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Holati',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                                Text(
                                  ariza.statusText,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: statusColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Category & Date
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            icon: Icons.category,
                            label: 'Kategoriya',
                            value: ariza.category,
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Yuborilgan sana',
                            value: DateFormat('dd.MM.yyyy HH:mm').format(ariza.createdAt),
                          ),
                          if (ariza.completedAt != null) ...[
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.check_circle,
                              label: 'Bajarilgan sana',
                              value: DateFormat('dd.MM.yyyy HH:mm').format(ariza.completedAt!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // User Info (Admin only)
                  if (isAdmin) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Foydalanuvchi',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            _InfoRow(
                              icon: Icons.person,
                              label: 'F.I.O',
                              value: ariza.userFullName,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.phone,
                              label: 'Telefon',
                              value: ariza.userPhone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ariza matni',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            ariza.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Images
                  if (ariza.imageUrls.isNotEmpty) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Rasmlar',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 12),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: ariza.imageUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: ariza.imageUrls[index],
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                        child: CircularProgressIndicator(),
                                      ),
                                    ),
                                    errorWidget: (context, url, error) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.error),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Admin Response
                  if (ariza.adminResponse != null) ...[
                    Card(
                      color: Colors.green[50],
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.admin_panel_settings, color: Colors.green[700]),
                                const SizedBox(width: 8),
                                Text(
                                  'Admin javobi',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[700],
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ariza.adminResponse!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
