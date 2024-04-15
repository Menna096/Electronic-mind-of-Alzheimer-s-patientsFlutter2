import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageManager {
  final _storage = FlutterSecureStorage();

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
}
