import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:english_words/english_words.dart';
import 'package:string_similarity/string_similarity.dart';

class PoetryTools {
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

  String findRhyme(String word1, String word2) {
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

  final openAiKey = dotenv.env['OPENAI_API_KEY'];
  Future<void> helloWorld(String text) async {
    final openai = OpenAI(apiKey: openAiKey, temperature: 0.9);
    final result = await openai.generate(text);
    print(text);
    print(result);
    final usage = result.usage;
    print(usage?.promptTokens);
    print(usage?.responseTokens);
    print(usage?.totalTokens);
  }
}
