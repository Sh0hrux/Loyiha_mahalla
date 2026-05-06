import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/xodim_model.dart';
import '../providers/xodim_provider.dart';
import '../../../../app/theme.dart';

class YangiXodimPage extends ConsumerStatefulWidget {
  final XodimModel? xodim; // For editing

  const YangiXodimPage({super.key, this.xodim});

  @override
  ConsumerState<YangiXodimPage> createState() => _YangiXodimPageState();
}

class _YangiXodimPageState extends ConsumerState<YangiXodimPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _positionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _photoUrlController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _orderController = TextEditingController();
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.xodim != null) {
      _fullNameController.text = widget.xodim!.fullName;
      _positionController.text = widget.xodim!.position;
      _phoneController.text = widget.xodim!.phone;
      _emailController.text = widget.xodim!.email ?? '';
      _photoUrlController.text = widget.xodim!.photoUrl ?? '';
      _descriptionController.text = widget.xodim!.description ?? '';
      _orderController.text = widget.xodim!.order.toString();
      _isActive = widget.xodim!.isActive;
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _positionController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _photoUrlController.dispose();
    _descriptionController.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _saveXodim() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final xodim = XodimModel(
        id: widget.xodim?.id ?? '',
        fullName: _fullNameController.text.trim(),
        position: _positionController.text.trim(),
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim().isEmpty
            ? null
            : _emailController.text.trim(),
        photoUrl: _photoUrlController.text.trim().isEmpty
            ? null
            : _photoUrlController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        order: int.tryParse(_orderController.text.trim()) ?? 0,
        isActive: _isActive,
        createdAt: widget.xodim?.createdAt ?? DateTime.now(),
      );

      if (widget.xodim != null) {
        // Update
        await ref
            .read(updateXodimProvider.notifier)
            .updateXodim(widget.xodim!.id, xodim);
      } else {
        // Create
        await ref.read(createXodimProvider.notifier).createXodim(xodim);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.xodim != null
                ? 'Xodim muvaffaqiyatli yangilandi'
                : 'Xodim muvaffaqiyatli qo\'shildi'),
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
        setState(() => _isLoading = false);
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
                title: Text(
                  widget.xodim != null ? 'Xodimni tahrirlash' : 'Yangi xodim',
                  style: const TextStyle(fontWeight: FontWeight.bold),
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

            // Form
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Full Name
                      _buildTextField(
                        controller: _fullNameController,
                        label: 'To\'liq ism',
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Iltimos, to\'liq ismni kiriting';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Position
                      _buildTextField(
                        controller: _positionController,
                        label: 'Lavozim',
                        icon: Icons.work_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Iltimos, lavozimni kiriting';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Phone
                      _buildTextField(
                        controller: _phoneController,
                        label: 'Telefon raqam',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Iltimos, telefon raqamni kiriting';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email (optional)
                      _buildTextField(
                        controller: _emailController,
                        label: 'Email (ixtiyoriy)',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Photo URL (optional)
                      _buildTextField(
                        controller: _photoUrlController,
                        label: 'Rasm URL (ixtiyoriy)',
                        icon: Icons.image_outlined,
                        keyboardType: TextInputType.url,
                      ),
                      const SizedBox(height: 16),

                      // Description (optional)
                      _buildTextField(
                        controller: _descriptionController,
                        label: 'Tavsif (ixtiyoriy)',
                        icon: Icons.description_outlined,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),

                      // Order
                      _buildTextField(
                        controller: _orderController,
                        label: 'Tartib raqami',
                        icon: Icons.format_list_numbered,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Iltimos, tartib raqamini kiriting';
                          }
                          if (int.tryParse(value.trim()) == null) {
                            return 'Faqat raqam kiriting';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Active Switch
                      Container(
                        padding: const EdgeInsets.all(16),
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
                        child: Row(
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              color: AppTheme.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Faol',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            Switch(
                              value: _isActive,
                              onChanged: (value) {
                                setState(() => _isActive = value);
                              },
                              activeColor: AppTheme.successColor,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Save Button
                      Container(
                        height: 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveXodim,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  widget.xodim != null
                                      ? 'Saqlash'
                                      : 'Qo\'shish',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
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
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 22,
          ),
          filled: true,
          fillColor: const Color(0xFFF9FAFB),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Color(0xFFE5E7EB),
              width: 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppTheme.primaryColor,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
