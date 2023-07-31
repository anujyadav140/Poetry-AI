import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:english_words/english_words.dart';
import 'package:poetry_ai/services/ai/tools/rhyme_tool.dart';
import 'package:string_similarity/string_similarity.dart';

class PoetryTools {
  // final llm = OpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 0.9);
  final llm = ChatOpenAI(
    apiKey: dotenv.env['OPENAI_API_KEY'],
    model: 'gpt-3.5-turbo-0613',
    temperature: 0,
  );
  Future<void> rhymeAgent() async {
    final tool = RhymeTool();
    final tools = [tool];
    final agent = OpenAIFunctionsAgent.fromLLMAndTools(llm: llm, tools: tools);
    final executor = AgentExecutor(agent: agent, tools: tools);
    final res = await executor.run(
        'What is the rhyme for the words SNEED and FEED? Look at the dice coefficient from the tool agent and give your own analysis on it');
    print(res);
    // final usage = result.usage;
    // print(usage?.promptTokens);
    // print(usage?.responseTokens);
    // print(usage?.totalTokens);
  }

  Future<Map<String, String>> parseCmuDict() async {
    try {
      final cmuDictAsset =
          await rootBundle.loadString('assets/data/cmudict.dict');
      final cmuDictLines = cmuDictAsset.split('\n');

      final Map<String, String> wordToPronunciation = {};

      for (var line in cmuDictLines) {
        line = line.trim();

        if (line.startsWith(';;;') || line.isEmpty) {
          continue;
        }

        final parts = line.split(RegExp(r'\s+'));
        if (parts.isNotEmpty) {
          final word = parts[0].toLowerCase();
          final pronunciation = parts.skip(1).join(' ');

          wordToPronunciation[word] = pronunciation;
        }
      }

      return wordToPronunciation;
    } catch (e) {
      print("Error parsing CMUdict: $e");
      return {};
    }
  }

  void findRhymeScheme() {
    String input = """
    Shall I compare thee to a summer’s day?
    Thou art more lovely and more temperate:
    Rough winds do shake the darling buds of May,
    And summer’s lease hath all too short a date;
    Sometime too hot the eye of heaven shines,
    And often is his gold complexion dimm'd;
    And every fair from fair sometime declines,
    By chance or nature’s changing course untrimm'd;
    But thy eternal summer shall not fade,
    Nor lose possession of that fair thou ow’st;
    Nor shall death brag thou wander’st in his shade,
    When in eternal lines to time thou grow’st:
    So long as men can breathe or eyes can see,
    So long lives this, and this gives life to thee.
  """;

    List<String> lastWordsList = extractLastWords(input);
    List<String> rhymingPairs = findRhymingPairs(lastWordsList);

    print("Rhyming Pairs:");
    rhymingPairs.forEach((pair) {
      print(pair);
    });
  }

  List<String> extractLastWords(String input) {
    List<String> lines = input.split('\n');

    // Remove leading and trailing whitespaces from each line and extract last word
    List<String> lastWordsList = lines.map((line) {
      String trimmedLine = line.trim();
      List<String> words = trimmedLine.split(' ');
      return words.isNotEmpty ? words.last : "";
    }).toList();

    return lastWordsList;
  }

  List<String> findRhymingPairs(List<String> lastWordsList) {
    List<String> rhymingPairs = [];

    for (int i = 0; i < lastWordsList.length - 1; i++) {
      for (int j = i + 1; j < lastWordsList.length; j++) {
        double similarity =
            calculateDiceCoefficient(lastWordsList[i], lastWordsList[j]);
        if (similarity >= 0.3) {
          // You can adjust the threshold value (0.5) as per your preference.
          String pair = "${lastWordsList[i]} - ${lastWordsList[j]}";
          rhymingPairs.add(pair);
        }
      }
    }

    return rhymingPairs;
  }

  double calculateDiceCoefficient(String word1, String word2) {
    return StringSimilarity.compareTwoStrings(word1, word2);
  }

  // String findRhyme(String word1, String word2) {
  //   double diceCoefficient = calculateDiceCoefficient(word1, word2);
  //   print("Dice's Coefficient: $diceCoefficient");

  //   double rhymeThreshold = 0.5;

  //   if (diceCoefficient >= rhymeThreshold) {
  //     return 'The words "$word1" and "$word2" rhyme!';
  //   } else {
  //     return 'The words "$word1" and "$word2" do not rhyme.';
  //   }
  // }

  String findStressPattern(String sentence, Map<String, String> cmuDict) {
    sentence = sentence.replaceAll(RegExp(r'[^A-Za-z ]'), "").toLowerCase();
    print(sentence);
    final words = sentence.split(' ');
    String stressPattern = '';

    for (var word in words) {
      final pronunciation = cmuDict[word];
      if (pronunciation != null) {
        final syllables = pronunciation.split(' ');
        for (var syllable in syllables) {
          if (syllable.endsWith('1')) {
            stressPattern += '1'; // Stressed syllable
          } else if (syllable.endsWith('0')) {
            stressPattern += '0'; // Unstressed syllable
          }
        }
      } else {
        // Word not found in the dictionary, stress the first syllable.
        stressPattern += '1';
      }
    }

    return stressPattern;
  }

  Future<void> helloWorld(String text) async {
    final openai =
        OpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 0.9);
    final result = await openai.generate(text);
    print(text);
    print(result);
    final usage = result.usage;
    print(usage?.promptTokens);
    print(usage?.responseTokens);
    print(usage?.totalTokens);
  }
}
