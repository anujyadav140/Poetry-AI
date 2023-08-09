import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:poetry_ai/pages/home_page.dart';
import 'package:screenshot/screenshot.dart';

class FinishPoem extends StatefulWidget {
  const FinishPoem({super.key, required this.poem});
  final List<String> poem;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF303030),
      appBar: AppBar(
        title: const Text("Save Poem"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Screenshot(
                controller: screenshotController,
                child: Container(
                    width: MediaQuery.of(context).size.width,
                    // height: MediaQuery.of(context).size.height,
                    padding: const EdgeInsets.only(left: 20.0, top: 20.0),
                    color: Colors.white,
                    child: Text(
                      widget.poem,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.black,
                          fontFamily: GoogleFonts.ebGaramond().fontFamily),
                    )),
              ),
              Column(
                children: [
                  ElevatedButton(
                      onPressed: () {
                        copyTextToClipboard();
                      },
                      child: const Text("Copy Text")),
                  ElevatedButton(
                      onPressed: () async {
                        final image = await screenshotController.capture();
                        if (image == null) return;
                        await saveImage(image);
                      },
                      child: const Text("Save Image")),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ));
                      },
                      child: const Text("Back To Home")),
                ],
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: const Icon(Icons.share),
      ),
    );
  }
}
