import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/ariza_provider.dart';
import '../../data/models/ariza_model.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../services/firebase_service.dart';

class YangiArizaPage extends ConsumerStatefulWidget {
  const YangiArizaPage({super.key});

  @override
  ConsumerState<YangiArizaPage> createState() => _YangiArizaPageState();
}

class _YangiArizaPageState extends ConsumerState<YangiArizaPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  String _selectedCategory = AppConstants.arizaCategories[0];
  final List<File> _selectedImages = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maksimum 3 ta rasm qo\'shish mumkin')),
      );
      return;
    }

    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _submitAriza() async {
    if (!_formKey.currentState!.validate()) return;

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    setState(() => _isSubmitting = true);

    try {
      // Upload images
      final List<String> imageUrls = [];
      for (var i = 0; i < _selectedImages.length; i++) {
        final url = await FirebaseService.uploadImage(
          imageFile: _selectedImages[i],
          path: 'arizalar/${currentUser.id}/${DateTime.now().millisecondsSinceEpoch}_$i.jpg',
        );
        imageUrls.add(url);
      }

      // Create ariza
      final ariza = ArizaModel(
        id: '',
        userId: currentUser.id,
        userFullName: currentUser.fullName,
        userPhone: currentUser.phoneNumber,
        category: _selectedCategory,
        description: _descriptionController.text.trim(),
        status: AppConstants.arizaStatusYuborildi,
        imageUrls: imageUrls,
        mahallaId: currentUser.mahallaId,
        createdAt: DateTime.now(),
      );

      await ref.read(createArizaProvider.notifier).createAriza(ariza);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ariza muvaffaqiyatli yuborildi'),
            backgroundColor: Colors.green,
          ),
        );
        context.pop();
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
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yangi Ariza'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Kategoriya',
                prefixIcon: Icon(Icons.category),
              ),
              items: AppConstants.arizaCategories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCategory = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Ariza matni',
                hintText: 'Arizangizni batafsil yozing...',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 5,
              maxLength: AppConstants.maxArizaTextLength,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ariza matnini kiriting';
                }
                if (value.trim().length < 10) {
                  return 'Ariza matni kamida 10 ta belgidan iborat bo\'lishi kerak';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Images
            Text(
              'Rasmlar (ixtiyoriy)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (_selectedImages.isNotEmpty)
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _selectedImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(_selectedImages[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 12,
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedImages.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('Rasm qo\'shish'),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitAriza,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Yuborish'),
            ),
          ],
        ),
      ),
    );
  }
}
