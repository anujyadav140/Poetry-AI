import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poetry_ai/services/local_notif.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

class FinishPoem extends StatefulWidget {
  const FinishPoem({
    super.key,
    required this.poem,
    required this.title,
    required this.name,
    this.primaryColor = const Color(0xFF303030),
    this.textColor = Colors.white,
    this.accentColor = const Color(0xFF303030),
  });
  final String title;
  final String name;
  final String poem;
  final Color primaryColor;
  final Color textColor;
  final Color accentColor;
  @override
  State<FinishPoem> createState() => _FinishPoemState();
}

class _FinishPoemState extends State<FinishPoem> {
  //Create an instance of ScreenshotController
  ScreenshotController screenshotController = ScreenshotController();
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  @override
  void initState() {
    super.initState();
  }

  Future<void> successful() async {
    MyNotification.showBigTextNotification(
        title: "Poetry AI",
        body: "A creative success!\nYou have completed a poem!",
        fln: flutterLocalNotificationsPlugin);
  }

  Future<void> showSuccessSnackbar() async {
    bool isWideScreen = false;
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: widget.accentColor,
      content: Text(
        'Image saved successfully',
        style: TextStyle(
            color: widget.textColor,
            letterSpacing: .5,
            fontSize: !isWideScreen ? 22 : 28,
            fontFamily: GoogleFonts.ebGaramond().fontFamily),
      ),
      duration: const Duration(seconds: 2),
    ));
  }

  void copyTextToClipboard() {
    bool isWideScreen = false;
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    Clipboard.setData(ClipboardData(text: widget.poem));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: widget.accentColor,
      content: Text(
        'Text copied to clipboard',
        style: TextStyle(
            color: widget.textColor,
            letterSpacing: .5,
            fontSize: !isWideScreen ? 22 : 28,
            fontFamily: GoogleFonts.ebGaramond().fontFamily),
      ),
      duration: const Duration(seconds: 2),
    ));
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
    const String shareText = "Poem written on Poetry AI";
    await Share.shareXFiles([xfile], text: shareText);
  }

  @override
  Widget build(BuildContext context) {
    bool isWideScreen = false;
    if (MediaQuery.of(context).size.width >= 768) {
      isWideScreen = true;
    }
    return SafeArea(
      child: Scaffold(
        backgroundColor: widget.primaryColor,
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
            "Save, Copy & Share",
            style: TextStyle(
                fontSize: !isWideScreen ? 20 : 28,
                color: widget.textColor,
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
                        padding: const EdgeInsets.all(40.0),
                        // color: widget.primaryColor,
                        color: Colors.white,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            widget.title.isNotEmpty
                                ? Text(
                                    widget.title,
                                    style: TextStyle(
                                        fontSize: !isWideScreen ? 20 : 28,
                                        color: Colors.black,
                                        fontFamily: GoogleFonts.ebGaramond()
                                            .fontFamily),
                                  )
                                : Container(),
                            const SizedBox(
                              height: 25,
                            ),
                            Text(
                              widget.poem,
                              style: TextStyle(
                                  fontSize: !isWideScreen ? 20 : 28,
                                  color: Colors.black,
                                  fontFamily:
                                      GoogleFonts.ebGaramond().fontFamily),
                            ),
                            const SizedBox(
                              height: 25,
                            ),
                            widget.name.isNotEmpty
                                ? Text(
                                    "—${widget.name}",
                                    style: TextStyle(
                                        fontSize: !isWideScreen ? 20 : 28,
                                        color: Colors.black,
                                        fontFamily: GoogleFonts.ebGaramond()
                                            .fontFamily),
                                  )
                                : Container(),
                          ],
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
          foregroundColor: widget.textColor,
          backgroundColor: widget.accentColor,
          overlayColor: Colors.transparent,
          overlayOpacity: 0.4,
          spacing: 9,
          spaceBetweenChildren: 9,
          closeManually: false,
          direction: SpeedDialDirection.up,
          children: [
            SpeedDialChild(
              child: Icon(
                Icons.copy_all,
                color: widget.textColor,
                size: 30,
              ),
              label: 'Copy Text',
              labelStyle: GoogleFonts.ebGaramond(
                textStyle: TextStyle(
                  color: Colors.black,
                  letterSpacing: .5,
                  fontSize: !isWideScreen ? 20 : 28,
                ),
              ),
              backgroundColor: widget.accentColor,
              onTap: () async {
                successful();
                copyTextToClipboard();
              },
            ),
            SpeedDialChild(
              child: Icon(
                Icons.download,
                color: widget.textColor,
                size: 30,
              ),
              label: 'Download As Image',
              labelStyle: GoogleFonts.ebGaramond(
                textStyle: TextStyle(
                  color: Colors.black,
                  letterSpacing: .5,
                  fontSize: !isWideScreen ? 20 : 28,
                ),
              ),
              backgroundColor: widget.accentColor,
              onTap: () async {
                successful();
                final image = await screenshotController.capture();
                if (image == null) return;
                await saveImage(image);
              },
            ),
            SpeedDialChild(
              child: Icon(
                Icons.share,
                color: widget.textColor,
                size: 30,
              ),
              label: 'Share',
              labelStyle: GoogleFonts.ebGaramond(
                textStyle: TextStyle(
                  color: Colors.black,
                  letterSpacing: .5,
                  fontSize: !isWideScreen ? 20 : 28,
                ),
              ),
              backgroundColor: widget.accentColor,
              onTap: () async {
                successful();
                final image = await screenshotController.capture();
                if (image == null) return;
                await saveAndShare(image);
              },
            ),
          ],
        ),
      ),
    );
  }
}
