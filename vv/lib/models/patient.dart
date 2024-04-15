class Patient {
  final String patientId;
  final String patientName;

  Patient({required this.patientId, required this.patientName});

  factory Patient.fromJson(Map<String, dynamic> json) {
    if (json['patientId'] == null || json['patientName'] == null) {
      throw FormatException('Missing required field(s) in Patient JSON data');
    }
    return Patient(
      patientId: json['patientId'].toString(),
      patientName: json['patientName'],
    );
  }
}

class PatientService {
  void someFunctionThatNeedsPatientId(String patientId) {
    // You can use patientId here to perform some logic, like fetching more data
    print('Using patient ID: $patientId');
  }
}
