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
    RhymeTool().countTotalSyllables();
    print(poem);
    // final chat = ChatOpenAI(
    //   model: 'gpt-3.5-turbo',
    //   apiKey: dotenv.env['OPENAI_API_KEY'],
    //   temperature: 0.9,
    // );
    // const template =
    //     '''You are a helpful poetry tutor that helps in finding the rhyme scheme of the poem''';
    // final systemMessagePrompt =
    //     SystemChatMessagePromptTemplate.fromTemplate(template);
    // const humanTemplate = '{poem}';
    // final humanMessagePrompt =
    //     HumanChatMessagePromptTemplate.fromTemplate(humanTemplate);
    // final chatPrompt = ChatPromptTemplate.fromPromptMessages(
    //     [systemMessagePrompt, humanMessagePrompt]);
    // final chain = LLMChain(llm: chat, prompt: chatPrompt);
    // final res = await chain.run({'poem': poem});
    return "";
  }

  Future<String> poeticMetreFinder(String poem) async {
    final chat =
        ChatOpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 0.9);
    const template =
        '''You are a helpful poetry tutor that highlights the metre of a given {poem},'
        return the whole poem- for stressed syllables uppercase the syllables & for unstressed lowercase;
        write few sentences talking about it''';
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

  Future<String> reviewTheFeatures(String poem, List<String> features) async {
    final chat =
        ChatOpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 1);
    const template =
        '''You are a helpful poetry tutor that guides the user to follow the correct poetry features.
         These are the features in a list: {features}
         try to make sure your student follows the features for the {poem}''';
    final systemMessagePrompt =
        SystemChatMessagePromptTemplate.fromTemplate(template);
    const humanTemplate = '{poem}';
    final humanMessagePrompt =
        HumanChatMessagePromptTemplate.fromTemplate(humanTemplate);
    final chatPrompt = ChatPromptTemplate.fromPromptMessages(
        [systemMessagePrompt, humanMessagePrompt]);
    final chain = LLMChain(llm: chat, prompt: chatPrompt);
    final res = await chain.run({
      'poem': poem,
      'features': features,
    });
    return res;
  }

  Future<String> rhymeTwoSelectedLines(List<String> selectedLines) async {
    final chat =
        ChatOpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 1);
    const template =
        '''You are a helpful poetry tutor that helps the student in rhyming two lines of poetry; you rhyme these {selectedLines}, 
        rhyme these lines without changing the meaning, metre, structure of the two lines, return two lines which totally rhyme''';
    final systemMessagePrompt =
        SystemChatMessagePromptTemplate.fromTemplate(template);
    final chatPrompt =
        ChatPromptTemplate.fromPromptMessages([systemMessagePrompt]);
    final chain = LLMChain(llm: chat, prompt: chatPrompt);
    final res = await chain.run({
      'selectedLines': selectedLines,
    });
    return res;
  }

  Future<String> changeLinesToFollowMetre(
      String lines, String metreFeature) async {
    final openai =
        OpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 0.9);
    // final chat =
    //     ChatOpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 1);
    // const template =
    //     '''You are a helpful poetry tutor that helps the student in correcting the lines of poetry; you make sure the lines follow the
    //     required {metreFeature} without changing the whole meaning of the lines''';
    // final systemMessagePrompt =
    //     SystemChatMessagePromptTemplate.fromTemplate(template);
    // const humanTemplate = '{lines}';
    // final humanMessagePrompt =
    //     HumanChatMessagePromptTemplate.fromTemplate(humanTemplate);
    // final chatPrompt = ChatPromptTemplate.fromPromptMessages(
    //     [systemMessagePrompt, humanMessagePrompt]);
    // final chain = LLMChain(llm: chat, prompt: chatPrompt);
    // final res = await chain.run({
    //   'lines': lines,
    //   'metreFeature': metreFeature,
    // });
    // return res;
    // An example prompt with one input variable
    // const oneInputPrompt = PromptTemplate(
    //   inputVariables: {'metreFeature'},
    //   template:
    //       '''You are a helpful poetry tutor that helps the student in correcting the lines of poetry; you make sure the lines follow the
    //  required {metreFeature} without changing the whole meaning of the lines''',
    // );
    // print(oneInputPrompt.format({'metreFeature': 'Iambic Pentameter'}));

// An example prompt with multiple input variables
    const multipleMetreFormatInput = PromptTemplate(
      inputVariables: {'lines', 'metreFeature'},
      template:
          '''You are a helpful poetry tutor that helps the student in correcting the lines of poetry; you make sure the {lines} follow the
     required {metreFeature} without changing the whole meaning of the lines''',
    );
    final chain = LLMChain(llm: openai, prompt: multipleMetreFormatInput);
    final res = await chain.run({
      'lines': lines,
      'metreFeature': metreFeature,
    });
    return res;
  }
}
