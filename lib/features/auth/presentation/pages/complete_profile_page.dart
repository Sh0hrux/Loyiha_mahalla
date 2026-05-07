import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/mahalla_data.dart';
import '../../../../core/services/mahalla_setup_service.dart';
import '../../../../app/theme.dart';

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

  String? _selectedRegion;
  String? _selectedDistrict;
  String? _selectedMahallaId;
  String? _selectedMahallaName;

  bool _isLoading = false;
  bool _isLoadingMahallas = false;
  List<Map<String, String>> _availableMahallas = [];

  @override
  void dispose() {
    _fullNameController.dispose();
    _addressController.dispose();
    _passportSeriesController.dispose();
    _passportNumberController.dispose();
    super.dispose();
  }

  Future<void> _loadMahallas(String district) async {
    if (!MahallaData.hasMahallas(district)) {
      setState(() {
        _availableMahallas = [];
        _selectedMahallaId = null;
        _selectedMahallaName = null;
      });
      return;
    }

    setState(() => _isLoadingMahallas = true);

    try {
      final mahallaService = MahallaSetupService();
      final mahallas = await mahallaService.getMahallasByDistrict(district);
      
      setState(() {
        _availableMahallas = mahallas
            .map((m) => {'id': m.id, 'name': m.name})
            .toList();
        _isLoadingMahallas = false;
      });
    } catch (e) {
      setState(() => _isLoadingMahallas = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mahallalarni yuklashda xatolik: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      // Check mahalla selection
      if (_selectedRegion == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Iltimos, viloyatni tanlang'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (_selectedDistrict == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Iltimos, tumanni tanlang'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      if (MahallaData.hasMahallas(_selectedDistrict!) && _selectedMahallaId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Iltimos, mahallani tanlang'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await ref.read(currentUserProvider.notifier).updateProfile({
          'fullName': _fullNameController.text.trim(),
          'address': _addressController.text.trim(),
          'passportSeries': _passportSeriesController.text.trim().toUpperCase(),
          'passportNumber': _passportNumberController.text.trim(),
          'mahallaId': _selectedMahallaId,
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.person_add_alt_1,
                          size: 60,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Profilni to\'ldirish',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ma\'lumotlaringizni kiriting',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Full Name
                  _buildTextField(
                    controller: _fullNameController,
                    label: 'F.I.O',
                    hint: 'Familiya Ism Otasining ismi',
                    icon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'F.I.O ni kiriting';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Region Dropdown
                  _buildDropdown(
                    label: 'Viloyat',
                    hint: 'Viloyatni tanlang',
                    icon: Icons.location_city_outlined,
                    value: _selectedRegion,
                    items: MahallaData.regions,
                    onChanged: (value) {
                      setState(() {
                        _selectedRegion = value;
                        _selectedDistrict = null;
                        _selectedMahallaId = null;
                        _selectedMahallaName = null;
                        _availableMahallas = [];
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // District Dropdown
                  if (_selectedRegion != null)
                    _buildDropdown(
                      label: 'Tuman',
                      hint: 'Tumanni tanlang',
                      icon: Icons.location_on_outlined,
                      value: _selectedDistrict,
                      items: MahallaData.getDistricts(_selectedRegion!),
                      onChanged: (value) {
                        setState(() {
                          _selectedDistrict = value;
                          _selectedMahallaId = null;
                          _selectedMahallaName = null;
                        });
                        if (value != null) {
                          _loadMahallas(value);
                        }
                      },
                    ),
                  if (_selectedRegion != null) const SizedBox(height: 16),

                  // Mahalla Dropdown (only for Yunusobod)
                  if (_selectedDistrict != null &&
                      MahallaData.hasMahallas(_selectedDistrict!))
                    _isLoadingMahallas
                        ? const Center(child: CircularProgressIndicator())
                        : _buildMahallaDropdown(),
                  if (_selectedDistrict != null &&
                      MahallaData.hasMahallas(_selectedDistrict!))
                    const SizedBox(height: 16),

                  // Address
                  _buildTextField(
                    controller: _addressController,
                    label: 'Manzil',
                    hint: 'Ko\'cha, uy raqami',
                    icon: Icons.home_outlined,
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
                  _buildTextField(
                    controller: _passportSeriesController,
                    label: 'Passport seriyasi',
                    hint: 'AA',
                    icon: Icons.badge_outlined,
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
                  _buildTextField(
                    controller: _passportNumberController,
                    label: 'Passport raqami',
                    hint: '1234567',
                    icon: Icons.numbers_outlined,
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
                      onPressed: _isLoading ? null : _saveProfile,
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
                          : const Text(
                              'Saqlash',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    TextCapitalization textCapitalization = TextCapitalization.none,
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
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        validator: validator,
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937),
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          labelStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
          hintStyle: TextStyle(
            color: Colors.grey[400],
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

  Widget _buildDropdown({
    required String label,
    required String hint,
    required IconData icon,
    required String? value,
    required List<String> items,
    required void Function(String?) onChanged,
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
      child: DropdownButtonFormField<String>(
        value: value,
        dropdownColor: Colors.white, // Dropdown menu oq rangda
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937), // Qora matn
        ),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F2937),
              ),
            ),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildMahallaDropdown() {
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
      child: DropdownButtonFormField<String>(
        value: _selectedMahallaId,
        dropdownColor: Colors.white, // Dropdown menu oq rangda
        style: const TextStyle(
          fontSize: 15,
          color: Color(0xFF1F2937), // Qora matn
        ),
        decoration: InputDecoration(
          labelText: 'Mahalla',
          hintText: 'Mahallani tanlang',
          labelStyle: const TextStyle(
            color: Color(0xFF6B7280),
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.home_work_outlined,
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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items: _availableMahallas.map((mahalla) {
          return DropdownMenuItem<String>(
            value: mahalla['id'],
            child: Text(
              mahalla['name']!,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF1F2937),
              ),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedMahallaId = value;
            _selectedMahallaName = _availableMahallas
                .firstWhere((m) => m['id'] == value)['name'];
          });
        },
      ),
    );
  }
}
