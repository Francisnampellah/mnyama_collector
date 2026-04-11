import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/case_models.dart';
import '../providers/case_provider.dart';

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
                        if (caseItem.images != null &&
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
                            _InfoRow(
                              label: 'Disease ID',
                              value: caseItem.diseaseLabelId,
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

  // ── Image gallery ─────────────────────────────────────────────────────────────

  Widget _buildImageGallery(List<CaseImage> images) {
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: Image.network(
                      img.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (ctx, child, prog) {
                        if (prog == null) return child;
                        return Container(
                          color: _warmBg,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: prog.expectedTotalBytes != null
                                  ? prog.cumulativeBytesLoaded /
                                        prog.expectedTotalBytes!
                                  : null,
                              color: _forestGreen,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (_, __, ___) => Container(
                        color: _warmBg,
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              size: 40,
                              color: _labelColor,
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Failed to load',
                              style: TextStyle(fontSize: 12, color: _textMuted),
                            ),
                          ],
                        ),
                      ),
                    ),
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
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(9),
                        child: Image.network(
                          images[index].imageUrl,
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
}

// ─── Detail Header ────────────────────────────────────────────────────────────

class _DetailHeader extends StatelessWidget {
  const _DetailHeader({
    required this.animalType,
    required this.statusLabel,
    required this.statusColor,
    required this.statusSurface,
    required this.onBack,
  });

  final String? animalType;
  final String? statusLabel;
  final Color statusColor;
  final Color statusSurface;
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
                // Back + status badge row
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
