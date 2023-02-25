class IsbnUtils {
  static bool isValidIsbn(String isbn) {
    if (isbn == null) {
      return false;
    }
    isbn = isbn.replaceAll('-', '').replaceAll(' ', ''); // remove dashes and spaces
    if (isbn.length != 10 && isbn.length != 13) {
      return false;
    }
    if (isbn.length == 10) {
      // Validate ISBN-10
      int sum = 0;
      for (int i = 0; i < 9; i++) {
        int? digit = int.tryParse(isbn[i]);
        if (digit == null) {
          return false;
        }
        sum += digit * (10 - i);
      }
      int checkDigit = int.tryParse(isbn[9]) ?? 0;
      return (sum + checkDigit) % 11 == 0;
    } else {
      // Validate ISBN-13
      if (!isbn.startsWith('978') && !isbn.startsWith('979')) {
        return false;
      }
      int sum = 0;
      for (int i = 0; i < 12; i++) {
        int? digit = int.tryParse(isbn[i]);
        if (digit == null) {
          return false;
        }
        sum += digit * (i.isOdd ? 3 : 1);
      }
      int checkDigit = int.tryParse(isbn[12]) ?? 0;
      return (sum + checkDigit) % 10 == 0;
    }
  }
}
