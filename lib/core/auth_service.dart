import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';

class AuthService {
  static const _pinKey = 'hidrata_pin_hash';
  static const _activeUserIdKey = 'hidrata_active_user_id';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final LocalAuthentication _localAuth = LocalAuthentication();

  String _hash(String pin) => sha256.convert(utf8.encode(pin)).toString();

  Future<bool> hasPin() async {
    final hash = await _storage.read(key: _pinKey);
    return hash != null;
  }

  Future<void> savePin(String pin) async {
    await _storage.write(key: _pinKey, value: _hash(pin));
  }

  Future<int?> getActiveUserId() async {
    final value = await _storage.read(key: _activeUserIdKey);
    return value != null ? int.tryParse(value) : null;
  }

  Future<void> setActiveUserId(int id) async {
    await _storage.write(key: _activeUserIdKey, value: id.toString());
  }

  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored != null && stored == _hash(pin);
  }

  Future<bool> authenticateBiometric() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isSupported = await _localAuth.isDeviceSupported();
      if (!canCheck || !isSupported) return false;
      return await _localAuth.authenticate(
        localizedReason: 'Autentique-se para acessar o Hidrata',
        options: const AuthenticationOptions(biometricOnly: true),
      );
    } catch (_) {
      return false;
    }
  }
}
