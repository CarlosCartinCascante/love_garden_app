// Time utilities for parsing and validating user-entered times.
// Centralized here to be unit-testable and reused across the app.

class TimeUtils {
  // Normalizes many input formats (8:5, 8:05 AM, 20:5, 12:00 pm, 8-05PM, 08.05)
  // to canonical HH:mm (24h). Returns empty string when parsing fails.
  static String canonicalizeTime(String? input) {
    if (input == null) return '';
    final s = input.trim();
    if (s.isEmpty) return '';

    final upper = s.toUpperCase();
    final isAM = upper.contains('AM');
    final isPM = upper.contains('PM');

    // Replace common separators with ':' first to simplify parsing
    var normalized = upper
        .replaceAll(RegExp(r'[\.\-]'), ':')
        .replaceAll(RegExp(r'\s+'), ':');

    // If we still don't have a colon, try to infer from digits
    if (!normalized.contains(':')) {
      final digitsOnly = upper.replaceAll(RegExp(r'[^0-9]'), '');
      if (digitsOnly.length < 3) return '';
      final hourStr = digitsOnly.substring(0, digitsOnly.length - 2);
      final minStr = digitsOnly.substring(digitsOnly.length - 2);
      normalized = '$hourStr:$minStr';
    }

    // Keep only digits and colon to parse numbers safely
    final cleaned = normalized.replaceAll(RegExp(r'[^0-9:]'), '');
    final parts = cleaned.split(':').where((p) => p.isNotEmpty).toList();
    if (parts.length < 2) return '';

    int h = int.tryParse(parts[0]) ?? 0;
    // Join any extra pieces in case of multiple separators (take first 2 chars)
    final minuteRaw = parts.sublist(1).join('');
    int m = int.tryParse(minuteRaw.padLeft(2, '0').substring(0, 2)) ?? 0;

    // Handle AM/PM conversions
    if (isPM && h < 12) h += 12;
    if (isAM && h == 12) h = 0;

    // Clamp ranges
    h = h.clamp(0, 23);
    m = m.clamp(0, 59);

    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  // Validates canonical HH:mm strings. Returns null when valid or an error message.
  static String? validateHHmm(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    final regex = RegExp(r'^([01]\d|2[0-3]):([0-5]\d)$');
    if (!regex.hasMatch(value)) return 'Formato HH:mm';
    return null;
  }
}
