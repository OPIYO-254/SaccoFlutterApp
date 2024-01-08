class Formatter{

  String formatAsTitle(String input) {
    if (input.isEmpty) {
      return '';
    }

    // Split the string into words
    List<String> words = input.toLowerCase().split(' ');

    // Capitalize the first letter of each word
    List<String> capitalizedWords = words.map((word) {
      if (word.isNotEmpty) {
        return word[0].toUpperCase() + word.substring(1);
      } else {
        return '';
      }
    }).toList();

    // Join the words back together
    String titleCaseString = capitalizedWords.join(' ');

    return titleCaseString;
  }
}