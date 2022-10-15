import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TestView extends StatefulWidget {
  const TestView({Key? key}) : super(key: key);

  @override
  State<TestView> createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  @override
  Widget build(BuildContext context) {
    var _database = FirebaseFirestore.instance;
    return FutureBuilder<DocumentSnapshot>(
      future: _database.collection("test").doc("testdoc").get(),
      builder:
          (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
                child: Text("hata hata kodu ${snapshot.error.toString()}")),
          );
        }
        if (snapshot.hasData && !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text("document does not exist")),
          );
        }
        if (snapshot.connectionState == ConnectionState.done) {
          Map<String, dynamic> data =
              snapshot.data!.data() as Map<String, dynamic>;

          return Scaffold(
            body: Center(
                child: ElevatedButton(
              onPressed: () async {
                print(snapshot.hasData);
                print(data["testfield"]);
              },
              child: Text("test et"),
            )),
          );
        }
        return Scaffold(
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
