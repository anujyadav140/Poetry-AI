import 'package:flutter/material.dart';

class PoetryType {
  String name;
  String description;
  List<String> features;

  PoetryType(this.name, this.description, this.features);
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
    ),
    PoetryType(
      'Haiku',
      'A traditional form of Japanese poetry with 17 syllables in a 5-7-5 pattern. Often focusing on nature and seasonal changes.',
      [
        '17 syllables in a 5-7-5 pattern',
        'Focuses on nature and seasonal changes',
      ],
    ),
    PoetryType(
      'Limerick',
      'A humorous five-line poem with a distinct rhythm pattern (AABBA) and usually featuring witty or nonsensical content.',
      [
        'Five lines with a distinct AABBA rhyme pattern',
        'Usually humorous and witty',
      ],
    ),
    PoetryType(
      'Free Verse',
      'A type of poetry that doesn\'t follow a specific rhyme scheme or meter. It allows poets more freedom in their expression.',
      [
        'No specific rhyme scheme or meter',
        'Offers poets more creative freedom',
      ],
    ),
    PoetryType(
      'Ballad',
      'A narrative poem that tells a story, often in quatrains with a rhyme scheme of ABAB and alternating tetrameter and trimeter lines.',
      [
        'Narrative poem that tells a story',
        'Quatrains with ABAB rhyme scheme',
        'Alternating tetrameter and trimeter lines',
      ],
    ),
    PoetryType(
      'Ode',
      'A lyrical poem that celebrates or pays tribute to a person, event, or object. Odes often express deep emotions and employ a formal tone.',
      [
        'Lyrical poem that celebrates or pays tribute',
        'Expresses deep emotions',
        'Employs a formal tone',
      ],
    ),
    PoetryType(
      'Prose Poetry',
      'A lyrical poem that celebrates or pays tribute to a person, event, or object. Odes often express deep emotions and employ a formal tone.',
      [
        'Combines elements of prose and poetry',
        'No specific rhyme or meter',
        'More like a paragraph with poetic language',
      ],
    ),
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
}

class Template extends StatelessWidget {
  final Color templateBoxColor;
  final Color templateSplashColor;
  final String name;
  final bool isSelected;
  final String description;
  final void Function()? onTap;

  const Template({
    super.key,
    required this.templateBoxColor,
    required this.templateSplashColor,
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
            borderRadius: BorderRadius.circular(20.0),
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
            height: 200,
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              children: [
                Text(name),
                Text(description),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
