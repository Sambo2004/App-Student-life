import 'dart:convert';
import 'dart:math';

import 'package:cryptography/cryptography.dart';

import '../data/student_store.dart';

/// Password-protects backups with authenticated AES-256-GCM encryption.
/// The password is never stored by the app.
class EncryptedBackupService {
  EncryptedBackupService._();

  static final instance = EncryptedBackupService._();

  final _cipher = AesGcm.with256bits();
  final _kdf = Argon2id(
    memory: 19 * 1024,
    parallelism: 2,
    iterations: 2,
    hashLength: 32,
  );

  Future<String> exportBackup(String password) async {
    _validatePassword(password);
    final salt = _randomBytes(16);
    final key = await _deriveKey(password, salt);
    final box = await _cipher.encryptString(
      StudentStore.instance.exportBackup(),
      secretKey: key,
    );
    return jsonEncode({
      'format': 'student-life-encrypted-backup',
      'version': 1,
      'kdf': 'argon2id',
      'cipher': 'aes-256-gcm',
      'salt': base64Encode(salt),
      'nonce': base64Encode(box.nonce),
      'cipherText': base64Encode(box.cipherText),
      'mac': base64Encode(box.mac.bytes),
    });
  }

  Future<void> importBackup(String source, String password) async {
    _validatePassword(password);
    if (source.length > 8 * 1024 * 1024) {
      throw const FormatException('Encrypted backup is too large.');
    }
    try {
      final value = jsonDecode(source);
      if (value is! Map<String, dynamic> ||
          value['format'] != 'student-life-encrypted-backup' ||
          value['version'] != 1) {
        throw const FormatException('Unsupported encrypted backup format.');
      }
      final salt = base64Decode(value['salt'] as String);
      final box = SecretBox(
        base64Decode(value['cipherText'] as String),
        nonce: base64Decode(value['nonce'] as String),
        mac: Mac(base64Decode(value['mac'] as String)),
      );
      final clearText = await _cipher.decryptString(
        box,
        secretKey: await _deriveKey(password, salt),
      );
      await StudentStore.instance.importBackup(clearText);
    } on SecretBoxAuthenticationError {
      throw const FormatException('Incorrect password or damaged backup.');
    } on FormatException {
      rethrow;
    } catch (_) {
      throw const FormatException('Incorrect password or damaged backup.');
    }
  }

  Future<SecretKey> _deriveKey(String password, List<int> salt) =>
      _kdf.deriveKeyFromPassword(password: password, nonce: salt);

  List<int> _randomBytes(int length) {
    final random = Random.secure();
    return List<int>.generate(length, (_) => random.nextInt(256));
  }

  void _validatePassword(String password) {
    if (password.length < 8) {
      throw const FormatException(
        'Use a backup password with at least 8 characters.',
      );
    }
  }
}
