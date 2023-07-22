import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poetry_ai/components/color_palette.dart';

class PoetryType {
  String name;
  String description;
  List<String> features;
  List<String> icons;
  PoetryType(this.name, this.description, this.features, this.icons);
}

class PoetryTypesData {
  static List<PoetryType> poetryTypes = [
    PoetryType(
      'Sonnet',
      'A 14-line poem, usually written in iambic pentameter, with various rhyme schemes. Examples include the Shakespearean and Petrarchan sonnets.',
      [
        '14 lines in length',
        'Usually written in iambic pentameter',
        'Various rhyme schemes (Shakespearean and Petrarchan)',
      ],
      [
        'images/lines.png',
        'images/meter.png',
        'images/rhyme.png',
      ],
    ),
    PoetryType(
      'Haiku',
      'A traditional form of Japanese poetry with 17 syllables in a 5-7-5 pattern. Often focusing on nature and seasonal changes.',
      [
        'It has 3 lines; total 17 syllables in a 5-7-5 syllable pattern',
        'Focuses on nature and seasonal changes',
        'No specific rhyme scheme (Traditionally, haikus do not have a rhyme pattern)',
      ],
      [
        'images/lines.png',
        'images/cherry-blossom.png',
        'images/rhyme.png',
      ],
    ),
    PoetryType(
      'Blank Verse',
      'Blank verse is poetry written with regular metrical but unrhymed lines, almost always in iambic pentameter.',
      [
        'Each line typically contains ten syllables with alternating stressed and unstressed syllables (iambic pentameter).',
        'There is no Rhyme. The absence of rhyme allows for a natural and conversational flow.',
        'First used in English drama by Christopher Marlowe and popularized by William Shakespeare.',
      ],
      [
        'images/meter.png',
        'images/rhyme.png',
        'images/poetry.png',
      ],
    ),
    PoetryType(
      'Limerick',
      'A humorous five-line poem with a distinct rhythm pattern (AABBA) and usually featuring witty or nonsensical content.',
      [
        'The rhythm often follows anapestic meter (da-da-DUM)',
        'Five lines with a distinct AABBA rhyme pattern',
        'Usually humorous and witty',
      ],
      [
        'images/meter.png',
        'images/rhyme.png',
        'images/laughing.png',
      ],
    ),
    PoetryType(
      'Free Verse',
      'A type of poetry that doesn\'t follow a specific rhyme scheme or meter. It allows poets more freedom in their expression.',
      [
        'No specific rhyme scheme or meter',
        'Offers poets more creative freedom',
        'The poem\'s structure is open-ended, without any strict rules.',
      ],
      [
        'images/rhyme.png',
        'images/poetry.png',
        'images/lines.png',
      ],
    ),
    PoetryType(
      'Ballad',
      'A narrative poem that tells a story, often in quatrains with a rhyme scheme of ABAB and alternating tetrameter and trimeter lines.',
      [
        'Narrative poem that tells a story',
        'Typically written in quatrains (four-line stanzas)',
        'Rhyme scheme of ABAB',
        'Alternating lines with tetrameter (eight syllables) and trimeter (six syllables)',
      ],
      [
        'images/dante.png',
        'images/lines.png',
        'images/rhyme.png',
        'images/meter.png',
      ],
    ),
    PoetryType(
      'Couplet',
      'A couplet poem consists of two lines, making it a very short form of poetry. Since it comprises only two lines, a couplet can be as brief as just a few words or as long as a few sentences, depending on the poet\'s intention and the message they want to convey.',
      [
        'A Couplet consists of two lines but can also be combined into a multiple-line poem',
        'Typically rhymed, with various rhyme schemes possible; like AABB Or AA, BB, CC Or ABAB',
        'Can have a uniform meter or follow the meter of the overall poem.',
      ],
      [
        'images/lines.png',
        'images/rhyme.png',
        'images/meter.png',
      ],
    ),
    PoetryType(
      'Prose Poetry',
      'A lyrical poem that celebrates or pays tribute to a person, event, or object. Odes often express deep emotions and employ a formal tone.',
      [
        'Combines elements of prose and poetry',
        'No specific rhyme or meter',
        'More like a paragraph with poetic language and imagery',
      ],
      [
        'images/lines.png',
        'images/meter.png',
        'images/book.png',
      ],
    )
  ];

  static PoetryType getPoetryTypeByName(String name) {
    return poetryTypes.firstWhere(
      (poetryType) => poetryType.name == name,
    );
  }

  static List<String> getFeaturesByName(String name) {
    PoetryType poetryType = getPoetryTypeByName(name);
    return poetryType.features;
  }

  static List<String> getIconsByName(String name) {
    PoetryType poetryType = getPoetryTypeByName(name);
    return poetryType.icons;
  }
}

class Template extends StatelessWidget {
  final Color templateBoxColor;
  final Color templateSplashColor;
  final Color templateUnderlineColor;
  final Color templateFontColor;
  final String name;
  final bool isSelected;
  final String description;
  final void Function()? onTap;

  const Template({
    super.key,
    required this.templateBoxColor,
    required this.templateSplashColor,
    required this.templateFontColor,
    required this.templateUnderlineColor,
    required this.name,
    required this.description,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8.0,
        left: 10.0,
        bottom: 15.0,
        right: 10.0,
      ),
      child: InkWell(
        splashColor: templateSplashColor,
        borderRadius: BorderRadius.circular(20.0),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: isSelected
                ? templateBoxColor.withOpacity(0.8)
                : templateBoxColor,
            borderRadius: BorderRadius.circular(10.0),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: SizedBox(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.5,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 15.0),
                      child: Container(
                        height: isSelected ? 25 : 15,
                        width: calculateContainerWidth(name, context),
                        color: templateUnderlineColor,
                      ),
                    ),
                    Text(
                      name,
                      style: GoogleFonts.ebGaramond(
                        textStyle: TextStyle(
                            color: templateFontColor,
                            letterSpacing: .5,
                            fontSize: 24),
                      ),
                    ),
                  ],
                ),
                // Text(description),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

double calculateContainerWidth(String text, BuildContext context) {
  final textSpan = TextSpan(text: text, style: const TextStyle(fontSize: 21));
  final textPainter = TextPainter(
    text: textSpan,
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();
  final textWidth = textPainter.width;
  final screenWidth = MediaQuery.of(context).size.width;
  return textWidth +
      screenWidth * 0.11; // You can adjust the multiplier as needed
}
