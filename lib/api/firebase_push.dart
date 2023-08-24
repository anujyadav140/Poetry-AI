import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

Future<void> handleBackgroundMessage(RemoteMessage message) async {
  print("Title: ${message.notification?.title}");
  print("Body: ${message.notification?.body}");
  print("Payload: ${message.data}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;
  final _firestore = FirebaseFirestore.instance;

  String getCurrentUserId() {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      return user.uid;
    }
    return '';
  }

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();
    final fCMToken = await _firebaseMessaging.getToken();

    if (fCMToken != null) {
      final tokensDoc = _firestore.collection('tokens').doc('all_tokens');
      final existingTokens = await tokensDoc.get();
      List<String> tokens = [];

      if (existingTokens.exists) {
        tokens = List<String>.from(existingTokens.data()!['tokens']);
      }

      tokens.add(fCMToken);

      await tokensDoc.set({'tokens': tokens});
    }

    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);
  }
}
