class FamilyMember {
  String familyId;
  String familyName;
  String relationility;
  String hisImageUrl;

  FamilyMember(
      {required this.familyId,
      required this.familyName,
      required this.relationility,
      required this.hisImageUrl});

  factory FamilyMember.fromJson(Map<String, dynamic> json) {
    return FamilyMember(
      familyId: json['familyId'], // Added familyId field here
      familyName: json['familyName'],
      relationility: json['relationility'],
      hisImageUrl: json['hisImageUrl'],
    );
  }
}
