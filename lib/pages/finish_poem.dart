import 'dart:io';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:poetry_ai/pages/quick_editor.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class FinishPoem extends StatefulWidget {
  const FinishPoem({super.key, required this.poem});
  final String poem;
  @override
  State<FinishPoem> createState() => _FinishPoemState();
}

class _FinishPoemState extends State<FinishPoem> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();

  @override
  void initState() {
    super.initState();
  }

  Future<void> showSuccessSnackbar() async {
    const snackBar = SnackBar(
      content: Text('Image saved successfully'),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void copyTextToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.poem));
    const snackBar = SnackBar(
      content: Text('Text copied to clipboard'),
      duration: Duration(seconds: 2),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<String> saveImage(Uint8List bytes) async {
    await [Permission.storage].request();
    final time = DateTime.now()
        .toIso8601String()
        .replaceAll('.', '-')
        .replaceAll(':', '-');
    final name = 'poem_generation_$time';
    final result = await ImageGallerySaver.saveImage(bytes, name: name);
    if (result['filePath'] != null) {
      showSuccessSnackbar();
    }
    return result['filePath'];
  }

  Future saveAndShare(Uint8List bytes) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageFile = File('${directory.path}/poetry.png');
    await imageFile.writeAsBytes(bytes);
    final xfile = XFile(imageFile.path);
    const String shareText =
        "Poem written on Poetry AI made with ❤ by Anuj Yadav";
    await Share.shareXFiles([xfile], text: shareText);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF303030),
        appBar: AppBar(
          backgroundColor: const Color(0xFF303030),
          title: Text(
            "Save, Copy & Share",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontFamily: GoogleFonts.ebGaramond().fontFamily),
          ),
          elevation: 0.0,
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Screenshot(
                  controller: screenshotController,
                  child: Row(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(20.0),
                        // color: const Color(0xFF303030),
                        color: Colors.white,
                        child: Text(
                          widget.poem,
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(
                                  color: Colors.black,
                                  fontFamily:
                                      GoogleFonts.ebGaramond().fontFamily),
                        ),
                      ),
                      // Container(
                      //   width: MediaQuery.of(context).size.width * 0.2,
                      //   color: Colors.blue,
                      // ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          foregroundColor: const Color(0xFF303030),
          backgroundColor: Colors.white,
          overlayColor: Colors.transparent,
          overlayOpacity: 0.4,
          spacing: 9,
          spaceBetweenChildren: 9,
          closeManually: false,
          direction: SpeedDialDirection.up,
          children: [
            SpeedDialChild(
              child: const Icon(
                Icons.copy_all,
                color: Color(0xFF303030),
              ),
              label: 'Copy Text',
              labelStyle: GoogleFonts.ebGaramond(
                textStyle: const TextStyle(
                  color: Color(0xFF303030),
                  letterSpacing: .5,
                  fontSize: 15,
                ),
              ),
              backgroundColor: Colors.white,
              onTap: () async {
                copyTextToClipboard();
              },
            ),
            SpeedDialChild(
              child: const Icon(
                Icons.download,
                color: Color(0xFF303030),
              ),
              label: 'Download As Image',
              labelStyle: GoogleFonts.ebGaramond(
                textStyle: const TextStyle(
                  color: Color(0xFF303030),
                  letterSpacing: .5,
                  fontSize: 15,
                ),
              ),
              backgroundColor: Colors.white,
              onTap: () async {
                final image = await screenshotController.capture();
                if (image == null) return;
                await saveImage(image);
              },
            ),
            SpeedDialChild(
              child: const Icon(
                Icons.share,
                color: Color(0xFF303030),
              ),
              label: 'Share',
              labelStyle: GoogleFonts.ebGaramond(
                textStyle: const TextStyle(
                  color: Color(0xFF303030),
                  letterSpacing: .5,
                  fontSize: 15,
                ),
              ),
              backgroundColor: Colors.white,
              onTap: () async {
                final image = await screenshotController.capture();
                if (image == null) return;
                await saveAndShare(image);
              },
            ),
          ],
        ),
        // floatingActionButton: Padding(
        //   padding: const EdgeInsets.all(8.0),
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: [
        //       FloatingActionButton.extended(
        //           heroTag: 'copy',
        //           onPressed: () {
        //             copyTextToClipboard();
        //           },
        //           icon: const Icon(Icons.copy),
        //           label: Text(
        //             "Copy Poem",
        //             style: Theme.of(context).textTheme.titleSmall?.copyWith(
        //                 color: Colors.white,
        //                 fontFamily: GoogleFonts.ebGaramond().fontFamily),
        //           )),
        //       FloatingActionButton.extended(
        //           heroTag: 'save',
        //           onPressed: () async {
        //             final image = await screenshotController.capture();
        //             if (image == null) return;
        //             await saveImage(image);
        //           },
        //           icon: const Icon(Icons.save),
        //           label: Text(
        //             "Save Poem",
        //             style: Theme.of(context).textTheme.titleSmall?.copyWith(
        //                 color: Colors.white,
        //                 fontFamily: GoogleFonts.ebGaramond().fontFamily),
        //           )),
        //       FloatingActionButton(
        //         heroTag: 'share',
        //         onPressed: () async {
        //           final image = await screenshotController.capture();
        //           if (image == null) return;
        //           await saveAndShare(image);
        //         },
        //         child: const Icon(Icons.share),
        //       ),
        //     ],
        //   ),
        // ),
      ),
    );
  }
}
