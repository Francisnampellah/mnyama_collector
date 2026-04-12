import 'package:flutter/material.dart';
import 'dart:io';
import '../models/case_models.dart';
import '../services/case_service.dart';

class CaseProvider extends ChangeNotifier {
  List<DiseaseLabel> _diseaseLabels = [];
  List<Case> _cases = [];
  Case? _currentCase;

  bool _isLoadingDiseases = false;
  bool _isLoadingCases = false;
  bool _isSubmitting = false;

  String? _error;

  // Getters
  List<DiseaseLabel> get diseaseLabels => _diseaseLabels;
  List<Case> get cases => _cases;
  Case? get currentCase => _currentCase;

  bool get isLoadingDiseases => _isLoadingDiseases;
  bool get isLoadingCases => _isLoadingCases;
  bool get isSubmitting => _isSubmitting;

  String? get error => _error;

  // Fetch disease labels
  Future<void> fetchDiseaseLabels() async {
    _isLoadingDiseases = true;
    _error = null;
    notifyListeners();

    try {
      print('Fetching disease labels...');
      _diseaseLabels = await CaseService.fetchDiseaseLabels();
      print(
        'Disease labels fetched successfully: ${_diseaseLabels.length} diseases',
      );
      _error = null;
    } catch (e) {
      print('Error fetching disease labels: $e');
      _error = e.toString();
    } finally {
      _isLoadingDiseases = false;
      notifyListeners();
    }
  }

  // Fetch all cases
  Future<void> fetchCases({int page = 1, int limit = 10}) async {
    _isLoadingCases = true;
    _error = null;
    notifyListeners();

    try {
      _cases = await CaseService.fetchCases(page: page, limit: limit);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingCases = false;
      notifyListeners();
    }
  }

  // Get case by ID
  Future<void> getCaseById(String caseId) async {
    _isLoadingCases = true;
    _error = null;
    notifyListeners();

    try {
      _currentCase = await CaseService.getCaseById(caseId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingCases = false;
      notifyListeners();
    }
  }

  // Submit a new case
  Future<Case> submitCase(CreateCaseRequest request) async {
    print('[CaseProvider] ========== BEGIN CASE SUBMISSION ==========');
    print('[CaseProvider] Setting isSubmitting = true');
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      print('[CaseProvider] Calling CaseService.createCase()...');
      final newCase = await CaseService.createCase(request);

      print('[CaseProvider] ✓ Case created successfully');
      print('[CaseProvider] Case details:');
      print('[CaseProvider]   - ID: ${newCase.id}');
      print('[CaseProvider]   - Status: ${newCase.status}');
      print('[CaseProvider]   - Created at: ${newCase.createdAt}');

      _currentCase = newCase;
      _error = null;
      return newCase;
    } catch (e, stackTrace) {
      print('[CaseProvider] ✗ Case submission failed: $e');
      print('[CaseProvider] Stack trace: $stackTrace');
      _error = e.toString();
      rethrow;
    } finally {
      print('[CaseProvider] Setting isSubmitting = false');
      _isSubmitting = false;
      notifyListeners();
      print('[CaseProvider] ========== END CASE SUBMISSION ==========');
    }
  }

  // Upload images for a case
  Future<void> uploadCaseImages(String caseId, List<File> images) async {
    print('[CaseProvider] ========== BEGIN IMAGE UPLOAD ==========');
    print('[CaseProvider] Setting isSubmitting = true');
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      print(
        '[CaseProvider] Uploading ${images.length} images for case: $caseId',
      );
      for (int i = 0; i < images.length; i++) {
        final fileSize = await images[i].length();
        print(
          '[CaseProvider]   Image ${i + 1}/${images.length}: ${images[i].path} ($fileSize bytes)',
        );
      }

      print('[CaseProvider] Calling CaseService.uploadCaseImages()...');
      await CaseService.uploadCaseImages(caseId, images);

      print('[CaseProvider] ✓ All images uploaded successfully');
      _error = null;
    } catch (e, stackTrace) {
      print('[CaseProvider] ✗ Image upload failed: $e');
      print('[CaseProvider] Stack trace: $stackTrace');
      _error = e.toString();
      rethrow;
    } finally {
      print('[CaseProvider] Setting isSubmitting = false');
      _isSubmitting = false;
      notifyListeners();
      print('[CaseProvider] ========== END IMAGE UPLOAD ==========');
    }
  }

  // Create case with images in one operation
  Future<void> createCaseWithImages(
    CreateCaseRequest caseRequest,
    List<File> images,
  ) async {
    print('[CaseProvider] ========== BEGIN CREATE CASE WITH IMAGES ==========');
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      // Step 1: Create the case
      print('[CaseProvider] Step 1: Creating case...');
      final newCase = await submitCase(caseRequest);
      print(
        '[CaseProvider] Step 1 complete: Case created with ID: ${newCase.id}',
      );

      // Step 2: Upload images if any
      if (images.isNotEmpty) {
        print('[CaseProvider] Step 2: Uploading ${images.length} images...');
        await uploadCaseImages(newCase.id, images);
        print('[CaseProvider] Step 2 complete: Images uploaded successfully');
      } else {
        print('[CaseProvider] Step 2 skipped: No images to upload');
      }

      _currentCase = newCase;
      _error = null;
      print('[CaseProvider] ✓ Case with images created successfully');
    } catch (e, stackTrace) {
      print('[CaseProvider] ✗ Failed to create case with images: $e');
      print('[CaseProvider] Stack trace: $stackTrace');
      _error = 'Failed to create case: $e';
      rethrow;
    } finally {
      _isSubmitting = false;
      notifyListeners();
      print('[CaseProvider] ========== END CREATE CASE WITH IMAGES ==========');
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Reset state
  void reset() {
    _diseaseLabels = [];
    _cases = [];
    _currentCase = null;
    _isLoadingDiseases = false;
    _isLoadingCases = false;
    _isSubmitting = false;
    _error = null;
    notifyListeners();
  }
}
