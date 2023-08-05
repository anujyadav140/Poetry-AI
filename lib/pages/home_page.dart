import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/color_palette.dart';
import 'package:poetry_ai/components/template_card.dart';
import 'package:poetry_ai/pages/editor.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:rive/rive.dart';
import 'dart:math' as math;
import 'package:wave/config.dart';
import 'package:wave/wave.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class Poem {
  String title;
  String type;
  List<String> features;
  String poetry;
  String meter;
  List<String> bookmarks;

  Poem(this.title, this.type, this.features, this.poetry, this.meter,
      this.bookmarks);
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentPoemIndex = -1;
  late AnimationController _controller;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String user = "";
  String setPoemType = "";
  String setPoemMeter = "";
  ScrollController scrollController = ScrollController();
  final globalThemeBox = Hive.box('myThemeBox');
  final poemListBox = Hive.box('myPoemBox');
  final poemListIndexBox = Hive.box('myPoemListIndexBox');
  PoetryType poetryTypeName = PoetryType("", "", [""], [""], "");
  bool isTemplateClicked = false;
  bool isPoemListNotEmpty = true;
  List<String> features = [""];
  List<String> icons = [""];
  int selectedTemplateIndex = -1;
  List<dynamic>? existingPoemList = [];
  @override
  void initState() {
    currentPoemIndex = poemListIndexBox.get('poemIndex') ?? -1;
    if (firebaseAuth.currentUser?.displayName != null) {
      user = firebaseAuth.currentUser!.displayName!;
    } else {
      user = firebaseAuth.currentUser!.email!;
      String email = user;
      RegExp regex = RegExp(r"^(.+)@.*$");
      String username = regex.firstMatch(email)?.group(1) ?? email;
      user = username;
    }
    globalThemeBox.get('theme');
    super.initState();
    _controller = AnimationController(
      value: 0.0,
      duration: const Duration(seconds: 10),
      upperBound: 1,
      lowerBound: -1,
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void setGlobalTheme(String theme) {
    globalThemeBox.put('theme', theme);
    print(globalThemeBox.get('theme'));
  }

  void deleteGlobalTheme() {
    globalThemeBox.delete('theme');
    print("Deleted");
  }

  List<String> themeList = [
    "Classic",
    "Green",
    "Purple",
  ];

  void setPoemList(String poemTitle, String poemType, List<String> poemFeatures,
      String poetry, String meter, List<String> bookmarks) {
    var poem = Poem(
      poemTitle,
      poemType,
      poemFeatures,
      poetry,
      meter,
      bookmarks,
    );

    poemListBox.add({
      'title': poem.title,
      'type': poem.type,
      'features': poem.features,
      'poem': poem.poetry,
      'meter': poem.meter,
      'bookmarks': poem.bookmarks
    });
  }

  void showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a theme ...'),
          content: SingleChildScrollView(
            child: ListBody(
              children: themeList.map((theme) {
                return ListTile(
                  title: Text(theme),
                  onTap: () {
                    if (theme == "Purple") {
                      setState(() {
                        setGlobalTheme(theme);
                      });
                      print("Purple Theme Selected");
                    } else if (theme == "Green") {
                      setState(() {
                        setGlobalTheme(theme);
                      });
                      print("Green Theme Selected");
                    } else if (theme == "Classic") {
                      setState(() {
                        setGlobalTheme(theme);
                      });
                      print("Classic Theme Selected");
                    }
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeValue = globalThemeBox.get('theme') ?? 'Green';
    void logout() async {
      //show loading
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );
      AuthService().logout();
      //pop the loading
      Navigator.pop(context);
    }

    void onTapTemplate(int index) {
      setState(() {
        if (selectedTemplateIndex == index) {
          selectedTemplateIndex = -1;
          isTemplateClicked = false;
        } else {
          selectedTemplateIndex = index;
          isTemplateClicked = true;
          poetryTypeName = PoetryTypesData.getPoetryTypeByName(
              PoetryTypesData.poetryTypes[index].name);
          setPoemType = PoetryTypesData.poetryTypes[index].name;
          setPoemMeter = PoetryTypesData.poetryTypes[index].metre;
          features = PoetryTypesData.getFeaturesByName(poetryTypeName.name);
          icons = PoetryTypesData.getIconsByName(poetryTypeName.name);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: AutoSizeText(
          "Welcome, $user!",
          minFontSize: 8,
          maxLines: 4,
          style: GoogleFonts.ebGaramond(
            textStyle: TextStyle(
                color: ColorTheme.text(themeValue),
                letterSpacing: .5,
                fontSize: 20),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        actions: [
          PopupMenuButton(
            icon: Icon(
              Icons.menu,
              color: ColorTheme.text(themeValue),
            ),
            onSelected: (value) {
              if (value == 'themes') {
                showThemeDialog(context);
              } else if (value == 'logout') {
                logout();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'themes',
                child: ListTile(
                  leading: Icon(Icons.palette),
                  title: Text("Themes"),
                ),
              ),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Logout"),
                ),
              ),
            ],
          )
        ],
      ),
      backgroundColor: ColorTheme.accent(themeValue),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (int i = 0; i < PoetryTypesData.poetryTypes.length; i++)
                    Template(
                      templateBoxColor: ColorTheme.primary(themeValue),
                      templateSplashColor: ColorTheme.secondary(themeValue),
                      templateUnderlineColor: ColorTheme.accent(themeValue),
                      templateFontColor: ColorTheme.text(themeValue),
                      name: PoetryTypesData.poetryTypes[i].name,
                      description: PoetryTypesData.poetryTypes[i].description,
                      onTap: () => onTapTemplate(i),
                      isSelected: selectedTemplateIndex == i,
                    ),
                ]),
              ),
              SizedBox(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.7,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50.0),
                      topRight: Radius.circular(50.0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                    child: ClipPath(
                      child: Container(
                        color: ColorTheme.secondary(themeValue),
                        child: isTemplateClicked
                            ? SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20.0,
                                        vertical: 10.0,
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            poetryTypeName.description,
                                            style: GoogleFonts.ebGaramond(
                                              textStyle: TextStyle(
                                                color:
                                                    ColorTheme.text(themeValue),
                                                letterSpacing: .5,
                                                fontSize: 15,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            "Features for ${poetryTypeName.name}:",
                                            style: GoogleFonts.ebGaramond(
                                              textStyle: TextStyle(
                                                color:
                                                    ColorTheme.text(themeValue),
                                                letterSpacing: .5,
                                                fontSize: 17,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Scrollbar(
                                        controller: scrollController,
                                        thumbVisibility: true,
                                        child: ListView.builder(
                                          controller: scrollController,
                                          itemCount: features.length,
                                          itemBuilder: (context, index) {
                                            return Column(
                                              children: [
                                                ListTile(
                                                  leading: SizedBox(
                                                    width: 50,
                                                    height: 50,
                                                    child: Image.asset(
                                                        icons[index]),
                                                  ),
                                                  title: Text(
                                                    features[index],
                                                    style:
                                                        GoogleFonts.ebGaramond(
                                                      textStyle: TextStyle(
                                                        color: ColorTheme.text(
                                                            themeValue),
                                                        letterSpacing: .5,
                                                        fontSize: 15,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                if (index !=
                                                    features.length - 1)
                                                  const Divider(
                                                    height: 1,
                                                    color: Colors.grey,
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : poemListBox.isNotEmpty
                                ? Scrollbar(
                                    controller: scrollController,
                                    thumbVisibility: true,
                                    thickness: 5.0,
                                    child: ListView.builder(
                                      controller: scrollController,
                                      itemCount: poemListBox.length,
                                      itemBuilder: (context, index) {
                                        var poemData = poemListBox.getAt(index)
                                            as Map<dynamic, dynamic>;
                                        String poemTitle =
                                            poemData['title'] as String;
                                        String poemForm =
                                            poemData['type'] as String;
                                        List<String> poemFeatures =
                                            poemData['features']
                                                as List<String>;
                                        String poemMeter =
                                            poemData['meter'] as String;
                                        return Slidable(
                                          key: const ValueKey(0),
                                          endActionPane: ActionPane(
                                            motion: const ScrollMotion(),
                                            children: [
                                              SlidableAction(
                                                onPressed: (context) {},
                                                backgroundColor:
                                                    const Color(0xFF21B7CA),
                                                foregroundColor: Colors.white,
                                                icon: Icons.share,
                                                label: 'Share',
                                              ),
                                              SlidableAction(
                                                onPressed: (context) {
                                                  setState(() {
                                                    poemListBox.deleteAt(index);
                                                    currentPoemIndex--;
                                                    poemListIndexBox.put(
                                                        'poemIndex',
                                                        currentPoemIndex);
                                                  });
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      backgroundColor:
                                                          ColorTheme.accent(
                                                              themeValue),
                                                      content: Text(
                                                        '$poemTitle deleted.',
                                                        style: TextStyle(
                                                            color:
                                                                ColorTheme.text(
                                                                    themeValue)),
                                                      ),
                                                      action: SnackBarAction(
                                                        backgroundColor:
                                                            ColorTheme.primary(
                                                                themeValue),
                                                        label: 'Undo',
                                                        textColor:
                                                            ColorTheme.text(
                                                                themeValue),
                                                        onPressed: () {
                                                          setState(() {
                                                            poemListBox
                                                                .add(poemData);
                                                          });
                                                        },
                                                      ),
                                                    ),
                                                  );
                                                },
                                                backgroundColor:
                                                    const Color(0xFFFE4A49),
                                                foregroundColor: Colors.white,
                                                icon: Icons.delete,
                                                label: 'Delete',
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Material(
                                                child: ListTile(
                                                  trailing: IconButton(
                                                    onPressed: () {
                                                      showDialog(
                                                        barrierDismissible:
                                                            true,
                                                        context: context,
                                                        builder: (context) {
                                                          String editedTitle =
                                                              poemTitle;
                                                          return Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8.0), // Add border radius here
                                                            ),
                                                            child: AlertDialog(
                                                              title: const Text(
                                                                  "Edit the poem title:"),
                                                              content: Column(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  // WaveWidget(
                                                                  //   config:
                                                                  //       CustomConfig(
                                                                  //     gradients: [
                                                                  //       [
                                                                  //         Colors
                                                                  //             .blue,
                                                                  //         Colors
                                                                  //             .blue
                                                                  //             .shade200
                                                                  //       ],
                                                                  //       [
                                                                  //         Colors
                                                                  //             .blue
                                                                  //             .shade200,
                                                                  //         Colors
                                                                  //             .blue
                                                                  //             .shade100
                                                                  //       ],
                                                                  //     ],
                                                                  //     durations: [
                                                                  //       3500,
                                                                  //       5000
                                                                  //     ],
                                                                  //     heightPercentages: [
                                                                  //       0.05,
                                                                  //       0.1
                                                                  //     ],
                                                                  //   ),
                                                                  //   waveAmplitude:
                                                                  //       0,
                                                                  //   backgroundColor:
                                                                  //       Colors
                                                                  //           .transparent,
                                                                  //   size: Size(
                                                                  //       double
                                                                  //           .infinity,
                                                                  //       80.0),
                                                                  // ),
                                                                  // SizedBox(
                                                                  //     height:
                                                                  //         16.0),
                                                                  TextField(
                                                                    onChanged:
                                                                        (value) {
                                                                      editedTitle =
                                                                          value;
                                                                    },
                                                                    decoration:
                                                                        InputDecoration(
                                                                      hintText:
                                                                          "Poem Name",
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                        borderSide:
                                                                            const BorderSide(color: Colors.grey),
                                                                      ),
                                                                      filled:
                                                                          true,
                                                                      fillColor:
                                                                          Colors
                                                                              .grey[200],
                                                                      contentPadding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        vertical:
                                                                            12.0,
                                                                        horizontal:
                                                                            16.0,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              actions: [
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child: const Text(
                                                                      "Cancel"),
                                                                ),
                                                                TextButton(
                                                                  onPressed:
                                                                      () {
                                                                    setState(
                                                                        () {
                                                                      var poemData = poemListBox
                                                                          .getAt(
                                                                              index) as Map<
                                                                          dynamic,
                                                                          dynamic>;
                                                                      poemData[
                                                                              'title'] =
                                                                          editedTitle;
                                                                      poemListBox.putAt(
                                                                          index,
                                                                          poemData);
                                                                    });
                                                                    Navigator.pop(
                                                                        context);
                                                                  },
                                                                  child:
                                                                      const Text(
                                                                          "Save"),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      );
                                                    },
                                                    icon:
                                                        const Icon(Icons.edit),
                                                  ),
                                                  title: Text(poemTitle),
                                                  tileColor:
                                                      ColorTheme.secondary(
                                                          themeValue),
                                                  onTap: () {
                                                    // print(poemIndex);
                                                    Navigator.pushReplacement(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    PoetryEditor(
                                                                      editorAppbarColor:
                                                                          ColorTheme.accent(
                                                                              themeValue),
                                                                      editorFontColor:
                                                                          ColorTheme.text(
                                                                              themeValue),
                                                                      editorPrimaryColor:
                                                                          ColorTheme.primary(
                                                                              themeValue),
                                                                      poemIndex:
                                                                          index,
                                                                    )));
                                                  },
                                                  splashColor:
                                                      ColorTheme.accent(
                                                          themeValue),
                                                ),
                                              ),
                                              if (index !=
                                                  poemListBox.length - 1)
                                                const Divider(
                                                  height: 1,
                                                  color: Colors.grey,
                                                ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  )
                                : Column(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width,
                                        height: 300,
                                        child: RiveAnimation.asset(
                                            ColorTheme.riveEmptyListAnimation(
                                                themeValue)),
                                      ),
                                      Text(
                                        "You haven't written any poetry yet ...",
                                        style: GoogleFonts.ebGaramond(
                                          textStyle: TextStyle(
                                              color:
                                                  ColorTheme.text(themeValue),
                                              letterSpacing: .5,
                                              fontSize: 18),
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ClipPath(
                    clipper: DrawClip(_controller.value),
                    child: SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: Container(
                        color: ColorTheme.secondary(themeValue),
                      ),
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorTheme.accent(themeValue),
        onPressed: () {
          if (isTemplateClicked) {
            int newPoemIndex = currentPoemIndex + 1;
            poemListIndexBox.put('poemIndex', newPoemIndex);
            var setPoemTitle =
                "Untitled-${poemListIndexBox.get('poemIndex')}  $setPoemType";
            setPoemList(
                setPoemTitle, setPoemType, features, "", setPoemMeter, []);
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => PoetryEditor(
                          editorAppbarColor: ColorTheme.accent(themeValue),
                          editorFontColor: ColorTheme.text(themeValue),
                          editorPrimaryColor: ColorTheme.primary(themeValue),
                          poemIndex: newPoemIndex,
                        )));
          } else {
            print("select a template!");
          }
        },
        child: Icon(
          Icons.add,
          color: ColorTheme.text(themeValue),
        ),
      ),
    );
  }
}

class DrawClip extends CustomClipper<Path> {
  double move = 0;
  double slice = math.pi;
  DrawClip(this.move);
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height * 0.8);
    double xCenter =
        size.width * 0.5 + (size.width * 0.6 + 1) * math.sin(move * slice);
    double yCenter = size.height * 0.8 + 69 * math.cos(move * slice);
    path.quadraticBezierTo(xCenter, yCenter, size.width, size.height * 0.8);

    path.lineTo(size.width, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return true;
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    return Path()
      ..lineTo(0, size.height)
      ..quadraticBezierTo(
          size.width / 4, size.height - 40, size.width / 2, size.height - 20)
      ..quadraticBezierTo(
          3 / 4 * size.width, size.height, size.width, size.height - 30)
      ..lineTo(size.width, 0);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
