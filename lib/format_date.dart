class ExtractYear {
  String extract(String date) {
    String year = '';
    int currentIndex = 0;

    while (currentIndex <= date.length - 4) {
      if (_isFourConsecutiveDigits(date, currentIndex)) {
        year = date.substring(currentIndex, currentIndex + 4);
        break;
      }
      currentIndex++;
    }

    return year;
  }

  bool _isFourConsecutiveDigits(String date, int index) {
    RegExp digitRegex = RegExp(r'\d');

    for (int i = index; i < index + 4; i++) {
      if (!digitRegex.hasMatch(date[i])) {
        return false;
      }
    }
    return true;
  }
}
