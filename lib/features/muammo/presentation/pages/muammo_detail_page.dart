import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../data/repositories/muammo_repository.dart';
import '../../data/models/muammo_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class MuammoDetailPage extends ConsumerStatefulWidget {
  final String muammoId;

  const MuammoDetailPage({
    super.key,
    required this.muammoId,
  });

  @override
  ConsumerState<MuammoDetailPage> createState() => _MuammoDetailPageState();
}

class _MuammoDetailPageState extends ConsumerState<MuammoDetailPage> {
  late Future<MuammoModel> _muammoFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadMuammo();
  }

  void _loadMuammo() {
    final repository = MuammoRepository();
    _muammoFuture = repository.getMuammoById(widget.muammoId);
  }

  Future<void> _updateStatus(String status, String statusText) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    String? adminResponse;

    // If status is resolved or rejected, ask for admin response
    if (status == 'hal_qilindi' || status == 'rad_etildi') {
      adminResponse = await showDialog<String>(
        context: context,
        builder: (context) {
          final controller = TextEditingController();
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status == 'hal_qilindi' ? 'Hal qilish' : 'Rad etish',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text('Muammo holatini "$statusText" ga o\'zgartirmoqchimisiz?'),
                    const SizedBox(height: 16),
                    TextField(
                      controller: controller,
                      decoration: const InputDecoration(
                        labelText: 'Admin javobi',
                        hintText: 'Javob yozing...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      autofocus: true,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Bekor qilish'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, controller.text),
                          child: const Text('Tasdiqlash'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      if (adminResponse == null || adminResponse.isEmpty) return;
    } else {
      // For "ko'rilmoqda" status, just confirm
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tasdiqlash'),
          content: Text('Muammo holatini "$statusText" ga o\'zgartirmoqchimisiz?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Bekor qilish'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tasdiqlash'),
            ),
          ],
        ),
      );

      if (confirmed != true) return;
    }

    setState(() => _isUpdating = true);

    try {
      final repository = MuammoRepository();
      await repository.updateMuammoStatus(
        muammoId: widget.muammoId,
        status: status,
        adminResponse: adminResponse,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Muammo holati "$statusText" ga o\'zgartirildi'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _loadMuammo();
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUpdating = false);
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'yuborildi':
        return Colors.blue;
      case 'ko\'rilmoqda':
        return Colors.orange;
      case 'hal_qilindi':
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
        title: const Text('Muammo Tafsilotlari'),
      ),
      body: FutureBuilder<MuammoModel>(
        future: _muammoFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _loadMuammo();
                });
              },
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Muammo topilmadi'));
          }

          final muammo = snapshot.data!;
          final statusColor = _getStatusColor(muammo.status);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadMuammo();
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
                    color: statusColor.withValues(alpha: 0.1),
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
                                  muammo.statusText,
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
                  const SizedBox(height: 12),

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
                            value: muammo.category,
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Yuborilgan sana',
                            value: DateFormat('dd.MM.yyyy HH:mm').format(muammo.createdAt),
                          ),
                          if (muammo.updatedAt != null) ...[
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.check_circle,
                              label: 'Yangilangan sana',
                              value: DateFormat('dd.MM.yyyy HH:mm').format(muammo.updatedAt!),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

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
                              value: muammo.userFullName,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.phone,
                              label: 'Telefon',
                              value: muammo.userPhone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Location
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manzil',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 20, color: Colors.red),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  muammo.location,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Description
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Muammo tavsifi',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            muammo.description,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Images
                  if (muammo.imageUrls.isNotEmpty) ...[
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
                              itemCount: muammo.imageUrls.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: muammo.imageUrls[index],
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
                    const SizedBox(height: 12),
                  ],

                  // Admin Response
                  if (muammo.adminResponse != null) ...[
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
                              muammo.adminResponse!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Admin Actions
                  if (isAdmin && muammo.status != 'hal_qilindi' && muammo.status != 'rad_etildi') ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Muammo holatini o\'zgartirish',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating
                                        ? null
                                        : () => _updateStatus('ko\'rilmoqda', 'Ko\'rilmoqda'),
                                    icon: const Icon(Icons.hourglass_empty),
                                    label: const Text('Ko\'rilmoqda'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating
                                        ? null
                                        : () => _updateStatus('hal_qilindi', 'Hal qilindi'),
                                    icon: const Icon(Icons.check_circle),
                                    label: const Text('Hal qilindi'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating
                                        ? null
                                        : () => _updateStatus('rad_etildi', 'Rad etildi'),
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Rad etish'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (_isUpdating) ...[
                              const SizedBox(height: 16),
                              const Center(
                                child: CircularProgressIndicator(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
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
