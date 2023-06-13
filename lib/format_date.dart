import 'package:intl/intl.dart';

String formatDate(String dateStr, String outputFormat) {
  // Define a list of separator characters
  List<String> separators = ['.', '-', '/', '\\', ' '];

  // Define a list of format patterns to try
  List<String> formatPatterns = ['d-m-y', 'y-m-d', 'm-d-y', 'm-y', 'y'];

  for (String pattern in formatPatterns) {
    // Split the date string into parts based on the separator characters and format pattern
    List<String> dateValues = [dateStr];
    for (String separator in separators) {
      List<String> parts = [];
      for (String value in dateValues) {
        parts.addAll(value.split(separator));
      }
      dateValues = parts;
    }

    // Remove empty values from the list
    dateValues.removeWhere((value) => value.isEmpty);

    // Attempt to parse the date, month, and year values based on the format pattern
    int? day;
    int? month;
    int? year;

    if (pattern == 'd-m-y') {
      if (dateValues.length == 3) {
        day = tryParseDay(dateValues);
        month = tryParseMonth(dateValues.sublist(1, 2));
        year = tryParseYear(dateValues.sublist(2));
      }
    } else if (pattern == 'y-m-d') {
      if (dateValues.length == 3) {
        year = tryParseYear(dateValues);
        month = tryParseMonth(dateValues.sublist(1, 2));
        day = tryParseDay(dateValues.sublist(2));
      }
    } else if (pattern == 'm-d-y') {
      if (dateValues.length == 3) {
        month = tryParseMonth(dateValues);
        day = tryParseDay(dateValues.sublist(1, 2));
        year = tryParseYear(dateValues.sublist(2));
      }
    } else if (pattern == 'm-y') {
      if (dateValues.length == 2) {
        month = tryParseMonth(dateValues.sublist(0, 1));
        year = tryParseYear(dateValues.sublist(1));
      }
    } else if (pattern == 'y') {
      if (dateValues.length == 1) {
        year = tryParseYear(dateValues);
      }
    }

    // Validate the day, month, and year values
    if (day != null || month != null || year != null) {
      day ??= 1;
      month ??= 1;
      if (year == null) return 'Invalid date';

      if (day > 31 ||
          (day > 30 && [4, 6, 9, 11].contains(month)) ||
          (day > 29 && month == 2) ||
          year < 1000) {
        continue; // Try the next format pattern
      }

      if (month > 12) {
        int temp = month;
        month = day;
        day = temp;
      }

      // Format the date as a DateTime object
      DateTime parsedDate = DateTime(year, month, day);

      // Format the date string according to the output format
      String formattedDate = DateFormat(outputFormat).format(parsedDate);

      return formattedDate;
    }
  }

  return 'Invalid date';
}

int? tryParseDay(List<String> dateValues) {
  for (String value in dateValues) {
    int? dayValue = int.tryParse(value);
    if (dayValue != null && dayValue >= 1 && dayValue <= 31) {
      return dayValue;
    }
  }
  return null;
}

int? tryParseMonth(List<String> dateValues) {
  for (String value in dateValues) {
    int? monthValue = int.tryParse(value);
    if (monthValue != null && monthValue >= 1 && monthValue <= 12) {
      return monthValue;
    }
  }

  // Define the month names list
  List<String> monthNames = [    'jan',    'feb',    'mar',    'apr',    'may',    'jun',    'jul',    'aug',    'sep',    'oct',    'nov',    'dec'  ];

  for (String value in dateValues) {
    String monthValue = value.toLowerCase();
    for (int j = 0; j < monthNames.length; j++) {
      if (monthValue.contains(monthNames[j])) {
        return j + 1;
      }
    }
  }

  // Try to parse the month from the first value
  String firstValue = dateValues.first;
  int? monthValue = int.tryParse(firstValue);
  if (monthValue != null && monthValue >= 1 && monthValue <= 12) {
    return monthValue;
  }

  return null;
}

int? tryParseYear(List<String> dateValues) {
  for (String value in dateValues) {
    int? yearValue = int.tryParse(value);
    if (yearValue != null && yearValue >= 1000) {
      return yearValue;
    }
  }
  return null;
}