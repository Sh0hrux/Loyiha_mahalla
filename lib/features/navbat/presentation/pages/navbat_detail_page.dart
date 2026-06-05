import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/navbat_repository.dart';
import '../../data/models/navbat_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class NavbatDetailPage extends ConsumerStatefulWidget {
  final String navbatId;

  const NavbatDetailPage({
    super.key,
    required this.navbatId,
  });

  @override
  ConsumerState<NavbatDetailPage> createState() => _NavbatDetailPageState();
}

class _NavbatDetailPageState extends ConsumerState<NavbatDetailPage> {
  late Future<NavbatModel> _navbatFuture;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _loadNavbat();
  }

  void _loadNavbat() {
    final repository = NavbatRepository();
    _navbatFuture = repository.getNavbatById(widget.navbatId);
  }

  Future<void> _updateStatus(String status, String statusText) async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tasdiqlash'),
        content: Text('Navbat holatini "$statusText" ga o\'zgartirmoqchimisiz?'),
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

    setState(() => _isUpdating = true);

    try {
      final repository = NavbatRepository();
      await repository.updateNavbatStatus(
        navbatId: widget.navbatId,
        status: status,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Navbat holati "$statusText" ga o\'zgartirildi'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _loadNavbat();
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
      case 'kutilmoqda':
        return Colors.blue;
      case 'tasdiqlandi':
        return Colors.green;
      case 'bekor_qilindi':
        return Colors.red;
      case 'tugallandi':
        return Colors.grey;
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
        title: const Text('Navbat Tafsilotlari'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF10B981), Color(0xFF059669)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<NavbatModel>(
        future: _navbatFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingWidget();
          }

          if (snapshot.hasError) {
            return CustomErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _loadNavbat();
                });
              },
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Navbat topilmadi'));
          }

          final navbat = snapshot.data!;
          final statusColor = _getStatusColor(navbat.status);

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _loadNavbat();
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
                                  navbat.statusText,
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

                  // Date & Time
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _InfoRow(
                            icon: Icons.calendar_today,
                            label: 'Sana',
                            value: DateFormat('dd MMMM yyyy, EEEE', 'uz').format(navbat.appointmentDate),
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.access_time,
                            label: 'Vaqt',
                            value: navbat.timeSlot,
                          ),
                          const Divider(height: 24),
                          _InfoRow(
                            icon: Icons.event_note,
                            label: 'Yaratilgan sana',
                            value: DateFormat('dd.MM.yyyy HH:mm').format(navbat.createdAt),
                          ),
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
                              value: navbat.userFullName,
                            ),
                            const Divider(height: 24),
                            _InfoRow(
                              icon: Icons.phone,
                              label: 'Telefon',
                              value: navbat.userPhone,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],

                  // Purpose
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Maqsad',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            navbat.purpose,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Admin Actions
                  if (isAdmin && navbat.status != 'tugallandi' && navbat.status != 'bekor_qilindi') ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Navbat holatini o\'zgartirish',
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            if (navbat.status == 'kutilmoqda') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isUpdating
                                          ? null
                                          : () => _updateStatus('tasdiqlandi', 'Tasdiqlandi'),
                                      icon: const Icon(Icons.check_circle),
                                      label: const Text('Tasdiqlash'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            if (navbat.status == 'tasdiqlandi') ...[
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _isUpdating
                                          ? null
                                          : () => _updateStatus('tugallandi', 'Tugallandi'),
                                      icon: const Icon(Icons.done_all),
                                      label: const Text('Tugallandi'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.grey[700],
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: _isUpdating
                                        ? null
                                        : () => _updateStatus('bekor_qilindi', 'Bekor qilindi'),
                                    icon: const Icon(Icons.cancel),
                                    label: const Text('Bekor qilish'),
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
