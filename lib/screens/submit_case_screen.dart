import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/case_models.dart';
import '../providers/case_provider.dart';

class SubmitCaseScreen extends StatefulWidget {
  const SubmitCaseScreen({super.key});

  @override
  State<SubmitCaseScreen> createState() => _SubmitCaseScreenState();
}

class _SubmitCaseScreenState extends State<SubmitCaseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();

  // Form fields
  DiseaseLabel? _selectedDisease;
  String? _animalType;
  String? _breed;
  int? _ageMonths;
  Gender? _gender;
  String? _symptoms;
  String? _diagnosis;
  String? _notes;
  String? _farmLocation;
  CaseSeverity? _severity;

  // Image fields
  List<File> _selectedImages = [];
  bool _isUploadingImages = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<CaseProvider>().fetchDiseaseLabels();
    });
  }

  Future<void> _captureImageFromCamera() async {
    try {
      print('[SubmitCaseScreen] Starting camera capture...');

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      print(
        '[SubmitCaseScreen] Camera capture returned: ${photo != null ? "photo captured" : "cancelled by user"}',
      );

      if (photo != null) {
        final file = File(photo.path);
        final exists = await file.exists();
        print('[SubmitCaseScreen] Photo file exists: $exists');

        if (exists) {
          final fileSize = await file.length();
          print('[SubmitCaseScreen] Photo file size: $fileSize bytes');
        }

        setState(() {
          _selectedImages.add(File(photo.path));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image captured successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('[SubmitCaseScreen] ERROR capturing image: $e');
      print('[SubmitCaseScreen] Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error capturing image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      print('[SubmitCaseScreen] Starting gallery picker...');

      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);
        final exists = await file.exists();
        print('[SubmitCaseScreen] Gallery image exists: $exists');

        setState(() {
          _selectedImages.add(File(image.path));
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      print('[SubmitCaseScreen] ERROR picking image: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit New Case'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Consumer<CaseProvider>(
        builder: (context, caseProvider, _) {
          return CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: true,
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Case Images Section
                        _buildSectionHeader(
                          context,
                          icon: Icons.image,
                          title: 'Case Images',
                          number: '1',
                        ),
                        const SizedBox(height: 16),
                        _buildImageUploadSection(context),
                        const SizedBox(height: 32),

                        // Disease Section
                        _buildSectionHeader(
                          context,
                          icon: Icons.health_and_safety,
                          title: 'Disease Information',
                          number: '2',
                        ),
                        const SizedBox(height: 16),
                        _buildDiseaseField(context, caseProvider),
                        const SizedBox(height: 32),

                        // Animal Information Section
                        _buildSectionHeader(
                          context,
                          icon: Icons.pets,
                          title: 'Animal Information',
                          number: '3',
                        ),
                        const SizedBox(height: 16),
                        _buildAnimalTypeField(context),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Breed',
                                hint: 'Optional',
                                keyboardType: TextInputType.text,
                                onChanged: (value) => _breed = value,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTextField(
                                label: 'Age (months)',
                                hint: 'Number',
                                keyboardType: TextInputType.number,
                                onChanged: (value) {
                                  _ageMonths = int.tryParse(value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: _buildGenderDropdown(context)),
                            const SizedBox(width: 12),
                            Expanded(child: _buildSeverityDropdown(context)),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Clinical Information Section
                        _buildSectionHeader(
                          context,
                          icon: Icons.medical_information,
                          title: 'Clinical Information',
                          number: '4',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Symptoms',
                          hint: 'Describe the symptoms...',
                          maxLines: 3,
                          onChanged: (value) => _symptoms = value,
                          isRequired: true,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Diagnosis',
                          hint: 'Any known diagnosis? (Optional)',
                          maxLines: 3,
                          onChanged: (value) => _diagnosis = value,
                        ),
                        const SizedBox(height: 32),

                        // Additional Information Section
                        _buildSectionHeader(
                          context,
                          icon: Icons.info,
                          title: 'Additional Information',
                          number: '5',
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Farm Location',
                          hint: 'Optional',
                          keyboardType: TextInputType.text,
                          onChanged: (value) => _farmLocation = value,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          label: 'Additional Notes',
                          hint: 'Any other relevant information?',
                          maxLines: 3,
                          onChanged: (value) => _notes = value,
                        ),
                        const SizedBox(height: 32),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: caseProvider.isSubmitting
                                ? null
                                : () => _submitForm(context, caseProvider),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: caseProvider.isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Text(
                                    'Submit Case',
                                    style: Theme.of(context).textTheme.bodyLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
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
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String number,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Icon(icon, color: Theme.of(context).primaryColor, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildImageUploadSection(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildImageButton(
                context,
                icon: Icons.camera_alt,
                label: 'Take Photo',
                onTap: _captureImageFromCamera,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildImageButton(
                context,
                icon: Icons.image,
                label: 'Choose from Gallery',
                onTap: _pickImageFromGallery,
              ),
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(
            '${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''} selected',
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedImages.removeAt(index);
                            });
                          },
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildImageButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
          color: Theme.of(context).primaryColor.withOpacity(0.05),
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiseaseField(BuildContext context, CaseProvider caseProvider) {
    return DropdownSearch<DiseaseLabel>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        itemBuilder: (context, disease, _) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disease.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  disease.code,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          );
        },
      ),
      items: caseProvider.diseaseLabels,
      selectedItem: _selectedDisease,
      onChanged: (disease) => setState(() => _selectedDisease = disease),
      compareFn: (a, b) => a.id == b.id,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Disease',
          hintText: 'Search and select...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.health_and_safety),
        ),
      ),
      validator: (disease) {
        if (disease == null) {
          return 'Please select a disease';
        }
        return null;
      },
    );
  }

  Widget _buildAnimalTypeField(BuildContext context) {
    return DropdownSearch<String>(
      items: const ['Cattle', 'Poultry', 'Pig', 'Sheep', 'Goat', 'Other'],
      selectedItem: _animalType,
      onChanged: (value) => setState(() => _animalType = value),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Animal Type',
          hintText: 'Select animal type...',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.pets),
        ),
      ),
      validator: (value) {
        if (value == null) {
          return 'Please select animal type';
        }
        return null;
      },
    );
  }

  Widget _buildGenderDropdown(BuildContext context) {
    return DropdownSearch<Gender>(
      items: Gender.values,
      selectedItem: _gender,
      onChanged: (value) => setState(() => _gender = value),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Gender',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.wc),
        ),
      ),
      itemAsString: (item) => item.name.toUpperCase(),
      validator: (value) {
        if (value == null) {
          return 'Please select gender';
        }
        return null;
      },
    );
  }

  Widget _buildSeverityDropdown(BuildContext context) {
    return DropdownSearch<CaseSeverity>(
      items: CaseSeverity.values,
      selectedItem: _severity,
      onChanged: (value) => setState(() => _severity = value),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: InputDecoration(
          labelText: 'Severity',
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          prefixIcon: const Icon(Icons.warning),
        ),
      ),
      itemAsString: (item) => item.name.toUpperCase(),
      validator: (value) {
        if (value == null) {
          return 'Please select severity';
        }
        return null;
      },
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    required Function(String) onChanged,
    bool isRequired = false,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: maxLines == 1 ? 1 : maxLines,
      onChanged: onChanged,
      validator: isRequired
          ? (value) {
              if (value?.isEmpty ?? true) {
                return 'This field is required';
              }
              return null;
            }
          : null,
    );
  }

  Future<void> _submitForm(
    BuildContext context,
    CaseProvider caseProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    if (_selectedDisease == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a disease')));
      return;
    }

    if (_animalType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an animal type')),
      );
      return;
    }

    try {
      print('[SubmitCaseScreen] Submitting case...');

      // Create the case request object
      final caseRequest = CreateCaseRequest(
        diseaseLabelId: _selectedDisease!.id,
        animalType: _animalType!,
        breed: _breed,
        ageMonths: _ageMonths,
        gender: _gender ?? Gender.UNKNOWN,
        symptoms: _symptoms ?? '',
        diagnosis: _diagnosis,
        notes: _notes,
        farmLocation: _farmLocation,
        severity: _severity ?? CaseSeverity.MODERATE,
      );

      await caseProvider.createCaseWithImages(caseRequest, _selectedImages);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Case submitted successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Navigator.of(context).pop();
        });
      }
    } catch (e) {
      print('[SubmitCaseScreen] Error submitting case: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
