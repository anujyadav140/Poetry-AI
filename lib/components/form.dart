import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class TemplateForm extends StatefulWidget {
  const TemplateForm({super.key});

  @override
  State<TemplateForm> createState() => _TemplateFormState();
}

class _TemplateFormState extends State<TemplateForm> {
  List<String> poeticForms = ["Quartrain", "Couplet", "Free Verse"];
  int selectedRadio = 0;
  final List<String> rhymeSchemeList = <String>[
    'ABAB',
    'AABB',
    'ABBA',
    'ABCB',
    'None'
  ];
  String dropdownRhyme = "ABAB";

  final List<String> syllableCountList = <String>[
    'Any',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];
  String dropdownSyllableCount = "10";

  Map<String, Map<String, String>> formDescriptions = {
    "Quartrain": {
      "Description":
          "Quatrain is a poem in which its stanzas are composed of 4 lines of verse, often with a rhyming schema.",
      "Sample Poem":
          "Love is the dear heart amid the flowers,\nSweet as a light in a beating meadow,\nHurried by her from her earthly hour,\nHopeless the raging tempest of her woe."
    },
    "Couplet": {
      "Description":
          "Couplet is a poem in which its stanzas are composed of 2 rhyming lines of verse.",
      "Sample Poem":
          "Thou shalt not win the music of thy life,\nAn infinite within the world's mad strife.\n An infinite conflict, a shifting stream,\nLove after a cloud, like a baleful dream."
    },
    "Free Verse": {
      "Description":
          "Free verse is a poem that is free of rules, such as no distinct rhyme pattern.",
      "Sample Poem":
          "I celebrate myself, and sing myself,\nAnd what I assume you shall assume,\nFor every atom belonging to me as good belongs to you."
    }
  };

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: Column(
              children: [
                Text(
                  "description",
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.black,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily),
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Poetic Form:",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontFamily: GoogleFonts.ebGaramond().fontFamily,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Column(
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: poeticForms.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 10.0),
                                child: Column(
                                  children: [
                                    Radio(
                                      fillColor: const MaterialStatePropertyAll(
                                          Colors.black),
                                      value: index,
                                      groupValue: selectedRadio,
                                      onChanged: (val) {
                                        setSelectedRadio(val!);
                                      },
                                    ),
                                    Text(
                                      poeticForms[index],
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                              color: Colors.black,
                                              fontFamily:
                                                  GoogleFonts.ebGaramond()
                                                      .fontFamily,
                                              fontWeight: index == selectedRadio
                                                  ? FontWeight.bold
                                                  : FontWeight.normal),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        Visibility(
                          visible: selectedRadio == selectedRadio,
                          child: Column(
                            children: [
                              Text(
                                formDescriptions[poeticForms[selectedRadio]]
                                        ?["Description"] ??
                                    "",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontFamily: GoogleFonts.ebGaramond()
                                            .fontFamily),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                formDescriptions[poeticForms[selectedRadio]]
                                        ?["Sample Poem"] ??
                                    "",
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(
                                        color: Colors.black,
                                        fontFamily: GoogleFonts.ebGaramond()
                                            .fontFamily),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Syllable Count:",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontFamily: GoogleFonts.ebGaramond().fontFamily,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "The number of syllables for each line of verse",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.black,
                                fontFamily: GoogleFonts.ebGaramond().fontFamily,
                                fontWeight: FontWeight.normal),
                      ),
                    ),
                    DropdownButton(
                      menuMaxHeight: 300.0,
                      items: syllableCountList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      value: dropdownSyllableCount,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontFamily: GoogleFonts.ebGaramond().fontFamily,
                          fontWeight: FontWeight.normal),
                      onChanged: (String? value) {
                        setState(() {
                          dropdownSyllableCount = value!;
                        });
                      },
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Column(
                  children: [
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "Rhyme:",
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: Colors.black,
                            fontFamily: GoogleFonts.ebGaramond().fontFamily,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Container(
                      alignment: Alignment.topLeft,
                      child: Text(
                        "The letters indicate which lines of the poem rhyme",
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                color: Colors.black,
                                fontFamily: GoogleFonts.ebGaramond().fontFamily,
                                fontWeight: FontWeight.normal),
                      ),
                    ),
                    DropdownButton(
                      menuMaxHeight: 300.0,
                      items: rhymeSchemeList
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.black,
                          fontFamily: GoogleFonts.ebGaramond().fontFamily,
                          fontWeight: FontWeight.normal),
                      value: dropdownRhyme,
                      onChanged: (String? value) {
                        setState(() {
                          dropdownRhyme = value!;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
