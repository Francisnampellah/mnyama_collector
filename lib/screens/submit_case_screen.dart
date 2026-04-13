import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/case_models.dart';
import '../providers/case_provider.dart';

// ─── Design tokens (shared with HomeScreen) ───────────────────────────────────
const _forestGreen = Color(0xFF1A3D2B);
const _forestGreenLight = Color(0xFF2D6647);
const _forestGreenMuted = Color(0xFF7AAB8A);
const _forestGreenSurface = Color(0xFFEAF3EC);

const _warmBg = Color(0xFFF7F5F0);
const _cardBg = Color(0xFFFFFFFF);
const _borderColor = Color(0xFFE0DDD8);

const _blueSurface = Color(0xFFEEF4FB);
const _blueAccent = Color(0xFF185FA5);

const _amberSurface = Color(0xFFFBF4E8);
const _amberAccent = Color(0xFFBA7517);

const _redSurface = Color(0xFFFCEBEB);
const _redAccent = Color(0xFFA32D2D);

const _purpleSurface = Color(0xFFEEEDFE);
const _purpleAccent = Color(0xFF534AB7);

const _textPrimary = Color(0xFF1C1C1E);
const _textMuted = Color(0xFFA09D98);
const _labelColor = Color(0xFF8A8880);
// ─────────────────────────────────────────────────────────────────────────────

class SubmitCaseScreen extends StatefulWidget {
  const SubmitCaseScreen({super.key});

  @override
  State<SubmitCaseScreen> createState() => _SubmitCaseScreenState();
}

