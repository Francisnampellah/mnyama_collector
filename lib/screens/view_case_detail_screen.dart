import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/case_models.dart';
import '../providers/case_provider.dart';
import '../services/image_loading_service.dart';

class ViewCaseDetailScreen extends StatefulWidget {
  final String caseId;

  const ViewCaseDetailScreen({super.key, required this.caseId});

  @override
  State<ViewCaseDetailScreen> createState() => _ViewCaseDetailScreenState();
}

class _ViewCaseDetailScreenState extends State<ViewCaseDetailScreen> {
  late PageController _imagePageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _imagePageController = PageController();
    _loadCaseDetails();
  }

  Future<void> _loadCaseDetails() async {
    await context.read<CaseProvider>().getCaseById(widget.caseId);

    // Test image URLs after case loads
    if (mounted) {
      final caseData = context.read<CaseProvider>().currentCase;
      if (caseData?.images != null && caseData!.images!.isNotEmpty) {
        _testImageUrls(caseData.images!);
      }
    }
  }

  Future<void> _testImageUrls(List<CaseImage> images) async {
    print('[ViewCaseDetail] ========== IMAGE URL DIAGNOSTICS ==========');
    print('[ViewCaseDetail] Total images: ${images.length}');

    final imageService = ImageLoadingService();

    for (var i = 0; i < images.length; i++) {
      final image = images[i];
      print('[ViewCaseDetail] ');
      print('[ViewCaseDetail] Image ${i + 1}/${images.length}:');
      print('[ViewCaseDetail] - File name: ${image.fileName}');
      print('[ViewCaseDetail] - MIME type: ${image.mimeType}');
      print('[ViewCaseDetail] - File size: ${image.fileSize} bytes');
      print('[ViewCaseDetail] - URL: ${image.imageUrl}');

      // Test if URL is accessible
      final isAccessible = await imageService.isUrlAccessible(image.imageUrl);
      print('[ViewCaseDetail] - URL accessible: $isAccessible');

      // Get file size from server
      final serverFileSize = await imageService.getImageSize(image.imageUrl);
      print(
        '[ViewCaseDetail] - Server file size: ${serverFileSize ?? "N/A"} bytes',
      );
    }

    print('[ViewCaseDetail] ========== END DIAGNOSTICS ==========');
  }

  @override
  void dispose() {
    _imagePageController.dispose();
    super.dispose();
  }

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
    return Scaffold(
      appBar: AppBar(title: const Text('Case Details'), elevation: 0),
      body: Consumer<CaseProvider>(
        builder: (context, caseProvider, _) {
          if (caseProvider.isLoadingCases) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading case details...'),
                ],
              ),
            );
          }

          if (caseProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load case details',
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
                      onPressed: _loadCaseDetails,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final caseItem = caseProvider.currentCase;
          if (caseItem == null) {
            return const Center(child: Text('No case found'));
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Case Header Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and Severity Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                caseItem.status,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getStatusColor(caseItem.status),
                              ),
                            ),
                            child: Text(
                              caseItem.status.name,
                              style: TextStyle(
                                color: _getStatusColor(caseItem.status),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _getSeverityColor(
                                caseItem.severity,
                              ).withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _getSeverityColor(caseItem.severity),
                              ),
                            ),
                            child: Text(
                              caseItem.severity.name,
                              style: TextStyle(
                                color: _getSeverityColor(caseItem.severity),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Case ID
                      Text(
                        'Case ID',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        caseItem.id,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Case Images
                if (caseItem.images != null && caseItem.images!.isNotEmpty)
                  _CaseImagesSection(
                    images: caseItem.images!,
                    pageController: _imagePageController,
                    onPageChanged: (index) {
                      setState(() => _currentImageIndex = index);
                    },
                    currentIndex: _currentImageIndex,
                  ),

                // Animal Information
                _DetailSection(
                  title: 'Animal Information',
                  children: [
                    _DetailRow(
                      label: 'Animal Type',
                      value: caseItem.animalType,
                    ),
                    if (caseItem.breed != null)
                      _DetailRow(label: 'Breed', value: caseItem.breed!),
                    _DetailRow(label: 'Gender', value: caseItem.gender.name),
                    if (caseItem.ageMonths != null)
                      _DetailRow(
                        label: 'Age',
                        value: '${caseItem.ageMonths} months',
                      ),
                  ],
                ),

                // Clinical Information
                _DetailSection(
                  title: 'Clinical Information',
                  children: [
                    _DetailColumn(label: 'Symptoms', value: caseItem.symptoms),
                    if (caseItem.diagnosis != null)
                      _DetailColumn(
                        label: 'Diagnosis',
                        value: caseItem.diagnosis!,
                      ),
                  ],
                ),

                // Additional Information
                _DetailSection(
                  title: 'Additional Information',
                  children: [
                    if (caseItem.farmLocation != null)
                      _DetailRow(
                        label: 'Farm Location',
                        value: caseItem.farmLocation!,
                      ),
                    if (caseItem.notes != null)
                      _DetailColumn(label: 'Notes', value: caseItem.notes!),
                  ],
                ),

                // Timeline
                _DetailSection(
                  title: 'Timeline',
                  children: [
                    _DetailRow(
                      label: 'Created',
                      value: _formatDateTime(caseItem.createdAt),
                    ),
                    _DetailRow(
                      label: 'Last Updated',
                      value: _formatDateTime(caseItem.updatedAt),
                    ),
                  ],
                ),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _CaseImagesSection extends StatelessWidget {
  final List<CaseImage> images;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final int currentIndex;

  const _CaseImagesSection({
    required this.images,
    required this.pageController,
    required this.onPageChanged,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Case Images (${images.length})',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),

          // Image Carousel
          SizedBox(
            height: 300,
            child: PageView.builder(
              controller: pageController,
              onPageChanged: onPageChanged,
              itemCount: images.length,
              itemBuilder: (context, index) {
                final image = images[index];
                print(
                  '[ViewCaseDetail] Loading image ${index + 1}/${images.length}',
                );
                print('[ViewCaseDetail] Image URL: ${image.imageUrl}');
                print('[ViewCaseDetail] File name: ${image.fileName}');

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      image.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;

                        final percent =
                            loadingProgress.expectedTotalBytes != null
                            ? (loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!)
                            : 0.0;

                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            // Animated shimmer background
                            _AnimatedPlaceholder(percent: percent),

                            // Progress info overlay
                            Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Circular progress indicator
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: CircularProgressIndicator(
                                          value: percent,
                                          strokeWidth: 4,
                                          backgroundColor: Colors.grey[200],
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Theme.of(context).primaryColor,
                                              ),
                                        ),
                                      ),
                                      // Percentage text
                                      Text(
                                        '${(percent * 100).toStringAsFixed(0)}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  // Size info
                                  if (loadingProgress.expectedTotalBytes !=
                                      null)
                                    Text(
                                      '${(loadingProgress.cumulativeBytesLoaded / 1024).toStringAsFixed(1)} / ${(loadingProgress.expectedTotalBytes! / 1024).toStringAsFixed(1)} KB',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    )
                                  else
                                    Text(
                                      '${(loadingProgress.cumulativeBytesLoaded / 1024).toStringAsFixed(1)} KB',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Downloading...',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        print('[ViewCaseDetail] Image.network error: $error');
                        print('[ViewCaseDetail] Stack trace: $stackTrace');
                        return Container(
                          color: Colors.grey[300],
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_not_supported,
                                size: 48,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Failed to load image',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Error: $error',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Image Info
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Image ${currentIndex + 1} of ${images.length}',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  images[currentIndex].fileName,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  '${(images[currentIndex].fileSize / 1024).toStringAsFixed(2)} KB',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          // Image Indicators
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              images.length,
              (index) => GestureDetector(
                onTap: () => pageController.jumpToPage(index),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == currentIndex
                        ? Theme.of(context).primaryColor
                        : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _DetailSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children
                  .expand(
                    (child) => [
                      child,
                      if (child != children.last)
                        Divider(color: Colors.grey[300], height: 16),
                    ],
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _DetailColumn extends StatelessWidget {
  final String label;
  final String value;

  const _DetailColumn({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

// Animated placeholder with shimmer effect
class _AnimatedPlaceholder extends StatefulWidget {
  final double percent;

  const _AnimatedPlaceholder({required this.percent});

  @override
  State<_AnimatedPlaceholder> createState() => _AnimatedPlaceholderState();
}

class _AnimatedPlaceholderState extends State<_AnimatedPlaceholder>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _shimmerAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _shimmerAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[300]!.withOpacity(_shimmerAnimation.value),
                Colors.grey[200]!.withOpacity(_shimmerAnimation.value),
                Colors.grey[300]!.withOpacity(_shimmerAnimation.value),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: ShaderMask(
            shaderCallback: (bounds) {
              return LinearGradient(
                begin: Alignment(-1.0 + widget.percent * 2, 0.0),
                end: Alignment(-0.5 + widget.percent * 2, 0.0),
                colors: [
                  Colors.transparent,
                  Colors.white.withOpacity(0.3),
                  Colors.transparent,
                ],
              ).createShader(bounds);
            },
            child: Container(color: Colors.grey[300]),
          ),
        );
      },
    );
  }
}
