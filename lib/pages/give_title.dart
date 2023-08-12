import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poetry_ai/pages/finish_poem.dart';

class GiveTitle extends StatefulWidget {
  const GiveTitle({
    super.key,
    required this.poem,
    this.primaryColor = const Color(0xFF303030),
    this.textColor = Colors.white,
    this.accentColor = const Color(0xFF303030),
  });
  final String poem;
  final Color primaryColor;
  final Color textColor;
  final Color accentColor;
  @override
  State<GiveTitle> createState() => _GiveTitleState();
}

class _GiveTitleState extends State<GiveTitle> {
  late String title = "";
  late String name = "";
  @override
  Widget build(BuildContext context) {
    bool isWideScreen = false;
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: widget.textColor,
          ),
          backgroundColor: widget.primaryColor,
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          )),
          title: Text(
            "Title & Write Your Name",
            style: TextStyle(
                fontSize: !isWideScreen ? 20 : 28,
                fontFamily: GoogleFonts.ebGaramond().fontFamily,
                color: widget.textColor),
          ),
          elevation: 0.0,
        ),
        backgroundColor: widget.primaryColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    title = value;
                  });
                },
                maxLines: null,
                autofocus: false,
                maxLength: 50,
                textCapitalization: TextCapitalization.sentences,
                scrollController: ScrollController(),
                scrollPhysics: const ClampingScrollPhysics(),
                style: TextStyle(
                  fontSize: !isWideScreen ? 20 : 28,
                  color: widget.textColor,
                  fontFamily: GoogleFonts.ebGaramond().fontFamily,
                ),
                cursorColor: widget.textColor,
                decoration: InputDecoration(
                  labelText: "Give A Title To Your Poem ...",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.textColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.textColor),
                  ),
                  counterStyle: TextStyle(
                      fontSize: !isWideScreen ? 16 : 26,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily,
                      color: widget.textColor),
                  labelStyle: TextStyle(
                      fontSize: !isWideScreen ? 20 : 26,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily,
                      color: widget.textColor),
                  hintStyle: TextStyle(
                    fontSize: !isWideScreen ? 18 : 26,
                    color: widget.textColor,
                    fontFamily: GoogleFonts.ebGaramond().fontFamily,
                  ),
                ),
                onTap: () {},
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    name = value;
                  });
                },
                maxLines: null,
                autofocus: false,
                maxLength: 25,
                textCapitalization: TextCapitalization.sentences,
                scrollController: ScrollController(),
                scrollPhysics: const ClampingScrollPhysics(),
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: widget.textColor,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily,
                    ),
                cursorColor: widget.textColor,
                decoration: InputDecoration(
                  labelText: "Write Your Name ...",
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.textColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: widget.textColor),
                  ),
                  counterStyle: TextStyle(
                      fontSize: !isWideScreen ? 16 : 26,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily,
                      color: widget.textColor),
                  labelStyle: TextStyle(
                      fontSize: !isWideScreen ? 20 : 26,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily,
                      color: widget.textColor),
                  hintStyle: TextStyle(
                    fontSize: !isWideScreen ? 18 : 26,
                    color: widget.textColor,
                    fontFamily: GoogleFonts.ebGaramond().fontFamily,
                  ),
                ),
                onTap: () {},
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.poem,
                  style: TextStyle(
                      fontSize: !isWideScreen ? 24 : 30,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily,
                      color: widget.textColor),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'finish',
          label: Text(
            "Finish",
            style: TextStyle(
                fontSize: !isWideScreen ? 20 : 28,
                fontFamily: GoogleFonts.ebGaramond().fontFamily,
                color: widget.textColor),
          ),
          tooltip: "Finish",
          backgroundColor: widget.accentColor,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinishPoem(
                    title: title,
                    name: name,
                    poem: widget.poem,
                    primaryColor: widget.primaryColor,
                    textColor: widget.textColor,
                    accentColor: widget.accentColor,
                  ),
                ));
          },
        ),
      ),
    );
  }
}
