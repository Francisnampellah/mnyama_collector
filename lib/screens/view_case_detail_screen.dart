import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/case_models.dart';
import '../providers/case_provider.dart';
import '../services/case_service.dart';
import '../config/app_config.dart';
import '../widgets/case_image_widget.dart';

// ─── Design tokens ────────────────────────────────────────────────────────────
const _forestGreen = Color(0xFF1A3D2B);
const _forestGreenLight = Color(0xFF2D6647);
const _forestGreenMuted = Color(0xFF7AAB8A);
const _forestGreenSurface = Color(0xFFEAF3EC);
const _warmBg = Color(0xFFF7F5F0);
const _cardBg = Color(0xFFFFFFFF);
const _borderColor = Color(0xFFE0DDD8);
const _textPrimary = Color(0xFF1C1C1E);
const _textMuted = Color(0xFFA09D98);
const _labelColor = Color(0xFF8A8880);

const _blueAccent = Color(0xFF185FA5);
const _blueSurface = Color(0xFFEEF4FB);
const _amberAccent = Color(0xFFBA7517);
const _amberSurface = Color(0xFFFBF4E8);
const _redAccent = Color(0xFFA32D2D);
const _redSurface = Color(0xFFFCEBEB);
const _purpleAccent = Color(0xFF534AB7);
const _purpleSurface = Color(0xFFEEEDFE);
// ─────────────────────────────────────────────────────────────────────────────

class ViewCaseDetailScreen extends StatefulWidget {
  final String caseId;
  const ViewCaseDetailScreen({super.key, required this.caseId});

  @override
  State<ViewCaseDetailScreen> createState() => _ViewCaseDetailScreenState();
}

