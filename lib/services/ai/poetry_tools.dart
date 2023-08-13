import 'dart:convert';

import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/services.dart';


class PoetryTools {
  late String url;
  late var data;
  final String? key = dotenv.env['OPENAI_API_KEY'];
  // final llm = OpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 0.9);

  Future<String> rhymeSchemePatternFinder(String poem) async {
    print(poem);
    return "";
  }

  Future<String> poeticMetreFinder(String poem) async {
    final chat = ChatOpenAI(apiKey: key, temperature: 0.9);
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

  Future<String> generateQuickLines(
      String previousLine,
      List<String> previousLines,
      List<String> nextLines,
      List<String> features) async {
    print(previousLine);
    final openai = OpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 1);
    final String form = features[0];
    final String syllables = features[1];
    final String rhyme = features[2];
    const multipleMetreFormatInput = PromptTemplate(
      inputVariables: {
        'previousLine',
        'previousLines',
        'nextLines',
        'form',
        'syllables',
        'rhyme'
      },
      template:
          '''You are a helpful AI poet. You have to generate poetry lines from the current line. 
          These are the previous lines: {previousLines}, 
          these are the next lines: {nextLines}.
          These are the rules you should follow strictly:
          1. The form should be: {form}; 
          2. Count the syllables make sure they are EXACTLY {syllables}, the syllable count should be exactly {syllables}'
          3. The rhyme scheme pattern should be strictly: {rhyme}.
          Generate exactly between 5 to 8 lines (NOT MORE THAN THAT!), without labelling or numbering them''',
    );
    print(multipleMetreFormatInput.format({
      'previousLine': previousLine,
      'previousLines': previousLines,
      'nextLines': nextLines,
      'form': form,
      'syllables': syllables,
      'rhyme': rhyme
    }));
    final chain = LLMChain(llm: openai, prompt: multipleMetreFormatInput);
    final res = await chain.run({
      'previousLine': previousLine,
      'previousLines': previousLines,
      'nextLines': nextLines,
      'form': form,
      'syllables': syllables,
      'rhyme': rhyme
    });
    return res;
  }

  Future<String> changeLinesToFollowMetre(
      String lines, String metreFeature) async {
    // final openai =
    //     OpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 0.9);
    final chat =
        ChatOpenAI(apiKey: dotenv.env['OPENAI_API_KEY'], temperature: 1);
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
          '''You are a helpful poetry tutor that helps the student in converting the following lines: "{lines}" of poetry to {metreFeature};
           you make sure the "{lines}" follow the required {metreFeature} metre, without chaning the meaning of the lines''',
    );
    print(multipleMetreFormatInput
        .format({'metreFeature': metreFeature, 'lines': lines}));
    final chain = LLMChain(llm: chat, prompt: multipleMetreFormatInput);
    final res = await chain.run({
      'lines': lines,
      'metreFeature': metreFeature,
    });
    return res;
  }
}
