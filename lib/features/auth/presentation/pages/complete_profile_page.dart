import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';

class CompleteProfilePage extends ConsumerStatefulWidget {
  const CompleteProfilePage({super.key});

  @override
  ConsumerState<CompleteProfilePage> createState() =>
      _CompleteProfilePageState();
}

class _CompleteProfilePageState extends ConsumerState<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _passportSeriesController = TextEditingController();
  final _passportNumberController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        await ref.read(currentUserProvider.notifier).updateProfile({
          'fullName': _fullNameController.text.trim(),
          'address': _addressController.text.trim(),
          'passportSeries': _passportSeriesController.text.trim().toUpperCase(),
          'passportNumber': _passportNumberController.text.trim(),
        });

        if (mounted) {
          context.go('/home');
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
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilni to\'ldirish'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Info Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue[700],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Iltimos, profilingizni to\'ldiring',
                          style: TextStyle(
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Full Name
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'F.I.O *',
                    hintText: 'Familiya Ism Otasining ismi',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'F.I.O ni kiriting';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Manzil *',
                    hintText: 'Toshkent shahar, Yunusobod tumani',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Manzilni kiriting';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Passport Series
                TextFormField(
                  controller: _passportSeriesController,
                  decoration: const InputDecoration(
                    labelText: 'Passport seriyasi *',
                    hintText: 'AA',
                    prefixIcon: Icon(Icons.badge),
                  ),
                  textCapitalization: TextCapitalization.characters,
                  maxLength: 2,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Passport seriyasini kiriting';
                    }
                    if (value.length != 2) {
                      return 'Passport seriyasi 2 ta harfdan iborat';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Passport Number
                TextFormField(
                  controller: _passportNumberController,
                  decoration: const InputDecoration(
                    labelText: 'Passport raqami *',
                    hintText: '1234567',
                    prefixIcon: Icon(Icons.numbers),
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 7,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Passport raqamini kiriting';
                    }
                    if (value.length != 7) {
                      return 'Passport raqami 7 ta raqamdan iborat';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Save Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Saqlash'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
