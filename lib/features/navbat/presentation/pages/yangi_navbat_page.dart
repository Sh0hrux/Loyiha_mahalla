import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/navbat_provider.dart';
import '../../data/models/navbat_model.dart';
import '../../../../app/theme.dart';

class YangiNavbatPage extends ConsumerStatefulWidget {
  const YangiNavbatPage({super.key});

  @override
  ConsumerState<YangiNavbatPage> createState() => _YangiNavbatPageState();
}

class _YangiNavbatPageState extends ConsumerState<YangiNavbatPage> {
  final _formKey = GlobalKey<FormState>();
  final _purposeController = TextEditingController();

  DateTime? _selectedDate;
  String? _selectedTimeSlot;
  bool _isSubmitting = false;

  // Available time slots
  final List<String> _timeSlots = [
    '09:00-09:30',
    '09:30-10:00',
    '10:00-10:30',
    '10:30-11:00',
    '11:00-11:30',
    '11:30-12:00',
    '14:00-14:30',
    '14:30-15:00',
    '15:00-15:30',
    '15:30-16:00',
    '16:00-16:30',
    '16:30-17:00',
  ];

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedTimeSlot = null; // Reset time slot when date changes
      });
    }
  }

  Future<void> _submitNavbat() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sanani tanlang'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vaqtni tanlang'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Foydalanuvchi topilmadi'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Check if time slot is available
      final existingNavbatlar =
          await ref.read(navbatlarByDateProvider(_selectedDate!).future);

      final isSlotTaken = existingNavbatlar.any(
        (navbat) => navbat.timeSlot == _selectedTimeSlot,
      );

      if (isSlotTaken) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bu vaqt band qilingan. Boshqa vaqt tanlang.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
        return;
      }

      // Create navbat
      final navbat = NavbatModel(
        id: '',
        userId: currentUser.id,
        userFullName: currentUser.fullName,
        userPhone: currentUser.phoneNumber,
        purpose: _purposeController.text.trim(),
        appointmentDate: _selectedDate!,
        timeSlot: _selectedTimeSlot!,
        status: 'kutilmoqda',
        createdAt: DateTime.now(),
      );

      await ref.read(createNavbatProvider.notifier).createNavbat(navbat);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Navbat muvaffaqiyatli band qilindi'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // AppBar
            SliverAppBar(
              expandedHeight: 120,
              floating: false,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text(
                  'Navbat band qilish',
                  style: TextStyle(fontWeight: FontWeight.bold),
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

            // Form
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Info Card
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.accentColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.accentColor,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Navbat 1 kundan 30 kungacha band qilish mumkin',
                                style: TextStyle(
                                  color: AppTheme.accentColor,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Purpose Input
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: TextFormField(
                          controller: _purposeController,
                          maxLines: 3,
                          decoration: const InputDecoration(
                            labelText: 'Tashrif maqsadi',
                            hintText: 'Nima uchun kelmoqchisiz?',
                            alignLabelWithHint: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(20),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tashrif maqsadini kiriting';
                            }
                            if (value.length < 5) {
                              return 'Kamida 5 ta belgi kiriting';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Date Selector
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 8,
                          ),
                          leading: Icon(
                            Icons.calendar_today_outlined,
                            color: AppTheme.primaryColor,
                          ),
                          title: Text(
                            _selectedDate == null
                                ? 'Sanani tanlang'
                                : DateFormat('dd MMMM yyyy', 'uz')
                                    .format(_selectedDate!),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: _selectedDate == null
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: _selectedDate == null
                                  ? Colors.grey[600]
                                  : Colors.black87,
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: _isSubmitting ? null : _selectDate,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Time Slots
                      if (_selectedDate != null) ...[
                        Text(
                          'Vaqtni tanlang',
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        const SizedBox(height: 12),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 2,
                          ),
                          itemCount: _timeSlots.length,
                          itemBuilder: (context, index) {
                            final timeSlot = _timeSlots[index];
                            final isSelected = _selectedTimeSlot == timeSlot;

                            return InkWell(
                              onTap: _isSubmitting
                                  ? null
                                  : () {
                                      setState(() {
                                        _selectedTimeSlot = timeSlot;
                                      });
                                    },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: isSelected
                                      ? const LinearGradient(
                                          colors: [
                                            Color(0xFF10B981),
                                            Color(0xFF059669)
                                          ],
                                        )
                                      : null,
                                  color: isSelected ? null : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.transparent
                                        : Colors.grey[300]!,
                                    width: 1.5,
                                  ),
                                  boxShadow: isSelected
                                      ? [
                                          BoxShadow(
                                            color: const Color(0xFF10B981)
                                                .withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Center(
                                  child: Text(
                                    timeSlot,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Submit Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF10B981), Color(0xFF059669)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF10B981).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: _isSubmitting ? null : _submitNavbat,
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: _isSubmitting
                                  ? const SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Band qilish',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
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
