import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/case_models.dart';
import '../providers/case_provider.dart';
import 'view_case_detail_screen.dart';

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

// Status color tokens
const _blueAccent = Color(0xFF185FA5);
const _blueSurface = Color(0xFFEEF4FB);
const _amberAccent = Color(0xFFBA7517);
const _amberSurface = Color(0xFFFBF4E8);
const _redAccent = Color(0xFFA32D2D);
const _redSurface = Color(0xFFFCEBEB);
// ─────────────────────────────────────────────────────────────────────────────

class ViewCasesScreen extends StatefulWidget {
  const ViewCasesScreen({super.key});

  @override
  State<ViewCasesScreen> createState() => _ViewCasesScreenState();
}

class _ViewCasesScreenState extends State<ViewCasesScreen>
    with TickerProviderStateMixin {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  CaseStatus? _selectedStatus;
  final _searchController = TextEditingController();
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeController.forward();
    _loadCases();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  Future<void> _loadCases() async {
    await context.read<CaseProvider>().fetchCases(
      page: _currentPage,
      limit: _itemsPerPage,
    );
  }

  List<Case> _getFilteredCases(List<Case> cases) {
    return cases.where((c) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          c.animalType.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.symptoms.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.id.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesStatus =
          _selectedStatus == null || c.status == _selectedStatus;
      return matchesSearch && matchesStatus;
    }).toList();
  }

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
                _CasesHeader(onBack: () => Navigator.of(context).pop()),
                Expanded(child: _buildBody(caseProvider)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(CaseProvider caseProvider) {
    // Loading state
    if (caseProvider.isLoadingCases && caseProvider.cases.isEmpty) {
      return _CenteredState(
        iconBg: _forestGreenSurface,
        icon: Icons.hourglass_top_rounded,
        iconColor: _forestGreen,
        title: 'Loading cases…',
        subtitle: null,
      );
    }

    // Error state
    if (caseProvider.error != null && caseProvider.cases.isEmpty) {
      return _CenteredState(
        iconBg: _redSurface,
        icon: Icons.error_outline_rounded,
        iconColor: _redAccent,
        title: 'Failed to load cases',
        subtitle: caseProvider.error,
        action: TextButton.icon(
          onPressed: _loadCases,
          icon: const Icon(Icons.refresh_rounded, size: 16),
          label: const Text('Retry'),
          style: TextButton.styleFrom(foregroundColor: _forestGreen),
        ),
      );
    }

    final filtered = _getFilteredCases(caseProvider.cases);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Search + filter bar
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: _cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _borderColor, width: 0.5),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Search by animal, symptoms or ID…',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: _textMuted,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _labelColor,
                        size: 20,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                color: _labelColor,
                                size: 18,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: _selectedStatus == null,
                        color: _forestGreen,
                        surface: _forestGreenSurface,
                        onTap: () => setState(() => _selectedStatus = null),
                      ),
                      const SizedBox(width: 8),
                      for (final status in CaseStatus.values) ...[
                        _FilterChip(
                          label: _statusLabel(status),
                          isSelected: _selectedStatus == status,
                          color: _statusColor(status),
                          surface: _statusSurface(status),
                          onTap: () => setState(() => _selectedStatus = status),
                        ),
                        const SizedBox(width: 8),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Results count
                if (filtered.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '${filtered.length} case${filtered.length == 1 ? '' : 's'}',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: _labelColor,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Empty state
        if (filtered.isEmpty)
          SliverFillRemaining(
            child: _CenteredState(
              iconBg: _amberSurface,
              icon: Icons.inbox_outlined,
              iconColor: _amberAccent,
              title: 'No cases found',
              subtitle: 'Try adjusting your search or filters',
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final c = filtered[index];
                  return _CaseCard(
                    caseItem: c,
                    statusColor: _statusColor(c.status),
                    statusSurface: _statusSurface(c.status),
                    statusLabel: _statusLabel(c.status),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ViewCaseDetailScreen(caseId: c.id),
                      ),
                    ),
                  );
                },
                childCount: filtered.length,
                addAutomaticKeepAlives: false,
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Header ──────────────────────────────────────────────────────────────────

class _CasesHeader extends StatelessWidget {
  const _CasesHeader({required this.onBack});
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
                        Icons.list_alt_rounded,
                        color: Color(0xFFA8D4B8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'View cases',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFFE8F0EB),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'All submitted disease cases',
                          style: TextStyle(
                            fontSize: 12,
                            color: _forestGreenMuted,
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

// ─── Filter chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.color,
    required this.surface,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color color;
  final Color surface;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : _borderColor,
            width: isSelected ? 1 : 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : _labelColor,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}

// ─── Case card ────────────────────────────────────────────────────────────────

class _CaseCard extends StatefulWidget {
  const _CaseCard({
    required this.caseItem,
    required this.statusColor,
    required this.statusSurface,
    required this.statusLabel,
    required this.onTap,
  });

  final Case caseItem;
  final Color statusColor;
  final Color statusSurface;
  final String statusLabel;
  final VoidCallback onTap;

  @override
  State<_CaseCard> createState() => _CaseCardState();
}

class _CaseCardState extends State<_CaseCard>
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
      end: 0.975,
    ).animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.caseItem;
    final shortId = c.id.length > 8 ? '${c.id.substring(0, 8)}…' : c.id;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ScaleTransition(
        scale: _scale,
        child: GestureDetector(
          onTapDown: (_) => _pressCtrl.forward(),
          onTapUp: (_) {
            _pressCtrl.reverse();
            widget.onTap();
          },
          onTapCancel: () => _pressCtrl.reverse(),
          child: Container(
            decoration: BoxDecoration(
              color: _cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _borderColor, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Card header strip
                Container(
                  decoration: BoxDecoration(
                    color: widget.statusSurface,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(17),
                      topRight: Radius.circular(17),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'ID: $shortId',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                          color: widget.statusColor,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: widget.statusColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.statusLabel.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Card body
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Animal type + arrow
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.animalType,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: _textPrimary,
                                    height: 1.1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: widget.statusSurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: widget.statusColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Meta row
                      Row(
                        children: [
                          _MetaChip(
                            icon: Icons.health_and_safety_outlined,
                            label: c.diseaseLabel?.name ?? 'Unknown disease',
                            iconColor: _forestGreen,
                          ),
                          const SizedBox(width: 10),
                          _MetaChip(
                            icon: Icons.calendar_today_outlined,
                            label: _formatDate(c.createdAt),
                            iconColor: _blueAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Symptoms
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: _warmBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: _borderColor, width: 0.5),
                        ),
                        child: Text(
                          c.symptoms,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12,
                            color: _labelColor,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Footer
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEEEDFE),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.image_outlined,
                              size: 14,
                              color: Color(0xFF534AB7),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${c.images?.length ?? 0} image${(c.images?.length ?? 0) == 1 ? '' : 's'}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: _textMuted,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) => '${d.day}/${d.month}/${d.year}';
}

// ─── Meta chip ────────────────────────────────────────────────────────────────

class _MetaChip extends StatelessWidget {
  const _MetaChip({
    required this.icon,
    required this.label,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: iconColor),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: _labelColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Centered state (loading / error / empty) ─────────────────────────────────

class _CenteredState extends StatelessWidget {
  const _CenteredState({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    this.action,
  });

  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(icon, size: 36, color: iconColor),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: _textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: _textMuted,
                  height: 1.5,
                ),
              ),
            ],
            if (action != null) ...[const SizedBox(height: 20), action!],
          ],
        ),
      ),
    );
  }
}
