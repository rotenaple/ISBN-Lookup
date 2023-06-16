class TitleCaseConverter {
  static String convertToTitleCase(String input) {
    final List<String> functionWords = [
      'a',
      'an',
      'the',
      'of',
      'in',
      'on',
      'with',
      'by',
      'for',
      'to',
      'and',
      'but',
      'or',
      'nor',
      'so',
      'yet'
    ];
    final List<String> words = input.split(' ');

    for (int i = 0; i < words.length; i++) {
      if (i == 0 || !functionWords.contains(words[i]) || isAfterStopPunctuation(words[i - 1])) {
        words[i] = capitalizeIfNeeded(words[i]);
      }
    }

    return words.join(' ');
  }

  static bool isAfterStopPunctuation(String word) {
    if (word.isEmpty) return false;

    final List<String> stopPunctuations = ['.', '!', '?', ':', '|', '{', '}', '[', ']', '('];
    final String firstCharacter = word[0];

    return stopPunctuations.contains(firstCharacter);
  }

  static String capitalizeIfNeeded(String word) {
    if (word.isEmpty) return word;

    if (word == word.toUpperCase() && word != word.toLowerCase()) {
      // Word contains at least one uppercase letter and no lowercase letters
      return word;
    } else {
      return capitalize(word);
    }
  }

  static String capitalize(String word) {
    if (word.isEmpty) return word;

    return word[0].toUpperCase() + word.substring(1);
  }
}
