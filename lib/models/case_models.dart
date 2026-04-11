import 'package:json_annotation/json_annotation.dart';

part 'case_models.g.dart';

// Disease Label Model
@JsonSerializable()
class DiseaseLabel {
  final String id;
  final String code;
  final String name;
  final String animalType;
  final DateTime createdAt;
  final DateTime updatedAt;

  DiseaseLabel({
    required this.id,
    required this.code,
    required this.name,
    required this.animalType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DiseaseLabel.fromJson(Map<String, dynamic> json) =>
      _$DiseaseLabelFromJson(json);
  Map<String, dynamic> toJson() => _$DiseaseLabelToJson(this);

  @override
  String toString() => '$code - $name ($animalType)';
}

// Case Severity enum
enum CaseSeverity {
  @JsonValue('MILD')
  MILD,
  @JsonValue('MODERATE')
  MODERATE,
  @JsonValue('SEVERE')
  SEVERE,
  @JsonValue('CRITICAL')
  CRITICAL,
}

// Case Status enum
enum CaseStatus {
  @JsonValue('SUBMITTED')
  SUBMITTED,
  @JsonValue('UNDER_REVIEW')
  UNDER_REVIEW,
  @JsonValue('APPROVED')
  APPROVED,
  @JsonValue('REJECTED')
  REJECTED,
}

// Gender enum
enum Gender {
  @JsonValue('MALE')
  MALE,
  @JsonValue('FEMALE')
  FEMALE,
  @JsonValue('UNKNOWN')
  UNKNOWN,
}

// Create Case Request
@JsonSerializable()
class CreateCaseRequest {
  final String diseaseLabelId;
  final String animalType;
  final String? breed;
  final int? ageMonths;
  final Gender gender;
  final String symptoms;
  final String? diagnosis;
  final String? notes;
  final String? farmLocation;
  final CaseSeverity severity;

  CreateCaseRequest({
    required this.diseaseLabelId,
    required this.animalType,
    this.breed,
    this.ageMonths,
    required this.gender,
    required this.symptoms,
    this.diagnosis,
    this.notes,
    this.farmLocation,
    required this.severity,
  });

  factory CreateCaseRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateCaseRequestFromJson(json);
  Map<String, dynamic> toJson() => _$CreateCaseRequestToJson(this);
}

// Case Image Model
@JsonSerializable()
class CaseImage {
  final String id;
  final String caseId;
  final String imageUrl;
  final String fileName;
  final String mimeType;
  final int fileSize;
  final DateTime createdAt;

  CaseImage({
    required this.id,
    required this.caseId,
    required this.imageUrl,
    required this.fileName,
    required this.mimeType,
    required this.fileSize,
    required this.createdAt,
  });

  factory CaseImage.fromJson(Map<String, dynamic> json) =>
      _$CaseImageFromJson(json);
  Map<String, dynamic> toJson() => _$CaseImageToJson(this);
}

// Case Model
@JsonSerializable()
class Case {
  final String id;
  final String userId;
  final String diseaseLabelId;
  final String animalType;
  final String? breed;
  final int? ageMonths;
  final Gender gender;
  final String symptoms;
  final String? diagnosis;
  final String? notes;
  final String? farmLocation;
  final CaseSeverity severity;
  final CaseStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<CaseImage>? images;

  Case({
    required this.id,
    required this.userId,
    required this.diseaseLabelId,
    required this.animalType,
    this.breed,
    this.ageMonths,
    required this.gender,
    required this.symptoms,
    this.diagnosis,
    this.notes,
    this.farmLocation,
    required this.severity,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.images,
  });

  factory Case.fromJson(Map<String, dynamic> json) => _$CaseFromJson(json);
  Map<String, dynamic> toJson() => _$CaseToJson(this);
}
