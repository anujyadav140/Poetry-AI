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
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling poeticMetreFinder $e';
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
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling rhymeTwoSelectedLines $e';
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
      return res;
    } on FirebaseFunctionsException catch (e) {
      return 'Error occurred while calling changeLinesToFollowMetre $e';
    } catch (e) {
      return 'Unexpected error occurred $e';
    }
  }
}