class _ViewCaseDetailScreenState extends State<ViewCaseDetailScreen>
    with TickerProviderStateMixin {
  late PageController _imagePageController;
  int _currentImageIndex = 0;
  late AnimationController _fadeController;
  bool _isEditMode = false;
  List<File> _selectedImages = [];
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();
    _loadCaseDetails();
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCaseDetails() async {
    await context.read<CaseProvider>().getCaseById(widget.caseId);
  }

  // ── Status helpers ───────────────────────────────────────────────────────────

  Color _statusColor(CaseStatus s) => switch (s) {
    CaseStatus.SUBMITTED => _blueAccent,
    CaseStatus.UNDER_REVIEW => _amberAccent,
    CaseStatus.APPROVED => _forestGreen,
    CaseStatus.REJECTED => _redAccent,
  };

  Color _statusSurface(CaseStatus s) => switch (s) {
    CaseStatus.SUBMITTED => _blueSurface,
    CaseStatus.UNDER_REVIEW => _amberSurface,
    CaseStatus.APPROVED => _forestGreenSurface,
    CaseStatus.REJECTED => _redSurface,
  };

  String _statusLabel(CaseStatus s) => switch (s) {
    CaseStatus.SUBMITTED => 'Submitted',
    CaseStatus.UNDER_REVIEW => 'Under Review',
    CaseStatus.APPROVED => 'Approved',
    CaseStatus.REJECTED => 'Rejected',
  };

  // ── Severity helpers ─────────────────────────────────────────────────────────

  Color _severityColor(CaseSeverity s) => switch (s) {
    CaseSeverity.MILD => _forestGreen,
    CaseSeverity.MODERATE => _amberAccent,
    CaseSeverity.SEVERE => const Color(0xFFB45309),
    CaseSeverity.CRITICAL => _redAccent,
  };

  Color _severitySurface(CaseSeverity s) => switch (s) {
    CaseSeverity.MILD => _forestGreenSurface,
    CaseSeverity.MODERATE => _amberSurface,
    CaseSeverity.SEVERE => const Color(0xFFFEF3C7),
    CaseSeverity.CRITICAL => _redSurface,
  };

  String _severityLabel(CaseSeverity s) => switch (s) {
    CaseSeverity.MILD => 'Mild',
    CaseSeverity.MODERATE => 'Moderate',
    CaseSeverity.SEVERE => 'Severe',
    CaseSeverity.CRITICAL => 'Critical',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _warmBg,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
        child: Consumer<CaseProvider>(
          builder: (context, caseProvider, _) {
            // Loading
            if (caseProvider.isLoadingCases) {
              return Column(
                children: [
                  _DetailHeader(
                    animalType: null,
                    statusLabel: null,
                    statusColor: _forestGreen,
                    statusSurface: _forestGreenSurface,
                    onBack: () => Navigator.of(context).pop(),
                    isEditMode: _isEditMode,
                    onToggleEdit: () =>
                        setState(() => _isEditMode = !_isEditMode),
                  ),
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: _forestGreen,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                ],
              );
            }

            // Error
            if (caseProvider.error != null) {
              return Column(
                children: [
                  _DetailHeader(
                    animalType: null,
                    statusLabel: null,
                    statusColor: _forestGreen,
                    statusSurface: _forestGreenSurface,
                    onBack: () => Navigator.of(context).pop(),
                    isEditMode: _isEditMode,
                    onToggleEdit: () =>
                        setState(() => _isEditMode = !_isEditMode),
                  ),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 72,
                              height: 72,
                              decoration: BoxDecoration(
                                color: _redSurface,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Icon(
                                Icons.error_outline_rounded,
                                size: 36,
                                color: _redAccent,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Failed to load case',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: _textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              caseProvider.error ?? 'Unknown error',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _textMuted,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextButton.icon(
                              onPressed: _loadCaseDetails,
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Retry'),
                              style: TextButton.styleFrom(
                                foregroundColor: _forestGreen,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            final caseItem = caseProvider.currentCase;
            if (caseItem == null) {
              return const Center(child: Text('No case found'));
            }

            // Log the backend response
            _logCaseResponse(caseItem);

            final sColor = _statusColor(caseItem.status);
            final sSurface = _statusSurface(caseItem.status);

            return Column(
              children: [
                _DetailHeader(
                  animalType: caseItem.animalType,
                  statusLabel: _statusLabel(caseItem.status),
                  statusColor: sColor,
                  statusSurface: sSurface,
                  onBack: () => Navigator.of(context).pop(),
                  isEditMode: _isEditMode,
                  onToggleEdit: () =>
                      setState(() => _isEditMode = !_isEditMode),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Status + Severity chips
                        Row(
                          children: [
                            Expanded(
                              child: _SummaryChip(
                                icon: Icons.info_outlined,
                                label: 'Status',
                                value: _statusLabel(caseItem.status),
                                iconColor: sColor,
                                iconBg: sSurface,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SummaryChip(
                                icon: Icons.warning_amber_rounded,
                                label: 'Severity',
                                value: _severityLabel(caseItem.severity),
                                iconColor: _severityColor(caseItem.severity),
                                iconBg: _severitySurface(caseItem.severity),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Images
                        if (_isEditMode) ...[
                          _buildImageUploadSection(),
                          const SizedBox(height: 16),
                        ] else if (caseItem.images != null &&
                            caseItem.images!.isNotEmpty) ...[
                          _buildImageGallery(caseItem.images!),
                          const SizedBox(height: 16),
                        ],

                        // Animal information
                        _DetailSection(
                          icon: Icons.pets_outlined,
                          iconColor: _amberAccent,
                          iconBg: _amberSurface,
                          title: 'Animal information',
                          children: [
                            _InfoRow(
                              label: 'Type',
                              value: caseItem.animalType,
                              icon: Icons.pets_outlined,
                              iconColor: _amberAccent,
                              iconBg: _amberSurface,
                            ),
                            if (caseItem.breed != null) ...[
                              _Divider(),
                              _InfoRow(
                                label: 'Breed',
                                value: caseItem.breed!,
                                icon: Icons.grain_outlined,
                                iconColor: _amberAccent,
                                iconBg: _amberSurface,
                              ),
                            ],
                            _Divider(),
                            _InfoRow(
                              label: 'Gender',
                              value: caseItem.gender.name.toUpperCase(),
                              icon: Icons.wc_outlined,
                              iconColor: _amberAccent,
                              iconBg: _amberSurface,
                            ),
                            if (caseItem.ageMonths != null) ...[
                              _Divider(),
                              _InfoRow(
                                label: 'Age',
                                value: '${caseItem.ageMonths} months',
                                icon: Icons.calendar_today_outlined,
                                iconColor: _amberAccent,
                                iconBg: _amberSurface,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Disease information
                        _DetailSection(
                          icon: Icons.health_and_safety_outlined,
                          iconColor: _forestGreen,
                          iconBg: _forestGreenSurface,
                          title: 'Disease information',
                          children: [
                            if (caseItem.diseaseLabel != null)
                              Column(
                                children: [
                                  _InfoRow(
                                    label: 'Name',
                                    value: caseItem.diseaseLabel!.name,
                                    icon: Icons.health_and_safety_outlined,
                                    iconColor: _forestGreen,
                                    iconBg: _forestGreenSurface,
                                  ),
                                  _Divider(),
                                  _InfoRow(
                                    label: 'Code',
                                    value: caseItem.diseaseLabel!.code,
                                    icon: Icons.api_outlined,
                                    iconColor: _forestGreen,
                                    iconBg: _forestGreenSurface,
                                  ),
                                  _Divider(),
                                  _InfoRow(
                                    label: 'Animal Type',
                                    value: caseItem.diseaseLabel!.animalType,
                                    icon: Icons.pets_outlined,
                                    iconColor: _forestGreen,
                                    iconBg: _forestGreenSurface,
                                  ),
                                ],
                              )
                            else
                              _InfoRow(
                                label: 'Disease',
                                value: 'N/A',
                                icon: Icons.health_and_safety_outlined,
                                iconColor: _forestGreen,
                                iconBg: _forestGreenSurface,
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Clinical information
                        _DetailSection(
                          icon: Icons.medical_information_outlined,
                          iconColor: _redAccent,
                          iconBg: _redSurface,
                          title: 'Clinical information',
                          children: [
                            _InfoBlock(
                              label: 'Symptoms',
                              value: caseItem.symptoms,
                            ),
                            if (caseItem.diagnosis != null) ...[
                              _Divider(),
                              _InfoBlock(
                                label: 'Diagnosis',
                                value: caseItem.diagnosis!,
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 14),

                        // Additional information
                        if (caseItem.farmLocation != null ||
                            caseItem.notes != null) ...[
                          _DetailSection(
                            icon: Icons.location_on_outlined,
                            iconColor: _blueAccent,
                            iconBg: _blueSurface,
                            title: 'Additional information',
                            children: [
                              if (caseItem.farmLocation != null)
                                _InfoRow(
                                  label: 'Farm Location',
                                  value: caseItem.farmLocation!,
                                  icon: Icons.location_on_outlined,
                                  iconColor: _blueAccent,
                                  iconBg: _blueSurface,
                                ),
                              if (caseItem.farmLocation != null &&
                                  caseItem.notes != null)
                                _Divider(),
                              if (caseItem.notes != null)
                                _InfoBlock(
                                  label: 'Notes',
                                  value: caseItem.notes!,
                                ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],

                        // Timeline
                        _DetailSection(
                          icon: Icons.schedule_outlined,
                          iconColor: _purpleAccent,
                          iconBg: _purpleSurface,
                          title: 'Timeline',
                          children: [
                            _TimelineRow(
                              label: 'Submitted',
                              value: _formatDateTime(caseItem.createdAt),
                              isFirst: true,
                              dotColor: _forestGreen,
                            ),
                            _TimelineRow(
                              label: 'Last updated',
                              value: _formatDateTime(caseItem.updatedAt),
                              isFirst: false,
                              dotColor: _purpleAccent,
                            ),
                          ],
                        ),
                      ],
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

  // ── Image upload section (edit mode) ──────────────────────────────────────────

  Widget _buildImageUploadSection() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Upload header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _amberSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 17,
                        color: _amberAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Upload or update images',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
                if (_selectedImages.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _amberSurface,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_selectedImages.length} selected',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: _amberAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main upload area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                // Primary upload button (only show if no images selected)
                if (_selectedImages.isEmpty) ...[
                  GestureDetector(
                    onTap: _pickImageFromGallery,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 24,
                      ),
                      decoration: BoxDecoration(
                        color: _amberSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _amberAccent,
                          width: 1.5,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.add_photo_alternate_outlined,
                              size: 28,
                              color: _amberAccent,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Add or replace images',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: _textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Tap to browse gallery or take photo',
                            style: TextStyle(fontSize: 12, color: _textMuted),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ] else ...[
                  // Display selected images grid
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _selectedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: _borderColor, width: 0.5),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(9),
                                child: Image.file(
                                  _selectedImages[index],
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: _warmBg,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      size: 20,
                                      color: _labelColor,
                                    ),
                                  ),
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
                                      color: _redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 14,
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
                  const SizedBox(height: 12),
                ],

                // Quick action buttons
                Row(
                  children: [
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.photo_library_outlined,
                        label: 'Gallery',
                        onTap: _pickImageFromGallery,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _QuickActionButton(
                        icon: Icons.camera_alt_outlined,
                        label: 'Camera',
                        onTap: _pickImageFromCamera,
                      ),
                    ),
                  ],
                ),

                // Save/Upload button (only show if images selected)
                if (_selectedImages.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveImagesToCase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _forestGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Upload Images',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  // ── Image gallery ─────────────────────────────────────────────────────────────

  Widget _buildImageGallery(List<CaseImage>? images) {
    // Safety check
    if (images == null || images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Gallery header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: _purpleSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        size: 17,
                        color: _purpleAccent,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Case images',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _textPrimary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _purpleSurface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_currentImageIndex + 1} / ${images.length}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: _purpleAccent,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Main image carousel
          SizedBox(
            height: 260,
            child: PageView.builder(
              controller: _imagePageController,
              onPageChanged: (i) => setState(() => _currentImageIndex = i),
              itemCount: images.length,
              itemBuilder: (context, index) {
                final img = images[index];
                final imagePath = _getImagePath(img);

                // Skip if no valid image path
                if (imagePath.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _warmBg,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: _textMuted,
                        ),
                      ),
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: CaseImageWidget(
                    imagePath: imagePath,
                    width: double.infinity,
                    height: 260,
                    fit: BoxFit.cover,
                    borderRadius: BorderRadius.circular(14),
                    onError: (error, stackTrace) {
                      print(
                        '[ViewCaseDetailScreen] Failed to load image $imagePath: $error',
                      );
                    },
                    onSuccess: () {
                      print(
                        '[ViewCaseDetailScreen] Successfully loaded image $imagePath',
                      );
                    },
                  ),
                );
              },
            ),
          ),

          // Dot indicators
          if (images.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(images.length, (i) {
                  final active = i == _currentImageIndex;
                  return GestureDetector(
                    onTap: () => _imagePageController.animateToPage(
                      i,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                    ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: active ? 20 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: active ? _forestGreen : _borderColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
            )
          else
            const SizedBox(height: 14),

          // Thumbnail strip
          if (images.length > 1)
            SizedBox(
              height: 74,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  final selected = index == _currentImageIndex;
                  final imagePath = _getImagePath(images[index]);

                  // Skip if no valid image path
                  if (imagePath.isEmpty) {
                    return Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? _forestGreen : _borderColor,
                          width: selected ? 2 : 0.5,
                        ),
                        color: _warmBg,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported,
                          size: 16,
                          color: _textMuted,
                        ),
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () => _imagePageController.animateToPage(
                      index,
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeInOut,
                    ),
                    child: Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: selected ? _forestGreen : _borderColor,
                          width: selected ? 2 : 0.5,
                        ),
                      ),
                      child: SimpleNetworkImage(
                        imagePath: imagePath,
                        width: 60,
                        height: 60,
                      ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.day}/${dt.month}/${dt.year} at $h:$m';
  }

  /// Get localPath from image for serving via ngrok/backend
  /// Fallback: uses fileName to reconstruct path as 'uploads/cases/{fileName}'
  /// Returns empty string if no valid path available
  String _getImagePath(CaseImage? image) {
    if (image == null) {
      print('[ViewCaseDetailScreen] ✗ CaseImage is null');
      return '';
    }

    print('[ViewCaseDetailScreen] ========== IMAGE DEBUG ==========');
    print('[ViewCaseDetailScreen] id: ${image.id}');
    print('[ViewCaseDetailScreen] fileName: ${image.fileName}');
    print('[ViewCaseDetailScreen] localPath: ${image.localPath}');
    print(
      '[ViewCaseDetailScreen] localPath is null: ${image.localPath == null}',
    );
    print(
      '[ViewCaseDetailScreen] localPath isEmpty: ${image.localPath?.isEmpty ?? "null"}',
    );
    print('[ViewCaseDetailScreen] ===============================');

    // Try to use localPath if available
    if (image.localPath != null && image.localPath!.isNotEmpty) {
      print('[ViewCaseDetailScreen] ✓ Using localPath: ${image.localPath}');
      return image.localPath!;
    }

    // Fallback: construct from fileName
    if (image.fileName.isNotEmpty) {
      final fallbackPath = 'uploads/cases/${image.fileName}';
      print(
        '[ViewCaseDetailScreen] ⚠ localPath empty, using fallback: $fallbackPath',
      );
      return fallbackPath;
    }

    print('[ViewCaseDetailScreen] ✗ No localPath or fileName available');
    return '';
  }

  /// Log complete case response from backend
  void _logCaseResponse(Case caseItem) {
    print('\n');
    print('╔════════════════════════════════════════════════════════════════╗');
    print('║          BACKEND RESPONSE - CASE DETAIL                       ║');
    print('╚════════════════════════════════════════════════════════════════╝');

    // Case metadata
    print('[ViewCaseDetailScreen] Case ID: ${caseItem.id}');
    print('[ViewCaseDetailScreen] User ID: ${caseItem.userId}');
    print(
      '[ViewCaseDetailScreen] Disease Label ID: ${caseItem.diseaseLabelId}',
    );
    print('[ViewCaseDetailScreen]');

    // Animal details
    print('[ViewCaseDetailScreen] ── ANIMAL DETAILS ──');
    print('[ViewCaseDetailScreen] Animal Type: ${caseItem.animalType}');
    print('[ViewCaseDetailScreen] Breed: ${caseItem.breed ?? "N/A"}');
    print('[ViewCaseDetailScreen] Gender: ${caseItem.gender}');
    print(
      '[ViewCaseDetailScreen] Age (months): ${caseItem.ageMonths ?? "N/A"}',
    );
    print('[ViewCaseDetailScreen]');

    // Clinical details
    print('[ViewCaseDetailScreen] ── CLINICAL DETAILS ──');
    print('[ViewCaseDetailScreen] Symptoms: ${caseItem.symptoms}');
    print('[ViewCaseDetailScreen] Diagnosis: ${caseItem.diagnosis ?? "N/A"}');
    print('[ViewCaseDetailScreen] Severity: ${caseItem.severity}');
    print('[ViewCaseDetailScreen]');

    // Case status
    print('[ViewCaseDetailScreen] ── CASE STATUS ──');
    print('[ViewCaseDetailScreen] Status: ${caseItem.status}');
    print('[ViewCaseDetailScreen] Created: ${caseItem.createdAt}');
    print('[ViewCaseDetailScreen] Updated: ${caseItem.updatedAt}');
    print('[ViewCaseDetailScreen]');

    // Farm location & notes
    print('[ViewCaseDetailScreen] ── ADDITIONAL INFO ──');
    print(
      '[ViewCaseDetailScreen] Farm Location: ${caseItem.farmLocation ?? "N/A"}',
    );
    print('[ViewCaseDetailScreen] Notes: ${caseItem.notes ?? "N/A"}');
    print('[ViewCaseDetailScreen]');

    // User details
    if (caseItem.user != null) {
      print('[ViewCaseDetailScreen] ── USER INFO ──');
      print('[ViewCaseDetailScreen] Name: ${caseItem.user!.fullName}');
      print('[ViewCaseDetailScreen] Email: ${caseItem.user!.email}');
      print('[ViewCaseDetailScreen] Role: ${caseItem.user!.role}');
      print('[ViewCaseDetailScreen]');
    }

    // Disease label details
    if (caseItem.diseaseLabel != null) {
      print('[ViewCaseDetailScreen] ── DISEASE LABEL ──');
      print('[ViewCaseDetailScreen] Code: ${caseItem.diseaseLabel!.code}');
      print('[ViewCaseDetailScreen] Name: ${caseItem.diseaseLabel!.name}');
      print(
        '[ViewCaseDetailScreen] Animal Type: ${caseItem.diseaseLabel!.animalType}',
      );
      print('[ViewCaseDetailScreen]');
    }

    // Images details
    print('[ViewCaseDetailScreen] ── IMAGES ──');
    if (caseItem.images != null && caseItem.images!.isNotEmpty) {
      print('[ViewCaseDetailScreen] Total Images: ${caseItem.images!.length}');
      for (int i = 0; i < caseItem.images!.length; i++) {
        final image = caseItem.images![i];
        print('[ViewCaseDetailScreen]');
        print('[ViewCaseDetailScreen] Image ${i + 1}:');
        print('[ViewCaseDetailScreen]   ID: ${image.id}');
        print('[ViewCaseDetailScreen]   File Name: ${image.fileName}');
        print(
          '[ViewCaseDetailScreen]   Local Path: ${image.localPath ?? "null"}',
        );
        print('[ViewCaseDetailScreen]   MIME Type: ${image.mimeType}');
        print(
          '[ViewCaseDetailScreen]   File Size: ${image.fileSize} bytes (${(image.fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
        );
        print('[ViewCaseDetailScreen]   Created: ${image.createdAt}');
        print('[ViewCaseDetailScreen]   Image URL: ${image.imageUrl}');
      }
    } else {
      print('[ViewCaseDetailScreen] No images available');
    }

    print('[ViewCaseDetailScreen]');
    print('╔════════════════════════════════════════════════════════════════╗');
    print('║                    END OF RESPONSE LOG                         ║');
    print('╚════════════════════════════════════════════════════════════════╝');
    print('\n');
  }

  // ── Image picker methods ───────────────────────────────────────────────────

  Future<void> _pickImageFromGallery() async {
    try {
      print(
        '[ViewCaseDetailScreen] ========== GALLERY PICKER START ==========',
      );
      print('[ViewCaseDetailScreen] Case ID: ${widget.caseId}');
      print(
        '[ViewCaseDetailScreen] Current selected images: ${_selectedImages.length}',
      );

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('[ViewCaseDetailScreen] ✓ Image picked from gallery');
        print('[ViewCaseDetailScreen]   Path: ${pickedFile.path}');
        print('[ViewCaseDetailScreen]   Name: ${pickedFile.name}');

        final file = File(pickedFile.path);
        final exists = await file.exists();
        print('[ViewCaseDetailScreen]   File exists: $exists');

        if (exists) {
          final fileSize = await file.length();
          print(
            '[ViewCaseDetailScreen]   File size: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
          );
        }

        setState(() {
          _selectedImages.add(file);
          print('[ViewCaseDetailScreen] ✓ Image added to list');
          print(
            '[ViewCaseDetailScreen]   Total selected: ${_selectedImages.length}',
          );
        });
      } else {
        print('[ViewCaseDetailScreen] ℹ User cancelled gallery picker');
      }

      print('[ViewCaseDetailScreen] ========== GALLERY PICKER END ==========');
    } catch (e, stackTrace) {
      print('[ViewCaseDetailScreen] ✗ Gallery picker error: $e');
      print('[ViewCaseDetailScreen] Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: _redAccent,
          ),
        );
      }
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      print('[ViewCaseDetailScreen] ========== CAMERA PICKER START ==========');
      print('[ViewCaseDetailScreen] Case ID: ${widget.caseId}');
      print(
        '[ViewCaseDetailScreen] Current selected images: ${_selectedImages.length}',
      );

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        print('[ViewCaseDetailScreen] ✓ Photo captured from camera');
        print('[ViewCaseDetailScreen]   Path: ${pickedFile.path}');
        print('[ViewCaseDetailScreen]   Name: ${pickedFile.name}');

        final file = File(pickedFile.path);
        final exists = await file.exists();
        print('[ViewCaseDetailScreen]   File exists: $exists');

        if (exists) {
          final fileSize = await file.length();
          print(
            '[ViewCaseDetailScreen]   File size: $fileSize bytes (${(fileSize / 1024 / 1024).toStringAsFixed(2)} MB)',
          );
        }

        setState(() {
          _selectedImages.add(file);
          print('[ViewCaseDetailScreen] ✓ Image added to list');
          print(
            '[ViewCaseDetailScreen]   Total selected: ${_selectedImages.length}',
          );
        });
      } else {
        print('[ViewCaseDetailScreen] ℹ User cancelled camera picker');
      }

      print('[ViewCaseDetailScreen] ========== CAMERA PICKER END ==========');
    } catch (e, stackTrace) {
      print('[ViewCaseDetailScreen] ✗ Camera picker error: $e');
      print('[ViewCaseDetailScreen] Stack trace: $stackTrace');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error taking photo: $e'),
            backgroundColor: _redAccent,
          ),
        );
      }
    }
  }

  Future<void> _saveImagesToCase() async {
    print('[ViewCaseDetailScreen] ========== UPLOAD START ==========');
    print('[ViewCaseDetailScreen] Case ID: ${widget.caseId}');
    print(
      '[ViewCaseDetailScreen] Selected images count: ${_selectedImages.length}',
    );

    if (_selectedImages.isEmpty) {
      print('[ViewCaseDetailScreen] ✗ No images selected - aborting upload');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one image'),
          backgroundColor: _redAccent,
        ),
      );
      return;
    }

    // Log image details
    for (int i = 0; i < _selectedImages.length; i++) {
      final file = _selectedImages[i];
      try {
        final size = await file.length();
        print('[ViewCaseDetailScreen] Image ${i + 1}:');
        print('[ViewCaseDetailScreen]   Path: ${file.path}');
        print(
          '[ViewCaseDetailScreen]   Size: $size bytes (${(size / 1024 / 1024).toStringAsFixed(2)} MB)',
        );
        print('[ViewCaseDetailScreen]   Exists: ${await file.exists()}');
      } catch (e) {
        print('[ViewCaseDetailScreen] Error reading image ${i + 1}: $e');
      }
    }

    try {
      // Show loading indicator
      if (!mounted) {
        print('[ViewCaseDetailScreen] ✗ Widget not mounted - aborting');
        return;
      }

      print('[ViewCaseDetailScreen] ℹ Showing loading snackbar');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Uploading ${_selectedImages.length} image(s)...'),
          backgroundColor: _forestGreen,
          duration: const Duration(seconds: 1),
        ),
      );

      // Call the CaseService to upload images
      print('[ViewCaseDetailScreen] ℹ Calling CaseService.uploadCaseImages()');
      print(
        '[ViewCaseDetailScreen]   Backend URL: ${AppConfig.backendBaseUrl}',
      );

      final uploadedImages = await CaseService.uploadCaseImages(
        widget.caseId,
        _selectedImages,
      );

      print('[ViewCaseDetailScreen] ✓ Upload successful!');
      print(
        '[ViewCaseDetailScreen]   Uploaded images count: ${uploadedImages.length}',
      );

      if (!mounted) {
        print(
          '[ViewCaseDetailScreen] ⚠ Widget not mounted after upload - skipping UI updates',
        );
        return;
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Successfully uploaded ${uploadedImages.length} image(s)',
          ),
          backgroundColor: _forestGreen,
          duration: const Duration(seconds: 2),
        ),
      );

      print('[ViewCaseDetailScreen] ℹ Clearing selected images');
      // Clear the selected images
      setState(() {
        _selectedImages.clear();
      });

      // Refresh the case details to show the new images
      print('[ViewCaseDetailScreen] ℹ Refreshing case details');
      await context.read<CaseProvider>().getCaseById(widget.caseId);
      print('[ViewCaseDetailScreen] ✓ Case details refreshed');

      // Exit edit mode
      print('[ViewCaseDetailScreen] ℹ Exiting edit mode');
      setState(() {
        _isEditMode = false;
      });

      print('[ViewCaseDetailScreen] ✓ Edit mode exited');
      print('[ViewCaseDetailScreen] ========== UPLOAD SUCCESS ==========');
    } catch (e, stackTrace) {
      print('[ViewCaseDetailScreen] ✗ Upload failed with exception!');
      print('[ViewCaseDetailScreen] Error type: ${e.runtimeType}');
      print('[ViewCaseDetailScreen] Error message: $e');
      print('[ViewCaseDetailScreen] Stack trace:\n$stackTrace');

      if (!mounted) {
        print(
          '[ViewCaseDetailScreen] ⚠ Widget not mounted - cannot show error message',
        );
        return;
      }

      String errorMessage = 'Failed to upload images';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Upload timeout. Please check your connection.';
      } else if (e.toString().contains('No images')) {
        errorMessage = 'No images selected';
      } else if (e.toString().contains('token')) {
        errorMessage = 'Authentication failed. Please login again.';
      } else if (e.toString().contains('SocketException')) {
        errorMessage = 'Network error. Check your internet connection.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Unauthorized. Please login again.';
      } else if (e.toString().contains('403')) {
        errorMessage = 'Access denied. Check permissions.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Case not found.';
      } else if (e.toString().contains('413')) {
        errorMessage = 'File too large. Max 10MB per image.';
      } else if (e.toString().contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }

      print('[ViewCaseDetailScreen] Error message shown: $errorMessage');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: _redAccent,
          duration: const Duration(seconds: 3),
        ),
      );

      print('[ViewCaseDetailScreen] ========== UPLOAD FAILED ==========');
    }
  }
}

// ─── Detail Header ────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.animalType,
    required this.statusLabel,
    required this.statusColor,
    required this.statusSurface,
    required this.onBack,
    required this.isEditMode,
    required this.onToggleEdit,
  });

  final String? animalType;
  final String? statusLabel;
  final Color statusColor;
  final Color statusSurface;
  final VoidCallback onBack;
  final bool isEditMode;
  final VoidCallback onToggleEdit;

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
                // Back + status badge & edit button row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
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
                    Row(
                      children: [
                        if (statusLabel != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusSurface,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel!.toUpperCase(),
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                                color: statusColor,
                              ),
                            ),
                          ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: onToggleEdit,
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                isEditMode ? 0.25 : 0.1,
                              ),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(
                                  isEditMode ? 0.3 : 0.15,
                                ),
                                width: 0.5,
                              ),
                            ),
                            child: Icon(
                              isEditMode
                                  ? Icons.check_rounded
                                  : Icons.edit_rounded,
                              size: 18,
                              color: isEditMode
                                  ? const Color(0xFFFFF9E1)
                                  : const Color(0xFFB0C8B8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Icon + title
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
                        Icons.description_outlined,
                        color: Color(0xFFA8D4B8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            animalType ?? 'Case details',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFFE8F0EB),
                              height: 1.1,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          const Text(
                            'Disease case report',
                            style: TextStyle(
                              fontSize: 12,
                              color: _forestGreenMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
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

// ─── Summary chip (status / severity) ────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.iconColor,
    required this.iconBg,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 17, color: iconColor),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: _labelColor,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: _textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Detail section card ──────────────────────────────────────────────────────

class _DetailSection extends StatelessWidget {
  const _DetailSection({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.children,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final List<Widget> children;

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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, size: 18, color: iconColor),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: _textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(height: 0.5, color: _borderColor),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Info row (icon + label + value) ─────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _labelColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Info block (multiline text field) ───────────────────────────────────────

class _InfoBlock extends StatelessWidget {
  const _InfoBlock({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: _labelColor,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _warmBg,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _borderColor, width: 0.5),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              color: _textPrimary,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Timeline row ─────────────────────────────────────────────────────────────

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({
    required this.label,
    required this.value,
    required this.isFirst,
    required this.dotColor,
  });

  final String label;
  final String value;
  final bool isFirst;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isFirst ? 14 : 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                ),
              ),
              if (isFirst)
                Container(width: 1.5, height: 30, color: _borderColor),
            ],
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                  color: _labelColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Shared divider ───────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 0.5,
      color: _borderColor,
      margin: const EdgeInsets.symmetric(vertical: 12),
    );
  }
}

// ─── Quick action button ──────────────────────────────────────────────────────

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
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
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: _amberSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _amberAccent, width: 1),
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: _amberAccent),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _amberAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