class _SubmitCaseScreenState extends State<SubmitCaseScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  late AnimationController _fadeController;

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
  final List<File> _selectedImages = [];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();

    Future.microtask(() {
      context.read<CaseProvider>().fetchDiseaseLabels();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _warmBg,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
        child: Consumer<CaseProvider>(
          builder: (context, caseProvider, _) {
            return Column(
              children: [
                _SubmitHeader(onBack: () => Navigator.of(context).pop()),
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Step 1 — Images
                          _StepSection(
                            stepNumber: 1,
                            title: 'Case images',
                            icon: Icons.image_outlined,
                            iconColor: _purpleAccent,
                            iconBg: _purpleSurface,
                            child: _buildImageUploadSection(),
                          ),
                          const SizedBox(height: 16),

                          // Step 2 — Disease
                          _StepSection(
                            stepNumber: 2,
                            title: 'Disease information',
                            icon: Icons.health_and_safety_outlined,
                            iconColor: _forestGreen,
                            iconBg: _forestGreenSurface,
                            child: _buildDiseaseField(caseProvider),
                          ),
                          const SizedBox(height: 16),

                          // Step 3 — Animal
                          _StepSection(
                            stepNumber: 3,
                            title: 'Animal information',
                            icon: Icons.pets_outlined,
                            iconColor: _amberAccent,
                            iconBg: _amberSurface,
                            child: Column(
                              children: [
                                _buildAnimalTypeField(),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _MnyamaCollectTextField(
                                        label: 'Breed',
                                        hint: 'e.g. Holstein',
                                        onChanged: (v) => _breed = v,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _MnyamaCollectTextField(
                                        label: 'Age (months)',
                                        hint: 'e.g. 24',
                                        keyboardType: TextInputType.number,
                                        onChanged: (v) =>
                                            _ageMonths = int.tryParse(v),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(child: _buildGenderDropdown()),
                                    const SizedBox(width: 10),
                                    Expanded(child: _buildSeverityDropdown()),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Step 4 — Clinical
                          _StepSection(
                            stepNumber: 4,
                            title: 'Clinical information',
                            icon: Icons.medical_information_outlined,
                            iconColor: _redAccent,
                            iconBg: _redSurface,
                            child: Column(
                              children: [
                                _MnyamaCollectTextField(
                                  label: 'Symptoms',
                                  hint: 'Describe the observed symptoms…',
                                  maxLines: 3,
                                  isRequired: true,
                                  onChanged: (v) => _symptoms = v,
                                ),
                                const SizedBox(height: 12),
                                _MnyamaCollectTextField(
                                  label: 'Diagnosis',
                                  hint: 'Any known diagnosis? (optional)',
                                  maxLines: 3,
                                  onChanged: (v) => _diagnosis = v,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Step 5 — Additional
                          _StepSection(
                            stepNumber: 5,
                            title: 'Additional information',
                            icon: Icons.location_on_outlined,
                            iconColor: _blueAccent,
                            iconBg: _blueSurface,
                            child: Column(
                              children: [
                                _MnyamaCollectTextField(
                                  label: 'Farm location',
                                  hint: 'Geographic area or farm name',
                                  onChanged: (v) => _farmLocation = v,
                                ),
                                const SizedBox(height: 12),
                                _MnyamaCollectTextField(
                                  label: 'Additional notes',
                                  hint: 'Any other relevant information…',
                                  maxLines: 3,
                                  onChanged: (v) => _notes = v,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 28),

                          // Submit button
                          _SubmitButton(
                            isSubmitting: caseProvider.isSubmitting,
                            onTap: () => _submitForm(context, caseProvider),
                          ),

                          // Error banner
                          if (caseProvider.error != null) ...[
                            const SizedBox(height: 14),
                            _ErrorBanner(message: caseProvider.error!),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ── Image upload ─────────────────────────────────────────────────────────────

  Widget _buildImageUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _ImagePickerButton(
                icon: Icons.camera_alt_outlined,
                label: 'Camera',
                onTap: _captureImageFromCamera,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ImagePickerButton(
                icon: Icons.photo_library_outlined,
                label: 'Gallery',
                onTap: _pickImageFromGallery,
              ),
            ),
          ],
        ),
        if (_selectedImages.isNotEmpty) ...[
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_selectedImages.length} image${_selectedImages.length > 1 ? 's' : ''} added',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _forestGreen,
                  letterSpacing: 0.2,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: _forestGreenSurface,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'READY',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: _forestGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.only(
                    right: index == _selectedImages.length - 1 ? 0 : 10,
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 110,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _borderColor, width: 0.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: Image.file(
                            _selectedImages[index],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () =>
                              setState(() => _selectedImages.removeAt(index)),
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: _redAccent,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 13,
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

  // ── Disease dropdown ─────────────────────────────────────────────────────────

  Widget _buildDiseaseField(CaseProvider caseProvider) {
    return DropdownSearch<DiseaseLabel>(
      popupProps: PopupProps.menu(
        showSearchBox: true,
        fit: FlexFit.loose,
        searchFieldProps: TextFieldProps(
          decoration: _mnyamaCollectInputDecoration(label: 'Search disease…'),
        ),
        itemBuilder: (context, disease, _) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                disease.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: _textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                disease.code,
                style: const TextStyle(fontSize: 11, color: _textMuted),
              ),
            ],
          ),
        ),
      ),
      items: caseProvider.diseaseLabels,
      selectedItem: _selectedDisease,
      onChanged: (disease) => setState(() => _selectedDisease = disease),
      compareFn: (a, b) => a.id == b.id,
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: _mnyamaCollectInputDecoration(
          label: 'Disease type',
          hint: 'Search and select…',
          prefixIcon: Icons.health_and_safety_outlined,
        ),
      ),
      validator: (v) => v == null ? 'Please select a disease' : null,
    );
  }

  Widget _buildAnimalTypeField() {
    return DropdownSearch<String>(
      items: const ['Cattle', 'Poultry', 'Pig', 'Sheep', 'Goat', 'Other'],
      selectedItem: _animalType,
      onChanged: (v) => setState(() => _animalType = v),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: _mnyamaCollectInputDecoration(
          label: 'Animal type',
          hint: 'Select animal type…',
          prefixIcon: Icons.pets_outlined,
        ),
      ),
      validator: (v) => v == null ? 'Please select animal type' : null,
    );
  }

  Widget _buildGenderDropdown() {
    return DropdownSearch<Gender>(
      items: Gender.values,
      selectedItem: _gender,
      onChanged: (v) => setState(() => _gender = v),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: _mnyamaCollectInputDecoration(
          label: 'Gender',
          prefixIcon: Icons.wc_outlined,
        ),
      ),
      itemAsString: (item) => item.name.toUpperCase(),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  Widget _buildSeverityDropdown() {
    return DropdownSearch<CaseSeverity>(
      items: CaseSeverity.values,
      selectedItem: _severity,
      onChanged: (v) => setState(() => _severity = v),
      dropdownDecoratorProps: DropDownDecoratorProps(
        dropdownSearchDecoration: _mnyamaCollectInputDecoration(
          label: 'Severity',
          prefixIcon: Icons.warning_amber_outlined,
        ),
      ),
      itemAsString: (item) => item.name.toUpperCase(),
      validator: (v) => v == null ? 'Required' : null,
    );
  }

  // ── Shared input decoration ──────────────────────────────────────────────────

  InputDecoration _mnyamaCollectInputDecoration({
    required String label,
    String? hint,
    IconData? prefixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: _warmBg,
      labelStyle: const TextStyle(
        fontSize: 13,
        color: _labelColor,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, size: 18, color: _labelColor)
          : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor, width: 0.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _borderColor, width: 0.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _forestGreen, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: _redAccent, width: 1),
      ),
    );
  }

  // ── Image pickers ────────────────────────────────────────────────────────────

  Future<void> _captureImageFromCamera() async {
    try {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );
      if (photo != null) {
        final file = File(photo.path);
        if (await file.exists()) {
          setState(() => _selectedImages.add(file));
          _showSnack('Image captured successfully', isError: false);
        }
      }
    } catch (e) {
      _showSnack('Error capturing image: $e', isError: true);
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image != null) {
        final file = File(image.path);
        if (await file.exists()) {
          setState(() => _selectedImages.add(file));
          _showSnack('Image selected successfully', isError: false);
        }
      }
    } catch (e) {
      _showSnack('Error picking image: $e', isError: true);
    }
  }

  void _showSnack(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? _redAccent : _forestGreenLight,
        duration: Duration(seconds: isError ? 4 : 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Submit ───────────────────────────────────────────────────────────────────

  Future<void> _submitForm(
    BuildContext context,
    CaseProvider caseProvider,
  ) async {
    if (!_formKey.currentState!.validate()) {
      _showSnack('Please fill in all required fields', isError: true);
      return;
    }
    if (_selectedDisease == null) {
      _showSnack('Please select a disease', isError: true);
      return;
    }
    if (_animalType == null) {
      _showSnack('Please select an animal type', isError: true);
      return;
    }

    try {
      final caseRequest = CreateCaseRequest(
        diseaseLabelId: _selectedDisease!.id,
        animalType: _animalType!,
        breed: _breed ?? '',
        ageMonths: _ageMonths,
        gender: _gender ?? Gender.UNKNOWN,
        symptoms: _symptoms ?? '',
        diagnosis: _diagnosis ?? '',
        notes: _notes ?? '',
        farmLocation: _farmLocation ?? '',
        severity: _severity ?? CaseSeverity.MODERATE,
      );

      await caseProvider.createCaseWithImages(caseRequest, _selectedImages);

      if (mounted) {
        _showSnack('Case submitted successfully!', isError: false);
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      _showSnack('Error: $e', isError: true);
    }
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _SubmitHeader extends StatelessWidget {
  const _SubmitHeader({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Container(
      color: _forestGreen,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(24, topPad + 16, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: onBack,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                        width: 0.5,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: Color(0xFFB0C8B8),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Title row
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _forestGreenLight,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.upload_file_rounded,
                        color: Color(0xFFA8D4B8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit case',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFE8F0EB),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Report a new animal disease',
                          style: TextStyle(
                            fontSize: 12,
                            color: _forestGreenMuted,
                            letterSpacing: 0.2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
          // Curved bottom
          Container(
            height: 26,
            decoration: const BoxDecoration(
              color: _warmBg,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step section card ────────────────────────────────────────────────────────

class _StepSection extends StatelessWidget {
  const _StepSection({
    required this.stepNumber,
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.child,
  });

  final int stepNumber;
  final String title;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step $stepNumber',
                        style: const TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                          color: _labelColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: _textPrimary,
                          height: 1.1,
                        ),
                      ),
                    ],
                  ),
                ),
                // Step number pill
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$stepNumber',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(height: 0.5, color: _borderColor),

          // Content
          Padding(padding: const EdgeInsets.all(16), child: child),
        ],
      ),
    );
  }
}

// ─── Text field ───────────────────────────────────────────────────────────────

class _MnyamaCollectTextField extends StatelessWidget {
  const _MnyamaCollectTextField({
    required this.label,
    this.hint,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    required this.onChanged,
    this.isRequired = false,
  });

  final String label;
  final String? hint;
  final TextInputType keyboardType;
  final int maxLines;
  final ValueChanged<String> onChanged;
  final bool isRequired;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
        fontSize: 14,
        color: _textPrimary,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: _warmBg,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: _labelColor,
          fontWeight: FontWeight.w500,
        ),
        hintStyle: const TextStyle(fontSize: 13, color: _textMuted),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor, width: 0.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _borderColor, width: 0.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _forestGreen, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11, color: _redAccent),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      minLines: maxLines == 1 ? 1 : maxLines,
      onChanged: onChanged,
      validator: isRequired
          ? (v) => (v?.isEmpty ?? true) ? 'This field is required' : null
          : null,
    );
  }
}

// ─── Image picker button ──────────────────────────────────────────────────────

class _ImagePickerButton extends StatelessWidget {
  const _ImagePickerButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: _warmBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _forestGreen.withOpacity(0.25), width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: _forestGreenSurface,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _forestGreen, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _forestGreen,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Submit button ────────────────────────────────────────────────────────────

class _SubmitButton extends StatefulWidget {
  const _SubmitButton({required this.isSubmitting, required this.onTap});

  final bool isSubmitting;
  final VoidCallback onTap;

  @override
  State<_SubmitButton> createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<_SubmitButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pressCtrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _pressCtrl.forward(),
        onTapUp: (_) {
          _pressCtrl.reverse();
          if (!widget.isSubmitting) widget.onTap();
        },
        onTapCancel: () => _pressCtrl.reverse(),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: _forestGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.isSubmitting)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Color(0xFFA8D4B8),
                    ),
                  ),
                )
              else
                const Icon(
                  Icons.check_circle_outline_rounded,
                  color: Color(0xFFA8D4B8),
                  size: 20,
                ),
              const SizedBox(width: 10),
              Text(
                widget.isSubmitting ? 'Submitting…' : 'Submit case',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE8F0EB),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Error banner ─────────────────────────────────────────────────────────────

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _redSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _redAccent.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: _redAccent, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 13,
                color: _redAccent,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
