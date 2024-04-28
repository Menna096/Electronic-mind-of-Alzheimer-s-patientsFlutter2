class FamilyMember {
  String familyId;
  String familyName;
  String relationility;
  String? familyDescriptionForPatient; // Changed to nullable type
  String hisImageUrl;

  FamilyMember({
    required this.familyId,
    required this.familyName,
    required this.relationility,
    this.familyDescriptionForPatient, // Removed required keyword
    required this.hisImageUrl,
  });

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      familyId: json['familyId'], 
      familyName: json['familyName'],
      relationility: json['relationility'],
      familyDescriptionForPatient: json['familyDescriptionForPatient'],
      hisImageUrl: json['hisImageUrl'],
    );
  }
}
