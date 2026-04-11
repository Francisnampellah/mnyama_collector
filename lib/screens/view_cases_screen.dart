import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/case_models.dart';
import '../providers/case_provider.dart';
import 'view_case_detail_screen.dart';

class ViewCasesScreen extends StatefulWidget {
  const ViewCasesScreen({super.key});

  @override
  State<ViewCasesScreen> createState() => _ViewCasesScreenState();
}

class _ViewCasesScreenState extends State<ViewCasesScreen> {
  int _currentPage = 1;
  final int _itemsPerPage = 10;
  String _searchQuery = '';
  CaseStatus? _selectedStatus;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    await context.read<CaseProvider>().fetchCases(
      page: _currentPage,
      limit: _itemsPerPage,
    );
  }

  void _filterCases() {
    setState(() {});
  }

  List<Case> _getFilteredCases(List<Case> cases) {
    return cases.where((caseItem) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          caseItem.animalType.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          caseItem.symptoms.toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          caseItem.id.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus =
          _selectedStatus == null || caseItem.status == _selectedStatus;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('View Cases'), elevation: 0),
      body: Consumer<CaseProvider>(
        builder: (context, caseProvider, _) {
          if (caseProvider.isLoadingCases && caseProvider.cases.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading cases...'),
                ],
              ),
            );
          }

          if (caseProvider.error != null && caseProvider.cases.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load cases',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      caseProvider.error ?? 'Unknown error',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadCases,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final filteredCases = _getFilteredCases(caseProvider.cases);

          if (caseProvider.cases.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No cases found',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your submitted cases will appear here',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Search and Filter Section
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Search Box
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText:
                              'Search by case ID, animal type, or symptoms',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterCases();
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        onChanged: (value) {
                          _filterCases();
                          setState(() => _searchQuery = value);
                        },
                      ),
                      const SizedBox(height: 12),

                      // Status Filter
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('All'),
                              selected: _selectedStatus == null,
                              onSelected: (_) {
                                setState(() => _selectedStatus = null);
                                _filterCases();
                              },
                            ),
                            const SizedBox(width: 8),
                            ...CaseStatus.values.map((status) {
                              return FilterChip(
                                label: Text(status.name),
                                selected: _selectedStatus == status,
                                onSelected: (_) {
                                  setState(() => _selectedStatus = status);
                                  _filterCases();
                                },
                              );
                            }),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Cases List
                if (filteredCases.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      'No cases match your search',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredCases.length,
                    itemBuilder: (context, index) {
                      final caseItem = filteredCases[index];
                      return _CaseCard(
                        caseItem: caseItem,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) =>
                                  ViewCaseDetailScreen(caseId: caseItem.id),
                            ),
                          );
                        },
                      );
                    },
                  ),

                // Pagination (if needed)
                if (caseProvider.cases.length == _itemsPerPage)
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _currentPage > 1
                              ? () {
                                  setState(() => _currentPage--);
                                  _loadCases();
                                }
                              : null,
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Previous'),
                        ),
                        const SizedBox(width: 16),
                        Text('Page $_currentPage'),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _currentPage++);
                            _loadCases();
                          },
                          icon: const Icon(Icons.arrow_forward),
                          label: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CaseCard extends StatelessWidget {
  final Case caseItem;
  final VoidCallback onTap;

  const _CaseCard({required this.caseItem, required this.onTap});

  Color _getStatusColor(CaseStatus status) {
    return switch (status) {
      CaseStatus.SUBMITTED => Colors.blue,
      CaseStatus.UNDER_REVIEW => Colors.orange,
      CaseStatus.APPROVED => Colors.green,
      CaseStatus.REJECTED => Colors.red,
    };
  }

  Color _getSeverityColor(CaseSeverity severity) {
    return switch (severity) {
      CaseSeverity.MILD => Colors.green,
      CaseSeverity.MODERATE => Colors.yellow[700]!,
      CaseSeverity.SEVERE => Colors.orange,
      CaseSeverity.CRITICAL => Colors.red,
    };
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Case Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Case ID: ${caseItem.id.substring(0, 8)}...',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          caseItem.animalType,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(
                            caseItem.status,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          caseItem.status.name,
                          style: TextStyle(
                            color: _getStatusColor(caseItem.status),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(
                            caseItem.severity,
                          ).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          caseItem.severity.name,
                          style: TextStyle(
                            color: _getSeverityColor(caseItem.severity),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Case Details
              Row(
                children: [
                  Icon(Icons.pets, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Gender: ${caseItem.gender.name}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (caseItem.ageMonths != null)
                    Text(
                      'Age: ${caseItem.ageMonths} months',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Symptoms Preview
              Text(
                'Symptoms: ${caseItem.symptoms.length > 60 ? caseItem.symptoms.substring(0, 60) + '...' : caseItem.symptoms}',
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Image Count & Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.image, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${caseItem.images?.length ?? 0} images',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Text(
                    _formatDate(caseItem.createdAt),
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
