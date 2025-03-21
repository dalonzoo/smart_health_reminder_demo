// lib/services/entity_extractor.dart
class EntityExtractor {
  // Extract time entities
  TimeEntity? extractTime(String text) {
    // Match patterns like "at 3:30", "at 15:30", "3:30 pm", "3 pm", etc.
    final timeRegex = RegExp(
      r'(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)?',
      caseSensitive: false,
    );

    final match = timeRegex.firstMatch(text);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      int minute = 0;

      // Parse minutes if provided
      if (match.group(2) != null) {
        minute = int.parse(match.group(2)!);
      }

      // Handle am/pm
      final ampm = match.group(3)?.toLowerCase();
      if (ampm == 'pm' && hour < 12) {
        hour += 12;
      } else if (ampm == 'am' && hour == 12) {
        hour = 0;
      }

      return TimeEntity(hour: hour, minute: minute);
    }

    return null;
  }

  // Extract date entities
  DateEntity? extractDate(String text) {
    // Match patterns like "tomorrow", "next Monday", "on May 15", etc.

    // Check for relative dates
    if (text.contains('tomorrow')) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      return DateEntity(
        year: tomorrow.year,
        month: tomorrow.month,
        day: tomorrow.day,
      );
    }

    if (text.contains('today')) {
      final today = DateTime.now();
      return DateEntity(
        year: today.year,
        month: today.month,
        day: today.day,
      );
    }

    // Check for day of week
    final daysOfWeek = [
      'monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday'
    ];

    for (int i = 0; i < daysOfWeek.length; i++) {
      if (text.toLowerCase().contains(daysOfWeek[i])) {
        // Calculate the next occurrence of this day
        final now = DateTime.now();
        final currentDayOfWeek = now.weekday; // 1 = Monday, 7 = Sunday
        final targetDayOfWeek = i + 1; // Convert to 1-based index

        int daysToAdd = targetDayOfWeek - currentDayOfWeek;
        if (daysToAdd <= 0) daysToAdd += 7; // Go to next week

        // Check if "next" is specified
        if (text.toLowerCase().contains('next ${daysOfWeek[i]}')) {
          daysToAdd += 7; // Skip to the following week
        }

        final targetDate = now.add(Duration(days: daysToAdd));
        return DateEntity(
          year: targetDate.year,
          month: targetDate.month,
          day: targetDate.day,
        );
      }
    }

    // Check for specific dates (e.g., "May 15")
    final monthNames = [
      'january', 'february', 'march', 'april', 'may', 'june',
      'july', 'august', 'september', 'october', 'november', 'december'
    ];

    for (int i = 0; i < monthNames.length; i++) {
      final monthRegex = RegExp(
        '${monthNames[i]}\\s+(\\d{1,2})',
        caseSensitive: false,
      );

      final match = monthRegex.firstMatch(text);
      if (match != null) {
        final day = int.parse(match.group(1)!);
        final month = i + 1; // Convert to 1-based index
        final year = DateTime.now().year;

        return DateEntity(year: year, month: month, day: day);
      }
    }

    return null;
  }

  // Extract quantity entities
  QuantityEntity? extractQuantity(String text) {
    // Match patterns like "500 ml", "2 liters", "10 minutes", etc.
    final quantityRegex = RegExp(
      r'(\d+(?:\.\d+)?)\s*(ml|liter|liters|l|glass|glasses|cup|cups|oz|step|steps|minute|minutes|min)',
      caseSensitive: false,
    );

    final match = quantityRegex.firstMatch(text);
    if (match != null) {
      final value = double.parse(match.group(1)!);
      final unit = match.group(2)!.toLowerCase();

      return QuantityEntity(value: value, unit: unit);
    }

    return null;
  }
}

// Entity classes
class TimeEntity {
  final int hour;
  final int minute;

  TimeEntity({required this.hour, required this.minute});

  @override
  String toString() => '$hour:${minute.toString().padLeft(2, '0')}';
}

class DateEntity {
  final int year;
  final int month;
  final int day;

  DateEntity({required this.year, required this.month, required this.day});

  DateTime toDateTime() => DateTime(year, month, day);

  @override
  String toString() => '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

class QuantityEntity {
  final double value;
  final String unit;

  QuantityEntity({required this.value, required this.unit});

  @override
  String toString() => '$value $unit';
}