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
        'What is the rhyme for the words Sigh and I? Look at the dice coefficient from the tool agent and give your own analysis on it');
    print(res);
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

  Future<String> rhymeSchemePatternFinder(String poem) async {
    print(poem);
    final chat = ChatOpenAI(
      model: 'gpt-3.5-turbo',
      apiKey: dotenv.env['OPENAI_API_KEY'],
      temperature: 0.9,
    );
    const template =
        '''You are a helpful poetry tutor that helps in finding the words that rhyme together from the given poem, only return pairs''';
    final systemMessagePrompt =
        SystemChatMessagePromptTemplate.fromTemplate(template);
    const humanTemplate = '{poem}';
    final humanMessagePrompt =
        HumanChatMessagePromptTemplate.fromTemplate(humanTemplate);
    final chatPrompt = ChatPromptTemplate.fromPromptMessages(
        [systemMessagePrompt, humanMessagePrompt]);
    final chain = LLMChain(llm: chat, prompt: chatPrompt);
    final res = await chain.run({'poem': poem});
    return res;
  }

  Future<String> poeticMetreFinder(String poem) async {
    final chat =
        ChatOpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 0.9);
    const template =
        '''You are a helpful poetry tutor that highlights the metre of a given poem,'
        return the whole poem- for stressed syllables uppercase the syllables & for unstressed lowercase''';
    final systemMessagePrompt =
        SystemChatMessagePromptTemplate.fromTemplate(template);
    const humanTemplate = '{poem}';
    final humanMessagePrompt =
        HumanChatMessagePromptTemplate.fromTemplate(humanTemplate);
    final chatPrompt = ChatPromptTemplate.fromPromptMessages(
        [systemMessagePrompt, humanMessagePrompt]);
    final chain = LLMChain(llm: chat, prompt: chatPrompt);
    final res = await chain.run({'poem': poem});
    return res;
  }
}
