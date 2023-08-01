import 'dart:async';
import 'package:english_words/english_words.dart';
import 'package:langchain/langchain.dart';
import 'package:string_similarity/string_similarity.dart';
// import 'package:math_expressions/math_expressions.dart';

// import 'base.dart';

/// {@template rhyme_tool}
/// A tool that can be used to rhyme a couple of words
/// {@endtemplate}
final class RhymeTool extends Tool {
  /// {@macro calculator_tool}
  RhymeTool()
      : super(
          name: 'rhymer',
          description:
              'you will find if the last words of each line from the input rhymes are not'
              'The input to this tool should be a lines of strings'
              'that can be analyzed to see if and how much they rhyme using Dice\'s Coefficient.',
        );

  @override
  FutureOr<String> runInternalString(final String toolInput) {
    try {
      return findRhyme(toolInput);
    } catch (e) {
      return "I don't know how to do that.";
    }
  }

  String poem = '''long tresses over--
blooming face; reminds one of:
cherry budding tree''';

  String preprocessPoem(String poem) {
    return poem.replaceAll(RegExp(r"['’]"), 'a');
  }

  int countTotalSyllables() {
    int totalSyllables = syllables("tresses");
    print(totalSyllables);
    // String preprocessedPoem = preprocessPoem(poem);
    // List<String> words = preprocessedPoem.split(RegExp(r'\s+|\n'));
    // int totalSyllables = 0;
    // for (String word in words) {
    //   String cleanWord = word.replaceAll(RegExp(r'[^\w\s]'), '');
    //   totalSyllables += syllables(cleanWord);
    // }
    // print(totalSyllables);
    return totalSyllables;
  }

  String findRhyme(String input) {
    List<String> words = input.split(' ');
    if (words.length != 2) {
      // Input should have exactly two words separated by a space.
      return 'Invalid input. Please enter exactly two words separated by a space.';
    }

    String word1 = words[0];
    String word2 = words[1];

    double diceCoefficient = calculateDiceCoefficient(word1, word2);
    print("Dice's Coefficient: $diceCoefficient");

    double rhymeThreshold = 0.5;

    if (diceCoefficient >= rhymeThreshold) {
      return 'The words "$word1" and "$word2" rhyme!';
    } else {
      return 'The words "$word1" and "$word2" do not rhyme.';
    }
  }

  static double calculateDiceCoefficient(String word1, String word2) {
    return StringSimilarity.compareTwoStrings(word1, word2);
  }
}
