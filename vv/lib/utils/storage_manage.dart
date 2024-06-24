import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  final _storage = const FlutterSecureStorage();

  Future<void> setPatientId(String patientId) async {
    await _storage.write(key: 'patientId', value: patientId);
  }

  Future<String?> getPatientId() async {
    return await _storage.read(key: 'patientId');
  }

  Future<void> setPatientname(String patientId) async {
    await _storage.write(key: 'patientName', value: patientId);
  }

  Future<String?> getPatientname() async {
    return await _storage.read(key: 'patientName');
  }

  Future<void> saveReminderId(String reminderId) async {
    await _storage.write(key: 'reminderId', value: reminderId);
  }

  // Get the saved reminder ID from secure storage
  Future<String?> getReminderId() async {
    return await _storage.read(key: 'reminderId');
  }

  Future<void> savefamilyId(String reminderId) async {
    await _storage.write(key: 'familyId', value: reminderId);
  }

  // Get the saved reminder ID from secure storage
  Future<String?> getfamilyId() async {
    return await _storage.read(key: 'familyId');
  }
}
