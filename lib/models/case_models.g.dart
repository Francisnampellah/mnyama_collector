// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'case_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DiseaseLabel _$DiseaseLabelFromJson(Map<String, dynamic> json) => DiseaseLabel(
  id: json['id'] as String,
  code: json['code'] as String,
  name: json['name'] as String,
  animalType: json['animalType'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$DiseaseLabelToJson(DiseaseLabel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'animalType': instance.animalType,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

CreateCaseRequest _$CreateCaseRequestFromJson(Map<String, dynamic> json) =>
    CreateCaseRequest(
      diseaseLabelId: json['diseaseLabelId'] as String,
      animalType: json['animalType'] as String,
      breed: json['breed'] as String?,
      ageMonths: (json['ageMonths'] as num?)?.toInt(),
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      symptoms: json['symptoms'] as String,
      diagnosis: json['diagnosis'] as String?,
      notes: json['notes'] as String?,
      farmLocation: json['farmLocation'] as String?,
      severity: $enumDecode(_$CaseSeverityEnumMap, json['severity']),
    );

Map<String, dynamic> _$CreateCaseRequestToJson(CreateCaseRequest instance) =>
    <String, dynamic>{
      'diseaseLabelId': instance.diseaseLabelId,
      'animalType': instance.animalType,
      'breed': instance.breed,
      'ageMonths': instance.ageMonths,
      'gender': _$GenderEnumMap[instance.gender]!,
      'symptoms': instance.symptoms,
      'diagnosis': instance.diagnosis,
      'notes': instance.notes,
      'farmLocation': instance.farmLocation,
      'severity': _$CaseSeverityEnumMap[instance.severity]!,
    };

const _$GenderEnumMap = {
  Gender.MALE: 'MALE',
  Gender.FEMALE: 'FEMALE',
  Gender.UNKNOWN: 'UNKNOWN',
};

const _$CaseSeverityEnumMap = {
  CaseSeverity.MILD: 'MILD',
  CaseSeverity.MODERATE: 'MODERATE',
  CaseSeverity.SEVERE: 'SEVERE',
  CaseSeverity.CRITICAL: 'CRITICAL',
};

CaseImage _$CaseImageFromJson(Map<String, dynamic> json) => CaseImage(
  id: json['id'] as String?,
  caseId: json['caseId'] as String,
  imageUrl: json['imageUrl'] as String,
  fileName: json['fileName'] as String,
  mimeType: json['mimeType'] as String,
  fileSize: (json['fileSize'] as num).toInt(),
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$CaseImageToJson(CaseImage instance) => <String, dynamic>{
  'id': instance.id,
  'caseId': instance.caseId,
  'imageUrl': instance.imageUrl,
  'fileName': instance.fileName,
  'mimeType': instance.mimeType,
  'fileSize': instance.fileSize,
  'createdAt': instance.createdAt?.toIso8601String(),
};

Case _$CaseFromJson(Map<String, dynamic> json) => Case(
  id: json['id'] as String,
  userId: json['userId'] as String,
  diseaseLabelId: json['diseaseLabelId'] as String,
  animalType: json['animalType'] as String,
  breed: json['breed'] as String?,
  ageMonths: (json['ageMonths'] as num?)?.toInt(),
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  symptoms: json['symptoms'] as String,
  diagnosis: json['diagnosis'] as String?,
  notes: json['notes'] as String?,
  farmLocation: json['farmLocation'] as String?,
  severity: $enumDecode(_$CaseSeverityEnumMap, json['severity']),
  status: $enumDecode(_$CaseStatusEnumMap, json['status']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  images: (json['images'] as List<dynamic>?)
      ?.map((e) => CaseImage.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$CaseToJson(Case instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'diseaseLabelId': instance.diseaseLabelId,
  'animalType': instance.animalType,
  'breed': instance.breed,
  'ageMonths': instance.ageMonths,
  'gender': _$GenderEnumMap[instance.gender]!,
  'symptoms': instance.symptoms,
  'diagnosis': instance.diagnosis,
  'notes': instance.notes,
  'farmLocation': instance.farmLocation,
  'severity': _$CaseSeverityEnumMap[instance.severity]!,
  'status': _$CaseStatusEnumMap[instance.status]!,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'images': instance.images,
};

const _$CaseStatusEnumMap = {
  CaseStatus.SUBMITTED: 'SUBMITTED',
  CaseStatus.UNDER_REVIEW: 'UNDER_REVIEW',
  CaseStatus.APPROVED: 'APPROVED',
  CaseStatus.REJECTED: 'REJECTED',
};
