import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:poetry_ai/pages/finish_poem.dart';

class GiveTitle extends StatefulWidget {
  const GiveTitle({super.key, required this.poem});
  final String poem;
  @override
  State<GiveTitle> createState() => _GiveTitleState();
}

class _GiveTitleState extends State<GiveTitle> {
  late String title = "";
  late String name = "";
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF303030),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(25),
          )),
          title: Text(
            "Title & Write Your Name",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontFamily: GoogleFonts.ebGaramond().fontFamily),
          ),
          elevation: 0.0,
        ),
        backgroundColor: const Color(0xFF303030),
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
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily,
                    ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: "Give A Title To Your Poem ...",
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  counterStyle: const TextStyle(color: Colors.white),
                  labelStyle: const TextStyle(color: Colors.white),
                  hintStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
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
                      color: Colors.white,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily,
                    ),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  labelText: "Write Your Name ...",
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white),
                  ),
                  counterStyle: const TextStyle(color: Colors.white),
                  labelStyle: const TextStyle(color: Colors.white),
                  hintStyle: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Colors.white,
                        fontFamily: GoogleFonts.ebGaramond().fontFamily,
                      ),
                ),
                onTap: () {},
              ),
              Container(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.poem,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontFamily: GoogleFonts.ebGaramond().fontFamily),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          heroTag: 'finish',
          label: Text(
            "Finish",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: const Color(0xFF303030),
                fontFamily: GoogleFonts.ebGaramond().fontFamily),
          ),
          tooltip: "Finish",
          backgroundColor: Colors.white,
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FinishPoem(
                    title: title,
                    name: name,
                    poem: widget.poem,
                  ),
                ));
          },
        ),
      ),
    );
  }
}
