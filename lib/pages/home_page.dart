import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:poetry_ai/components/color_palette.dart';
import 'package:poetry_ai/components/template_card.dart';
import 'package:poetry_ai/pages/editor.dart';
import 'package:poetry_ai/services/authentication/auth_service.dart';
import 'package:rive/rive.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String user = "";
  final _myBox = Hive.box('myBox');
  final globalThemeBox = Hive.box('myThemeBox');
  PoetryType poetryTypeName = PoetryType("", "", [""], [""]);
  bool isTemplateClicked = false;
  List<String> features = [""];
  List<String> icons = [""];
  int selectedTemplateIndex = -1;
  @override
  void initState() {
    if (firebaseAuth.currentUser?.displayName != null) {
      user = firebaseAuth.currentUser!.displayName!;
    } else {
      user = firebaseAuth.currentUser!.email!;
      String email = user;
      RegExp regex = RegExp(r"^(.+)@.*$");
      String username = regex.firstMatch(email)?.group(1) ?? email;
      user = username;
      print(username);
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

  void writeData() {
    _myBox.put(1, "anuj");
  }

  void readData() {
    _myBox.get(1);
    print(_myBox.get(1));
  }

  void deleteData() {
    _myBox.delete(1);
    print("data deleted!");
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

  // String selectedColor = "Green";
  // Default color
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
                        // ColorTheme.selectedColor = "Purple";
                      });
                      print("Purple Theme Selected");
                    } else if (theme == "Green") {
                      setState(() {
                        setGlobalTheme(theme);
                        // ColorTheme.selectedColor = "Green";
                      });
                      print("Green Theme Selected");
                    } else if (theme == "Classic") {
                      setState(() {
                        setGlobalTheme(theme);
                        // ColorTheme.selectedColor = "Green";
                      });
                      print("Classic Theme Selected");
                    }
                    Navigator.pop(context); // Close the dialog
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
          // If the same template is tapped again, unselect it and set isTemplateClicked to false
          selectedTemplateIndex = -1;
          isTemplateClicked = false;
        } else {
          // Otherwise, select the template and set isTemplateClicked to true
          selectedTemplateIndex = index;
          isTemplateClicked = true;
          poetryTypeName = PoetryTypesData.getPoetryTypeByName(
              PoetryTypesData.poetryTypes[index].name);
          features = PoetryTypesData.getFeaturesByName(poetryTypeName.name);
          icons = PoetryTypesData.getIconsByName(poetryTypeName.name);
          print(features);
          print(icons);
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
                showThemeDialog(context); // Show the theme dialog
              } else if (value == 'logout') {
                logout();
                // } else if (value == 'home') {
                //   Navigator.push(context,
                //       MaterialPageRoute(builder: (context) => const Home()));
                // }
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
              // const PopupMenuItem(
              //   value: 'home',
              //   child: ListTile(
              //     leading: Icon(Icons.home),
              //     title: Text("Home"),
              //   ),
              // ),
            ],
          )
        ],
      ),
      backgroundColor: ColorTheme.accent(themeValue),
      body: SafeArea(
        child: Center(
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
                                        thumbVisibility: true,
                                        child: ListView.builder(
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
                            : Column(
                                children: [
                                  SizedBox(
                                    width: MediaQuery.of(context).size.width,
                                    height: 300,
                                    child: RiveAnimation.asset(
                                        ColorTheme.riveEmptyListAnimation(
                                            themeValue)),
                                  ),
                                  Text(
                                    "You haven't written any poetry yet ...",
                                    style: GoogleFonts.ebGaramond(
                                      textStyle: TextStyle(
                                          color: ColorTheme.text(themeValue),
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
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const PoetryEditor()));
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
