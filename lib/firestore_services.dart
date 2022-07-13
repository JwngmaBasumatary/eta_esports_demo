import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future getDownloadLink() async {
    return await _db
        .collection("Apk_Link")
        .doc("latest_apk_link")
        .get()
        .then((documentSnapshot) => documentSnapshot.get('link'));
  }
}
