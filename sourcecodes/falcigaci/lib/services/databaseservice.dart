import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class DatabaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collectionName = "falcigaci";
  final String _fallarSubCollectionName = "fallar";
  final String _falTestCevap =
      "Bu fal otomatik olarak oluşturulmuştur. Lütfen sen de kendi falını göndermek için aşağıdaki gönderme butonuna tıkla. Falını silmek için ise basılı tut.";
  final String _falTestUrl =
      "https://firebasestorage.googleapis.com/v0/b/falcigaci-58898.appspot.com/o/consts%2Fkahve-fali-nasil-bakilir-teknikleri-nelerdir.jpg?alt=media&token=25aeecba-e73c-4960-89fb-43bb6fec622c";

  ///sign in anonymously and return uid
  Future<void> signInAnonymously() async {
    await _auth.signInAnonymously();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  String getUid() => _auth.currentUser!.uid;

  ///delete fal from firestore
  Future<void> deleteFal(
      {required String docId, required String falId, required falUrl}) async {
    await _firestore
        .collection(_collectionName)
        .doc(docId)
        .collection(_fallarSubCollectionName)
        .doc(falId)
        .delete();

    ///delete from storage
    if (falUrl != _falTestUrl) {
      await _storage.refFromURL(falUrl).delete();
    }
  }

  ///create empty user for first login
  Future<void> createEmptyUser({required String docId}) async {
    await _firestore
        .collection(_collectionName)
        .doc(docId)
        .collection(_fallarSubCollectionName)
        .doc("fal1")
        .set({
      "cevap": _falTestCevap,
      "tarih": DateTime.now(),
      "isCevaplandi": true,
      "falUrl": _falTestUrl,
    });
  }

  /// add fal to firestore
  Future<void> addFalToFirestore({
    required String docId,
    required int count,
  }) async {
    notifyListeners();
    final ImagePicker _picker = ImagePicker();
    final XFile? photo =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 35);
    late String url;
    if (photo != null) {
      final image = File(photo.path);
      final ref = await _storage
          .ref()
          .child("fallar")
          .child(docId)
          .child("${DateTime.now()}.jpg");
      await ref.putFile(image);
      url = await ref.getDownloadURL();
      print(url);
    }
    String falId = DateTime.now().toString();
    await _firestore
        .collection(_collectionName)
        .doc(docId)
        .collection("fallar")
        .doc("fal $falId")
        .set({
      "cevap": "",
      "tarih": DateTime.now(),
      "falUrl": url,
      "isCevaplandi": false,
    });
  }
}
