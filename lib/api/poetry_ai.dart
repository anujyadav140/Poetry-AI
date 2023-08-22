import 'package:cloud_functions/cloud_functions.dart';

class PoetryAiTools {
  final HttpsCallable _poeticMetreFinder =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('poeticMetreFinder');

  Future<String> callPoeticMetreFinderFunction(String poem) async {
    try {
      final result = await _poeticMetreFinder.call({
        'poem': poem,
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print(tokens);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling poeticMetreFinder $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _recommendPoem =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('recommendPoem');

  Future<String> callRecommendPoemFunction(String poem) async {
    print(poem);
    try {
      final result = await _recommendPoem.call({
        'poem': poem,
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print(tokens);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling recommendPoem $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _rhymeWholePoem =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('rhymeWholePoem');

  Future<String> callRhymeWholePoemFunction(
      String lines, String rhymeScheme) async {
    try {
      final result = await _rhymeWholePoem.call({
        'lines': lines,
        'rhymeScheme': rhymeScheme,
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print(tokens);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling rhymeWholePoem $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _getInspired =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('getInspired');

  Future<String> callGetInspiredFunction(String lines) async {
    try {
      final result = await _getInspired.call({
        'lines': lines,
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print(tokens);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling getInspired $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _reviewTheFeatures =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('reviewTheFeatures');

  Future<String> callReviewTheFeaturesFunction(
      String poem, List<String> features) async {
    try {
      final result = await _reviewTheFeatures.call({
        'poem': poem,
        'features': features,
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print(tokens);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling reviewTheFeatures $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _rhymeTwoSelectedLines =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('rhymeTwoSelectedLines');

  Future<String> callRhymeTwoSelectedLinesFunction(
      List<String> selectedLines) async {
    try {
      final result = await _rhymeTwoSelectedLines.call({
        'selectedLines': selectedLines,
      });
      final String res = result.data['result'];
      dynamic tokens = result.data['tokens'];
      int totalTokens = tokens['tokenUsage']['totalTokens'];
      print("Total Tokens: $totalTokens");
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling rhymeTwoSelectedLines $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _generateFewLinesForInspiration =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('generateFewLinesForInspiration');

  Future<String> callGenerateFewLinesForInspirationFunction(
      String lines) async {
    try {
      final result = await _generateFewLinesForInspiration.call({
        'lines': lines,
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print(tokens);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling generateFewLinesForInspiration $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _generateQuickLines =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('generateQuickLines');

  Future<String> callGenerateQuickLinesFunction(
      String previousLine,
      List<String> previousLines,
      List<String> nextLines,
      List<String> features) async {
    try {
      final result = await _generateQuickLines.call({
        'previousLine': previousLine,
        'previousLines': previousLines,
        'nextLines': nextLines,
        'features': features
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print(tokens);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling generateQuickLines $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _changeLinesToFollowMetre =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('changeLinesToFollowMetre');

  Future<String> callChangeLinesToFollowMetreFunction(
      String lines, String metreFeature) async {
    try {
      final result = await _changeLinesToFollowMetre.call({
        'lines': lines,
        'metreFeature': metreFeature,
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print("-----------------------------------");
      print(tokens);
      print("-----------------------------------");
      print(res);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling changeLinesToFollowMetre $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  final HttpsCallable _rhymeScheme =
      FirebaseFunctions.instanceFor(region: 'us-central1')
          .httpsCallable('rhymeScheme');

  Future<String> callRhymeSchemeFinder(String poem) async {
    try {
      final result = await _rhymeScheme.call({
        'poem': poem,
      });
      final String res = result.data['result'];
      var tokens = result.data['tokens'];
      print(tokens);
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling rhymeScheme $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }

  convertLinesToProperMetreForm(
      String multiSelectedLines, String poetryMetre) {}
}
