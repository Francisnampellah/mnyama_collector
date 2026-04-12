import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'dart:convert';
import 'dart:io';
import '../models/case_models.dart';
import '../models/auth_models.dart';
import '../config/app_config.dart';
import 'token_service.dart';

class CaseService {
  static const String baseUrl = AppConfig.backendBaseUrl;

  // Get all disease labels
  static Future<List<DiseaseLabel>> fetchDiseaseLabels() async {
    try {
      final token = await TokenService.getToken();

      print(
        '[CaseService] Fetching disease labels from: $baseUrl/disease-labels',
      );
      print('[CaseService] Token: ${token?.substring(0, 20)}...');

      final response = await http
          .get(
            Uri.parse('$baseUrl/disease-labels'),
            headers: {
              'Content-Type': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ApiException(
              message: 'Request timeout. Please try again.',
              statusCode: 408,
            ),
          );

      print('[CaseService] Response Status: ${response.statusCode}');
      print('[CaseService] Response Body Length: ${response.body.length}');
      print(
        '[CaseService] Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        print('[CaseService] Parsed JSON Type: ${data.runtimeType}');
        print('[CaseService] Full Response: $data');

        // Handle different response formats
        List<dynamic> diseaseList = [];

        if (data is List) {
          // Response is directly a list
          diseaseList = data;
          print('[CaseService] Response is direct list format');
        } else if (data is Map) {
          if (data['diseaseLabels'] != null && data['diseaseLabels'] is List) {
            // Response has 'diseaseLabels' wrapper (the actual format)
            diseaseList = data['diseaseLabels'] as List<dynamic>;
            print('[CaseService] Response has diseaseLabels wrapper format');
          } else if (data['data'] != null && data['data'] is List) {
            // Response has 'data' wrapper
            diseaseList = data['data'] as List<dynamic>;
            print('[CaseService] Response has data wrapper format');
          } else if (data.containsKey('diseases') && data['diseases'] is List) {
            // Try 'diseases' key
            diseaseList = data['diseases'] as List<dynamic>;
            print('[CaseService] Response has diseases key format');
          } else {
            print(
              '[CaseService] Warning: Response is Map but no recognized list key. Keys: ${data.keys.toList()}',
            );
          }
        }

        print('[CaseService] Parsed diseaseList length: ${diseaseList.length}');

        if (diseaseList.isEmpty) {
          print('[CaseService] WARNING: Disease labels list is empty!');
        }

        final result = diseaseList.map((d) {
          try {
            return DiseaseLabel.fromJson(d as Map<String, dynamic>);
          } catch (e) {
            print('[CaseService] Error parsing disease: $e');
            print('[CaseService] Disease data: $d');
            rethrow;
          }
        }).toList();

        print('[CaseService] Successfully parsed ${result.length} diseases');
        return result;
      } else {
        final errorBody = response.body;
        print('[CaseService] Error Response: $errorBody');

        try {
          final errorData = jsonDecode(errorBody);
          throw ApiException(
            message:
                errorData['message'] ??
                'Failed to fetch disease labels (${response.statusCode})',
            statusCode: response.statusCode,
            code: errorData['code'],
          );
        } catch (e) {
          throw ApiException(
            message:
                'Failed to fetch disease labels (${response.statusCode}): $errorBody',
            statusCode: response.statusCode,
          );
        }
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      print('[CaseService] Exception in fetchDiseaseLabels: $e');
      throw ApiException(message: 'An error occurred: $e');
    }
  }

  // Create a new case
  static Future<Case> createCase(CreateCaseRequest request) async {
    try {
      print('[CaseService] ========== BEGIN CREATE CASE ==========');
      print('[CaseService] Retrieving authentication token...');
      final token = await TokenService.getToken();

      if (token == null) {
        throw ApiException(message: 'Authentication token not found');
      }

      print('[CaseService] Token retrieved: ${token.substring(0, 20)}...');
      print('[CaseService] Sending case data to: $baseUrl/cases');
      print('[CaseService] Request body:');
      final requestBody = request.toJson();
      print('[CaseService] Full request JSON: $requestBody');
      print(
        '[CaseService]   - Disease Label ID: ${requestBody['diseaseLabelId']}',
      );
      print('[CaseService]   - Animal Type: ${requestBody['animalType']}');
      print('[CaseService]   - Severity: ${requestBody['severity']}');
      print('[CaseService]   - Gender: ${requestBody['gender']}');

      final response = await http
          .post(
            Uri.parse('$baseUrl/cases'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(requestBody),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ApiException(
              message: 'Request timeout. Please try again.',
              statusCode: 408,
            ),
          );

      print('[CaseService] Response status: ${response.statusCode}');
      print('[CaseService] Response body length: ${response.body.length}');
      print(
        '[CaseService] Response body (first 2000 chars): ${response.body.substring(0, response.body.length > 2000 ? 2000 : response.body.length)}',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[CaseService] Parsing response JSON...');
        final data = jsonDecode(response.body);
        print('[CaseService] Parsed data type: ${data.runtimeType}');
        print('[CaseService] Full parsed data: $data');

        // Try multiple response formats: data, case, or direct
        final caseData = data['data'] ?? data['case'] ?? data;
        print('[CaseService] Case data extracted: $caseData');
        print('[CaseService] Case data type: ${caseData.runtimeType}');

        // Log each field value and type for debugging
        if (caseData is Map) {
          print('[CaseService] Case data fields:');
          caseData.forEach((key, value) {
            print(
              '[CaseService]   - $key: $value (type: ${value.runtimeType})',
            );
          });
        }

        print('[CaseService] ✓ Case created successfully');
        print('[CaseService] Attempting to parse Case object...');

        try {
          final createdCase = Case.fromJson(caseData as Map<String, dynamic>);

          print('[CaseService] ✓ Case parsed successfully:');
          print('[CaseService]   - ID: ${createdCase.id}');
          print('[CaseService]   - Status: ${createdCase.status}');
          print('[CaseService]   - Created at: ${createdCase.createdAt}');
          print('[CaseService] ========== END CREATE CASE ==========');

          return createdCase;
        } catch (parseError, stackTrace) {
          print('[CaseService] ✗ Error parsing Case object: $parseError');
          print('[CaseService] Stack trace: $stackTrace');
          print('[CaseService] Failed caseData: $caseData');
          rethrow;
        }
      } else {
        print(
          '[CaseService] ✗ Case creation failed with status: ${response.statusCode}',
        );
        print('[CaseService] Error response: ${response.body}');

        try {
          final errorData = jsonDecode(response.body);
          print('[CaseService] Error data: $errorData');
          throw ApiException(
            message: errorData['message'] ?? 'Failed to create case',
            statusCode: response.statusCode,
            code: errorData['code'],
          );
        } catch (e) {
          print('[CaseService] Error parsing error response: $e');
          throw ApiException(
            message: 'Failed to create case (${response.statusCode})',
            statusCode: response.statusCode,
          );
        }
      }
    } on ApiException catch (e) {
      print('[CaseService] ✗ ApiException: $e');
      rethrow;
    } catch (e, stackTrace) {
      print('[CaseService] ✗ Unexpected error: $e');
      print('[CaseService] Stack trace: $stackTrace');
      throw ApiException(message: 'An error occurred: $e');
    }
  }

  /// Create a case with image attachment using multipart/form-data
  /// This sends case data + image in a single request
  ///
  /// Parameters:
  ///   - request: Case submission data (without image)
  ///   - imagePath: Optional path to image file to attach
  ///
  /// Returns: Created Case object
  ///
  /// Example:
  ///   final case = await CaseService.createCaseWithImage(
  ///     request,
  ///     imagePath: '/path/to/image.jpg'
  ///   );
  static Future<Case> createCaseWithImage(
    CreateCaseRequest request, {
    String? imagePath,
  }) async {
    try {
      print('[CaseService] ========== BEGIN CREATE CASE WITH IMAGE ==========');
      print('[CaseService] Retrieving authentication token...');

      final token = await TokenService.getToken();

      if (token == null) {
        throw ApiException(message: 'Authentication token not found');
      }

      print('[CaseService] Token retrieved: ${token.substring(0, 20)}...');
      print('[CaseService] Creating multipart request...');

      final uri = Uri.parse('$baseUrl/cases/with-image');
      final requestData = http.MultipartRequest('POST', uri);

      // Add authorization header
      requestData.headers['Authorization'] = 'Bearer $token';

      // Add case fields as form fields
      print('[CaseService] Adding form fields:');
      requestData.fields['diseaseLabelId'] = request.diseaseLabelId;
      print('[CaseService]   - diseaseLabelId: ${request.diseaseLabelId}');

      requestData.fields['animalType'] = request.animalType;
      print('[CaseService]   - animalType: ${request.animalType}');

      requestData.fields['gender'] = request.gender.toString().split('.').last;
      print('[CaseService]   - gender: ${request.gender}');

      requestData.fields['severity'] = request.severity
          .toString()
          .split('.')
          .last;
      print('[CaseService]   - severity: ${request.severity}');

      requestData.fields['symptoms'] = request.symptoms;
      print(
        '[CaseService]   - symptoms: ${request.symptoms.substring(0, 50)}...',
      );

      // Optional fields
      if (request.breed != null) {
        requestData.fields['breed'] = request.breed!;
        print('[CaseService]   - breed: ${request.breed}');
      }

      if (request.ageMonths != null) {
        requestData.fields['ageMonths'] = request.ageMonths.toString();
        print('[CaseService]   - ageMonths: ${request.ageMonths}');
      }

      if (request.diagnosis != null) {
        requestData.fields['diagnosis'] = request.diagnosis!;
        print('[CaseService]   - diagnosis: ${request.diagnosis}');
      }

      if (request.notes != null) {
        requestData.fields['notes'] = request.notes!;
        print('[CaseService]   - notes: ${request.notes}');
      }

      if (request.farmLocation != null) {
        requestData.fields['farmLocation'] = request.farmLocation!;
        print('[CaseService]   - farmLocation: ${request.farmLocation}');
      }

      // Add image file if provided
      if (imagePath != null && imagePath.isNotEmpty) {
        print('[CaseService] Adding image file...');
        final imageFile = File(imagePath);

        if (!await imageFile.exists()) {
          throw ApiException(message: 'Image file not found at: $imagePath');
        }

        final fileSize = await imageFile.length();
        print('[CaseService] Image file found: $imagePath ($fileSize bytes)');

        final fileName = imagePath.split('/').last;
        print('[CaseService] Image file name: $fileName');

        // Add file to request with field name 'image' (matches backend multer config)
        requestData.files.add(
          await http.MultipartFile.fromPath('image', imagePath),
        );

        print('[CaseService] ✓ Image file added to multipart request');
      } else {
        print('[CaseService] ℹ No image file provided');
      }

      print('[CaseService] Sending multipart request to: $uri');
      print('[CaseService] Total fields: ${requestData.fields.length}');
      print('[CaseService] Total files: ${requestData.files.length}');

      // Send the request
      final streamedResponse = await requestData.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw ApiException(
          message: 'Request timeout. Please try again.',
          statusCode: 408,
        ),
      );

      // Convert streamed response to regular response
      final response = await http.Response.fromStream(streamedResponse);

      print('[CaseService] ✓ Response received');
      print('[CaseService] Response status: ${response.statusCode}');
      print('[CaseService] Response body length: ${response.body.length}');
      print('[CaseService] Response headers: ${response.headers}');
      print(
        '[CaseService] Response body (first 2000 chars): ${response.body.substring(0, response.body.length > 2000 ? 2000 : response.body.length)}',
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('[CaseService] Parsing response body...');
        final data = jsonDecode(response.body);
        print('[CaseService] Parsed response: $data');

        // Try multiple response formats: data, case, or direct
        final caseData = data['data'] ?? data['case'] ?? data;

        print('[CaseService] Extracted caseData: $caseData');
        print('[CaseService] CaseData type: ${caseData.runtimeType}');

        // Log each field for debugging
        if (caseData is Map) {
          print('[CaseService] CaseData fields:');
          caseData.forEach((key, value) {
            print(
              '[CaseService]   - $key: $value (type: ${value.runtimeType})',
            );
          });
        }

        print('[CaseService] ✓ Case created successfully with image');

        try {
          final createdCase = Case.fromJson(caseData as Map<String, dynamic>);

          print('[CaseService] ✓ Case parsed successfully:');
          print('[CaseService]   - ID: ${createdCase.id}');
          print('[CaseService]   - Status: ${createdCase.status}');
          print(
            '[CaseService]   - Image count: ${createdCase.images?.length ?? 0}',
          );
          print(
            '[CaseService] ========== END CREATE CASE WITH IMAGE ==========',
          );

          return createdCase;
        } catch (parseError, stackTrace) {
          print('[CaseService] ✗ Error parsing Case object: $parseError');
          print('[CaseService] Stack trace: $stackTrace');
          print('[CaseService] Failed caseData: $caseData');
          rethrow;
        }
      } else {
        print(
          '[CaseService] ✗ Case creation failed with status: ${response.statusCode}',
        );
        print('[CaseService] Error response: ${response.body}');

        try {
          final errorData = jsonDecode(response.body);
          throw ApiException(
            message:
                errorData['message'] ??
                'Failed to create case (${response.statusCode})',
            statusCode: response.statusCode,
            code: errorData['code'],
          );
        } catch (e) {
          if (e is ApiException) rethrow;
          throw ApiException(
            message: 'Failed to create case (${response.statusCode})',
            statusCode: response.statusCode,
          );
        }
      }
    } on ApiException catch (e) {
      print('[CaseService] ✗ ApiException: $e');
      rethrow;
    } catch (e, stackTrace) {
      print('[CaseService] ✗ Unexpected error: $e');
      print('[CaseService] Stack trace: $stackTrace');
      throw ApiException(message: 'An error occurred: $e');
    }
  }

  // Get all cases
  static Future<List<Case>> fetchCases({int page = 1, int limit = 10}) async {
    try {
      final token = await TokenService.getToken();

      if (token == null) {
        throw ApiException(message: 'Authentication token not found');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/cases?page=$page&limit=$limit'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ApiException(
              message: 'Request timeout. Please try again.',
              statusCode: 408,
            ),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle multiple response formats
        List<dynamic> caseList = [];

        if (data is List) {
          // Direct list format
          caseList = data;
        } else if (data is Map) {
          if (data['cases'] != null && data['cases'] is List) {
            // Format: { "cases": [...] }
            caseList = data['cases'] as List<dynamic>;
          } else if (data['data'] != null && data['data'] is List) {
            // Format: { "data": [...] }
            caseList = data['data'] as List<dynamic>;
          } else if (data['items'] != null && data['items'] is List) {
            // Format: { "items": [...] }
            caseList = data['items'] as List<dynamic>;
          }
        }

        return caseList
            .map((c) => Case.fromJson(c as Map<String, dynamic>))
            .toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Failed to fetch cases',
          statusCode: response.statusCode,
          code: errorData['code'],
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An error occurred: $e');
    }
  }

  // Get case by ID
  static Future<Case> getCaseById(String caseId) async {
    try {
      final token = await TokenService.getToken();

      if (token == null) {
        throw ApiException(message: 'Authentication token not found');
      }

      final response = await http
          .get(
            Uri.parse('$baseUrl/cases/$caseId'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw ApiException(
              message: 'Request timeout. Please try again.',
              statusCode: 408,
            ),
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Handle multiple response formats
        Map<String, dynamic> caseData;

        if (data is Map) {
          if (data['case'] != null) {
            // Format: { "case": {...} }
            caseData = data['case'] as Map<String, dynamic>;
          } else if (data['data'] != null) {
            // Format: { "data": {...} }
            caseData = data['data'] as Map<String, dynamic>;
          } else {
            // Direct case object
            caseData = data as Map<String, dynamic>;
          }
        } else {
          throw ApiException(message: 'Invalid response format');
        }

        return Case.fromJson(caseData);
      } else {
        final errorData = jsonDecode(response.body);
        throw ApiException(
          message: errorData['message'] ?? 'Failed to fetch case',
          statusCode: response.statusCode,
          code: errorData['code'],
        );
      }
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException(message: 'An error occurred: $e');
    }
  }

  // Upload images for a case
  static Future<List<CaseImage>> uploadCaseImages(
    String caseId,
    List<File> images,
  ) async {
    try {
      print('[CaseService] ========== BEGIN UPLOAD CASE IMAGES ==========');
      print('[CaseService] Case ID: $caseId');
      print('[CaseService] Number of images: ${images.length}');

      if (images.isEmpty) {
        throw ApiException(message: 'No images to upload');
      }

      final token = await TokenService.getToken();
      if (token == null) {
        throw ApiException(message: 'Authentication token not found');
      }

      print('[CaseService] Token retrieved: ${token.substring(0, 20)}...');

      final uri = Uri.parse('$baseUrl/cases/$caseId/images');
      print('[CaseService] Upload endpoint: $uri');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      for (int i = 0; i < images.length; i++) {
        final file = images[i];
        print('[CaseService] Processing image ${i + 1}/${images.length}...');
        print('[CaseService]   Path: ${file.path}');

        if (!await file.exists()) {
          throw ApiException(message: 'Image file not found: ${file.path}');
        }

        final fileBytes = await file.readAsBytes();
        final fileName = file.path.split('/').last;
        final mimeType = _getMimeType(fileName);

        print('[CaseService]   File name: $fileName');
        print('[CaseService]   File size: ${fileBytes.length} bytes');
        print('[CaseService]   MIME type: $mimeType');

        request.files.add(
          http.MultipartFile.fromBytes(
            'images',
            fileBytes,
            filename: fileName,
            contentType: MediaType.parse(mimeType),
          ),
        );

        print('[CaseService]   ✓ Image added to request');
      }

      print('[CaseService] Sending multipart request...');
      print('[CaseService] Total files in request: ${request.files.length}');

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 60),
        onTimeout: () => throw ApiException(
          message: 'Upload timeout. Please try again.',
          statusCode: 408,
        ),
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('[CaseService] ✓ Response received');
      print('[CaseService] Response status: ${response.statusCode}');
      print('[CaseService] Response body length: ${response.body.length}');
      print('[CaseService] Response headers: ${response.headers}');
      print(
        '[CaseService] Response body (first 1000 chars): ${response.body.substring(0, response.body.length > 1000 ? 1000 : response.body.length)}',
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('[CaseService] Parsing response JSON...');
        final data = jsonDecode(response.body);
        print('[CaseService] Parsed data type: ${data.runtimeType}');
        print('[CaseService] Full parsed data: $data');

        // Parse response - could be wrapped or direct
        List<dynamic> imageList = [];

        if (data is List) {
          imageList = data;
          print('[CaseService] Response is direct list format');
        } else if (data is Map) {
          print('[CaseService] Response is Map format');
          print('[CaseService] Response keys: ${data.keys.toList()}');

          if (data['images'] != null && data['images'] is List) {
            imageList = data['images'] as List<dynamic>;
            print('[CaseService] Using "images" key format');
          } else if (data['data'] != null && data['data'] is List) {
            imageList = data['data'] as List<dynamic>;
            print('[CaseService] Using "data" key format');
          } else {
            print(
              '[CaseService] WARNING: No recognized list key in response',
            );
          }
        }

        print('[CaseService] Image list length: ${imageList.length}');

        print('[CaseService] Parsing each image...');
        final result = <CaseImage>[];
        for (int i = 0; i < imageList.length; i++) {
          try {
            final img = imageList[i];
            print('[CaseService] Image $i data type: ${img.runtimeType}');
            print('[CaseService] Image $i data: $img');

            final parsed = CaseImage.fromJson(img as Map<String, dynamic>);
            result.add(parsed);

            print('[CaseService] ✓ Image $i parsed successfully');
            print('[CaseService]   - ID: ${parsed.id}');
            print('[CaseService]   - File name: ${parsed.fileName}');
            print('[CaseService]   - URL: ${parsed.imageUrl}');
          } catch (e, stackTrace) {
            print('[CaseService] ✗ Error parsing image $i: $e');
            print('[CaseService] Stack trace: $stackTrace');
            print('[CaseService] Problem image data: ${imageList[i]}');
            rethrow;
          }
        }

        print('[CaseService] ✓ All ${result.length} images parsed successfully');
        print('[CaseService] ========== END UPLOAD CASE IMAGES ==========');
        return result;
      } else {
        final errorBody = response.body;
        print('[CaseService] ✗ Upload failed with status ${response.statusCode}');
        print('[CaseService] Error body: $errorBody');

        try {
          final errorData = jsonDecode(errorBody);
          print('[CaseService] Error data parsed: $errorData');
          throw ApiException(
            message:
                errorData['message'] ??
                'Failed to upload images (${response.statusCode})',
            statusCode: response.statusCode,
            code: errorData['code'],
          );
        } catch (e) {
          print('[CaseService] Error parsing error response: $e');
          throw ApiException(
            message: 'Failed to upload images (${response.statusCode})',
            statusCode: response.statusCode,
          );
        }
      }
    } on ApiException catch (e) {
      print('[CaseService] ✗ ApiException: $e');
      rethrow;
    } catch (e, stackTrace) {
      print('[CaseService] ✗ Unexpected error: $e');
      print('[CaseService] Stack trace: $stackTrace');
      throw ApiException(
        message: 'An error occurred while uploading images: $e',
      );
    }
  }

  // Helper method to detect MIME type from file extension
  static String _getMimeType(String fileName) {
    final ext = fileName.toLowerCase().split('.').last;

    final mimeTypes = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'gif': 'image/gif',
      'webp': 'image/webp',
      'bmp': 'image/bmp',
      'ico': 'image/x-icon',
    };

    return mimeTypes[ext] ?? 'image/jpeg'; // Default to jpeg if unknown
  }
}
