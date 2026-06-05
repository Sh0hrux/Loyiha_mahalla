import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/eslatma_model.dart';
import '../providers/eslatma_provider.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../../features/users/data/repositories/users_repository.dart';
import '../../../../features/auth/data/models/user_model.dart';
import '../../../../app/theme.dart';

// Users repository provider
final usersRepositoryProvider = Provider<UsersRepository>((ref) {
  return UsersRepository();
});

// All users stream provider
final allUsersProvider = StreamProvider.autoDispose<List<UserModel>>((ref) {
  final repository = ref.watch(usersRepositoryProvider);
  return repository.getAllUsers();
});

class YangiEslatmaPage extends ConsumerStatefulWidget {
  const YangiEslatmaPage({super.key});

  @override
  ConsumerState<YangiEslatmaPage> createState() => _YangiEslatmaPageState();
}

class _YangiEslatmaPageState extends ConsumerState<YangiEslatmaPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _searchController = TextEditingController();

  EslatmaType _selectedType = EslatmaType.umumiy;
  DateTime? _expiresAt;
  bool _isUrgent = false;
  bool _sendToAll = false;
  final List<String> _selectedUserIds = [];
  String _searchQuery = '';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  /// Eslatma turi rangi
  Color _typeColor(EslatmaType type) {
    switch (type) {
      case EslatmaType.soliq:
        return const Color(0xFF10B981); // Green
      case EslatmaType.kommunal:
        return const Color(0xFF3B82F6); // Blue
      case EslatmaType.tadbir:
        return const Color(0xFFF59E0B); // Amber
      case EslatmaType.yigilish:
        return const Color(0xFF8B5CF6); // Violet
      case EslatmaType.xizmat:
        return const Color(0xFFEC4899); // Pink
      case EslatmaType.muhim:
        return const Color(0xFFEF4444); // Red
      case EslatmaType.umumiy:
        return const Color(0xFF6366F1); // Indigo
    }
  }

  Future<void> _submitEslatma() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_sendToAll && _selectedUserIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kamida bitta foydalanuvchi tanlang'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    // Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tasdiqlash'),
        content: Text(
          _sendToAll
              ? 'Hamma foydalanuvchilarga eslatma yuborilsinmi?'
              : '${_selectedUserIds.length} ta foydalanuvchiga eslatma yuborilsinmi?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(false),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () => context.pop(true),
            child: const Text('Ha, yuborish'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final notifier = ref.read(eslatmaNotifierProvider.notifier);

      List<String> targetUserIds = _selectedUserIds;

      // If send to all, get all user IDs
      if (_sendToAll) {
        final allUsersAsync = ref.read(allUsersProvider);
        if (allUsersAsync.hasValue) {
          targetUserIds = allUsersAsync.value!.map((u) => u.id).toList();
        }
      }

      final success = await notifier.createBulkEslatma(
        userIds: targetUserIds,
        adminId: currentUser.id,
        adminName: currentUser.fullName,
        type: _selectedType,
        title: _titleController.text.trim(),
        message: _messageController.text.trim(),
        expiresAt: _expiresAt,
        isUrgent: _isUrgent,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '✅ ${targetUserIds.length} ta eslatma yuborildi!',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allUsersAsync = ref.watch(allUsersProvider);
    final eslatmaState = ref.watch(eslatmaNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yangi Eslatma'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Info Card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Foydalanuvchilarga eslatma yuboring',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Send to all toggle
            SwitchListTile(
              title: const Text(
                'Hamma foydalanuvchilarga yuborish',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: allUsersAsync.when(
                data: (users) => Text('${users.length} ta foydalanuvchi'),
                loading: () => const Text('Yuklanmoqda...'),
                error: (_, __) => const Text('Xatolik'),
              ),
              value: _sendToAll,
              onChanged: (value) {
                setState(() {
                  _sendToAll = value;
                  if (value) _selectedUserIds.clear();
                });
              },
              activeThumbColor: AppTheme.primaryColor,
            ),
            const Divider(),

            // User selection (if not send to all)
            if (!_sendToAll) ...[
              const Text(
                'Foydalanuvchilarni tanlang',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Search
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Qidirish...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
              const SizedBox(height: 12),

              // Selected count
              if (_selectedUserIds.isNotEmpty)
                Chip(
                  label: Text('${_selectedUserIds.length} ta tanlandi'),
                  onDeleted: () {
                    setState(() => _selectedUserIds.clear());
                  },
                ),
              const SizedBox(height: 8),

              // Users list
              allUsersAsync.when(
                data: (users) {
                  final filteredUsers = users.where((user) {
                    if (_searchQuery.isEmpty) return true;
                    return user.fullName.toLowerCase().contains(_searchQuery) ||
                        user.phoneNumber.toLowerCase().contains(_searchQuery);
                  }).toList();

                  if (filteredUsers.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Text('Foydalanuvchi topilmadi'),
                      ),
                    );
                  }

                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = filteredUsers[index];
                        final isSelected = _selectedUserIds.contains(user.id);

                        return CheckboxListTile(
                          title: Text(user.fullName),
                          subtitle: Text(user.phoneNumber.isNotEmpty
                              ? user.phoneNumber
                              : 'Telefon yo\'q'),
                          secondary: CircleAvatar(
                            child: Text(
                              user.fullName[0].toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                _selectedUserIds.add(user.id);
                              } else {
                                _selectedUserIds.remove(user.id);
                              }
                            });
                          },
                          activeColor: AppTheme.primaryColor,
                        );
                      },
                    ),
                  );
                },
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (error, _) => Center(
                  child: Text('Xatolik: $error'),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Type selector
            Row(
              children: [
                const Icon(Icons.category_outlined,
                    size: 20, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Eslatma turi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _typeColor(_selectedType).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_selectedType.emoji} ${_selectedType.label}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: _typeColor(_selectedType),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.7,
              children: EslatmaType.values.map((type) {
                final color = _typeColor(type);
                final isSelected = _selectedType == type;
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? color.withValues(alpha: 0.12)
                          : Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? color : Colors.grey.shade300,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: color.withValues(alpha: 0.25),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            type.emoji,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            type.label,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.1,
                              color: isSelected ? color : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(Icons.check_circle, color: color, size: 18),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Sarlavha',
                hintText: 'Eslatma sarlavhasi',
                prefixIcon: const Icon(Icons.title),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              maxLength: 100,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Sarlavha kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Message
            TextFormField(
              controller: _messageController,
              decoration: InputDecoration(
                labelText: 'Xabar',
                hintText: 'Eslatma matni',
                prefixIcon: const Icon(Icons.message),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 500,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Xabar kiriting';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Expiration date
            ListTile(
              title: const Text('Amal qilish muddati (ixtiyoriy)'),
              subtitle: _expiresAt != null
                  ? Text(
                      '${_expiresAt!.day}.${_expiresAt!.month}.${_expiresAt!.year}',
                    )
                  : const Text('Muddatsiz'),
              leading: const Icon(Icons.calendar_today),
              trailing: _expiresAt != null
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        setState(() => _expiresAt = null);
                      },
                    )
                  : null,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now().add(const Duration(days: 7)),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (date != null) {
                  setState(() => _expiresAt = date);
                }
              },
            ),
            const Divider(),

            // Urgent toggle
            SwitchListTile(
              title: const Text('Shoshilinch eslatma'),
              subtitle: const Text('Muhim va tezkor xabar'),
              secondary: Icon(
                Icons.priority_high,
                color: _isUrgent ? AppTheme.errorColor : Colors.grey,
              ),
              value: _isUrgent,
              onChanged: (value) {
                setState(() => _isUrgent = value);
              },
              activeThumbColor: AppTheme.errorColor,
            ),
            const SizedBox(height: 24),

            // Submit button
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: eslatmaState.isLoading ? null : _submitEslatma,
                icon: eslatmaState.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  eslatmaState.isLoading ? 'Yuborilmoqda...' : 'Yuborish',
                  style: const TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
