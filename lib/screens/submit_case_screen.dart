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
    // Fetch disease labels when screen loads
    Future.microtask(() {
      context.read<CaseProvider>().fetchDiseaseLabels();
    });
  }

  Future<void> _captureImageFromCamera() async {
    try {
      print('[SubmitCaseScreen] Starting camera capture...');
      print('[SubmitCaseScreen] ImagePicker instance: $_imagePicker');

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      print(
        '[SubmitCaseScreen] Camera capture returned: ${photo != null ? "photo captured" : "cancelled by user"}',
      );

      if (photo != null) {
        print('[SubmitCaseScreen] Photo path: ${photo.path}');
        print('[SubmitCaseScreen] Photo name: ${photo.name}');

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
        print(
          '[SubmitCaseScreen] Image added to list. Total images: ${_selectedImages.length}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image captured successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('[SubmitCaseScreen] Camera capture cancelled by user');
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
      print('[SubmitCaseScreen] Starting gallery image selection...');
      print('[SubmitCaseScreen] ImagePicker instance: $_imagePicker');

      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      print(
        '[SubmitCaseScreen] Gallery selection returned: ${photo != null ? "image selected" : "cancelled by user"}',
      );

      if (photo != null) {
        print('[SubmitCaseScreen] Image path: ${photo.path}');
        print('[SubmitCaseScreen] Image name: ${photo.name}');

        final file = File(photo.path);
        final exists = await file.exists();
        print('[SubmitCaseScreen] Image file exists: $exists');

        if (exists) {
          final fileSize = await file.length();
          print('[SubmitCaseScreen] Image file size: $fileSize bytes');
        }

        setState(() {
          _selectedImages.add(File(photo.path));
        });
        print(
          '[SubmitCaseScreen] Image added to list. Total images: ${_selectedImages.length}',
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image selected successfully'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      } else {
        print('[SubmitCaseScreen] Gallery selection cancelled by user');
      }
    } catch (e, stackTrace) {
      print('[SubmitCaseScreen] ERROR selecting image: $e');
      print('[SubmitCaseScreen] Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        print(
          '[SubmitCaseScreen] ========== CASE SUBMISSION STARTED ==========',
        );
        print('[SubmitCaseScreen] Form validation: PASSED');

        final request = CreateCaseRequest(
          diseaseLabelId: _selectedDisease!.id,
          animalType: _animalType!,
          breed: _breed,
          ageMonths: _ageMonths,
          gender: _gender!,
          symptoms: _symptoms!,
          diagnosis: _diagnosis,
          notes: _notes,
          farmLocation: _farmLocation,
          severity: _severity!,
        );

        print('[SubmitCaseScreen] Case request created:');
        print('[SubmitCaseScreen]   - Disease ID: ${request.diseaseLabelId}');
        print('[SubmitCaseScreen]   - Animal Type: ${request.animalType}');
        print('[SubmitCaseScreen]   - Breed: ${request.breed}');
        print('[SubmitCaseScreen]   - Age: ${request.ageMonths} months');
        print('[SubmitCaseScreen]   - Gender: ${request.gender}');
        print('[SubmitCaseScreen]   - Severity: ${request.severity}');
        print('[SubmitCaseScreen] Submitting case to provider...');

        final caseProvider = context.read<CaseProvider>();
        final createdCase = await caseProvider.submitCase(request);

        print('[SubmitCaseScreen] ✓ Case submitted successfully!');
        print('[SubmitCaseScreen] Case ID: ${createdCase.id}');
        print('[SubmitCaseScreen] Case Status: ${createdCase.status}');

        if (!mounted) return;

        // Upload images if any selected
        if (_selectedImages.isNotEmpty) {
          print('[SubmitCaseScreen] ');
          print('[SubmitCaseScreen] ========== STARTING IMAGE UPLOAD ==========');
          print('[SubmitCaseScreen] Total images to upload: ${_selectedImages.length}');
          
          // Log detailed info about each image
          for (int i = 0; i < _selectedImages.length; i++) {
            final imageFile = _selectedImages[i];
            final exists = await imageFile.exists();
            final size = await imageFile.length();
            print('[SubmitCaseScreen] Image ${i + 1}:');
            print('[SubmitCaseScreen]   - Path: ${imageFile.path}');
            print('[SubmitCaseScreen]   - Type: ${imageFile.runtimeType}');
            print('[SubmitCaseScreen]   - Exists: $exists');
            print('[SubmitCaseScreen]   - Size: $size bytes');
          }

          setState(() => _isUploadingImages = true);

          try {
            print('[SubmitCaseScreen] ');
            print('[SubmitCaseScreen] Passing images to provider...');
            print('[SubmitCaseScreen] - Case ID: ${createdCase.id}');
            print('[SubmitCaseScreen] - Images count: ${_selectedImages.length}');
            print('[SubmitCaseScreen] - Images type: ${_selectedImages.runtimeType}');
            
            await caseProvider.uploadCaseImages(
              createdCase.id,
              _selectedImages,
            );

            if (!mounted) return;
            setState(() => _isUploadingImages = false);

            print('[SubmitCaseScreen] ✓ All images uploaded successfully!');
            print(
              '[SubmitCaseScreen] ========== CASE SUBMISSION COMPLETE ==========',
            );

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Case created with ${_selectedImages.length} image(s)!',
                ),
                backgroundColor: Colors.green,
              ),
            );
          } catch (e, stackTrace) {
            if (!mounted) return;
            setState(() => _isUploadingImages = false);

            print('[SubmitCaseScreen] ✗ Image upload FAILED: $e');
            print('[SubmitCaseScreen] Stack trace: $stackTrace');

            // Show warning: case created but images failed to upload
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Case created but image upload failed: $e'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        } else {
          // Case created without images
          print('[SubmitCaseScreen] No images to upload');
          print(
            '[SubmitCaseScreen] ========== CASE SUBMISSION COMPLETE ==========',
          );

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Case submitted successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }

        if (!mounted) return;
        // Navigate back
        Navigator.of(context).pop(true);
      } catch (e, stackTrace) {
        if (!mounted) return;
        setState(() => _isUploadingImages = false);

        print('[SubmitCaseScreen] ✗ CASE SUBMISSION FAILED: $e');
        print('[SubmitCaseScreen] Stack trace: $stackTrace');
        print(
          '[SubmitCaseScreen] ========== CASE SUBMISSION FAILED ==========',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Disease Case'), elevation: 0),
      body: Consumer<CaseProvider>(
        builder: (context, caseProvider, _) {
          if (caseProvider.isLoadingDiseases) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading diseases...'),
                ],
              ),
            );
          }

          // Show error state with retry
          if (caseProvider.error != null &&
              caseProvider.diseaseLabels.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load diseases',
                      style: Theme.of(
                        context,
                      ).textTheme.titleLarge?.copyWith(color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      caseProvider.error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        caseProvider.clearError();
                        caseProvider.fetchDiseaseLabels();
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Warning if diseases not loaded
                  if (caseProvider.diseaseLabels.isEmpty &&
                      !caseProvider.isLoadingDiseases)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.orange),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'No diseases available. Please contact administrator.',
                              style: TextStyle(
                                color: Colors.orange,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (caseProvider.diseaseLabels.isEmpty &&
                      !caseProvider.isLoadingDiseases)
                    const SizedBox(height: 24),

                  // Section: Disease Selection
                  _SectionHeader(title: 'Disease Information'),
                  const SizedBox(height: 16),

                  // Disease Label Dropdown with Search
                  DropdownSearch<DiseaseLabel>(
                    items: caseProvider.diseaseLabels,
                    selectedItem: _selectedDisease,
                    onChanged: (value) {
                      setState(() => _selectedDisease = value);
                    },
                    popupProps: PopupProps.menu(
                      showSearchBox: true,
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search diseases...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: const Icon(Icons.search),
                          contentPadding: const EdgeInsets.all(12),
                        ),
                      ),
                      itemBuilder: (context, disease, isSelected) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            disease.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      },
                      menuProps: MenuProps(
                        borderRadius: BorderRadius.circular(8),
                        elevation: 8,
                      ),
                    ),
                    dropdownButtonProps: DropdownButtonProps(
                      color: Theme.of(context).primaryColor,
                    ),
                    dropdownDecoratorProps: DropDownDecoratorProps(
                      dropdownSearchDecoration: InputDecoration(
                        labelText: 'Select Disease *',
                        hintText: 'Choose or search disease',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.local_hospital),
                        contentPadding: const EdgeInsets.fromLTRB(
                          12,
                          16,
                          8,
                          12,
                        ),
                      ),
                    ),
                    validator: (value) {
                      if (value == null) {
                        return 'Please select a disease';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Section: Animal Information
                  _SectionHeader(title: 'Animal Information'),
                  const SizedBox(height: 16),

                  // Animal Type
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Animal Type *',
                      hintText: 'e.g., Cow, Sheep, Goat',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.pets),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please enter animal type';
                      }
                      return null;
                    },
                    onSaved: (value) => _animalType = value,
                  ),
                  const SizedBox(height: 16),

                  // Breed (Optional)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Breed',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.info_outline),
                    ),
                    onSaved: (value) => _breed = value,
                  ),
                  const SizedBox(height: 16),

                  // Age in Months (Optional)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Age (months)',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.calendar_today),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value != null && value.isNotEmpty) {
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                      }
                      return null;
                    },
                    onSaved: (value) => _ageMonths = value?.isNotEmpty ?? false
                        ? int.parse(value!)
                        : null,
                  ),
                  const SizedBox(height: 16),

                  // Gender
                  DropdownButtonFormField<Gender>(
                    value: _gender,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Gender *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.wc),
                    ),
                    items: Gender.values.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            gender.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _gender = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select gender';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Section: Clinical Information
                  _SectionHeader(title: 'Clinical Information'),
                  const SizedBox(height: 16),

                  // Symptoms
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Symptoms *',
                      hintText: 'Describe the clinical symptoms',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.description),
                    ),
                    maxLines: 4,
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'Please describe symptoms';
                      }
                      return null;
                    },
                    onSaved: (value) => _symptoms = value,
                  ),
                  const SizedBox(height: 16),

                  // Diagnosis (Optional)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Diagnosis',
                      hintText: 'Final diagnosis if known',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.medical_services),
                    ),
                    maxLines: 3,
                    onSaved: (value) => _diagnosis = value,
                  ),
                  const SizedBox(height: 16),

                  // Severity
                  DropdownButtonFormField<CaseSeverity>(
                    value: _severity,
                    isExpanded: true,
                    decoration: InputDecoration(
                      labelText: 'Severity *',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.warning),
                    ),
                    items: CaseSeverity.values.map((severity) {
                      return DropdownMenuItem(
                        value: severity,
                        child: SizedBox(
                          width: double.infinity,
                          child: Text(
                            severity.name,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _severity = value);
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Please select severity';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),

                  // Section: Additional Information
                  _SectionHeader(title: 'Additional Information'),
                  const SizedBox(height: 16),

                  // Notes (Optional)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      hintText: 'Any additional notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.note),
                    ),
                    maxLines: 3,
                    onSaved: (value) => _notes = value,
                  ),
                  const SizedBox(height: 16),

                  // Farm Location (Optional)
                  TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Farm Location',
                      hintText: 'Location of the farm',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.location_on),
                    ),
                    onSaved: (value) => _farmLocation = value,
                  ),
                  const SizedBox(height: 32),

                  // Section: Case Images
                  _SectionHeader(title: 'Case Images'),
                  const SizedBox(height: 16),
                  Text(
                    'Capture or select images of the animal and disease signs',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),

                  // Image Capture Buttons
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _captureImageFromCamera,
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Camera'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _pickImageFromGallery,
                          icon: const Icon(Icons.photo_library),
                          label: const Text('Gallery'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Images Preview Grid
                  if (_selectedImages.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected Images (${_selectedImages.length})',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                          itemCount: _selectedImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey[300]!,
                                      width: 1,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_selectedImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => _removeImage(index),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    padding: const EdgeInsets.all(4),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey[300]!,
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[50],
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.image_not_supported,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No images selected',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Tap Camera or Gallery to add images',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (caseProvider.isSubmitting || _isUploadingImages)
                          ? null
                          : _submitForm,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: (caseProvider.isSubmitting || _isUploadingImages)
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  _isUploadingImages
                                      ? 'Uploading Images...'
                                      : 'Submitting...',
                                ),
                              ],
                            )
                          : const Text('Submit Case'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Cancel Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
    );
  }
}
