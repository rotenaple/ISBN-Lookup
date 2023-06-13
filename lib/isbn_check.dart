class IsbnCheck {
  bool isValidIsbnFormat(String isbn) {
    isbn = isbn.replaceAll('-', ''); // Remove dashes from ISBN

    if (isbn.length == 10) {
      // ISBN-10 check digit calculation
      int sum = 0;
      for (int i = 0; i < 9; i++) {
        if (isbn[i] == 'X') {
          sum += 10 * (10 - i);
        } else {
          sum += int.parse(isbn[i]) * (10 - i);
        }
      }
      int checkDigit = (11 - (sum % 11)) % 11;

      bool isValid = (isbn[9] == 'X' && checkDigit == 10) || (checkDigit == int.parse(isbn[9]));

      print("checkdigit matches: " + isValid.toString());
      return isValid;
    } else if (isbn.length == 13) {
      // ISBN-13 check digit calculation
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        sum += int.parse(isbn[i]) * (i % 2 == 0 ? 1 : 3);
      }
      int checkDigit = 10 - (sum % 10);
      if (checkDigit == 10) {
        checkDigit = 0;
      }

      bool isValid = checkDigit == int.parse(isbn[12]);

      print("checkdigit matches: " + isValid.toString());
      return isValid;
    }

    return false; // Invalid ISBN length
  }
}
