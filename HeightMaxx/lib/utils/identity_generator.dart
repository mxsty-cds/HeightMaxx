// lib/utils/identity_generator.dart
//
// Utility class for generating stable user IDs, unique handles,
// and on-brand fallback nicknames.

import 'dart:math';

class IdentityGenerator {
  IdentityGenerator._(); // Prevent instantiation

  static final Random _random = Random();

  static const List<String> _fallbackNicknames = [
    'SkyStretcher',
    'ApexMover',
    'PosturePro',
    'CloudReacher',
    'SpineAligner',
    'SummitSeeker',
    'ZenMover',
    'GravitySurfer',
  ];

  /// Generates a unique, stable internal User ID.
  /// Uses a combination of the current timestamp and a random hex string.
  static String generateUserId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch.toRadixString(16);
    final randomPart = _random.nextInt(0xFFFFFF).toRadixString(16).padLeft(6, '0');
    return 'hmx_$timestamp$randomPart';
  }

  /// Generates a human-readable, unique-ish handle based on the user's input.
  /// Example: "Alex" -> "alex_842"
  static String generateUsername(String baseName) {
    if (baseName.trim().isEmpty) {
      baseName = 'user';
    }
    // Remove spaces, special characters, and make lowercase
    final sanitized = baseName.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    final suffix = _random.nextInt(999).toString().padLeft(3, '0');
    return '${sanitized}_$suffix';
  }

  /// Returns a random, on-brand nickname for users who skip the input step.
  static String generateNickname() {
    final index = _random.nextInt(_fallbackNicknames.length);
    return _fallbackNicknames[index];
  }
}