import 'package:falcigaci/views/falci.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/databaseservice.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isClicked = false;
  late String uid;
  void _uidControl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid")!;
    if (uid != null) {
      print("uid var");
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (context) => Falci()), (route) => false);
    } else {
      print("uid yok");
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _uidControl();
    });

    ///eğer uid varsa falci sayfasına yönlendir
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Falcı Gacı',
          style: TextStyle(fontFamily: 'Lobster', fontSize: 30),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        mainAxisSize: MainAxisSize.min,

        ///to the lef
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            height: 200,
            width: 200,
            child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all(Colors.deepPurpleAccent)),
                onPressed: _isClicked == true
                    ? () {
                        print("daha önce basıldı");
                      }
                    : () async {
                        setState(() {
                          _isClicked = true;
                        });
                        final prefs = await SharedPreferences.getInstance();
                        await Provider.of<DatabaseService>(context,
                                listen: false)
                            .signInAnonymously();
                        setState(() {
                          print("giriş yapıldı");
                          uid = Provider.of<DatabaseService>(context,
                                  listen: false)
                              .getUid();
                          print("uid: $uid");
                          prefs.setString("uid", uid);
                          print("prefs uid: ${prefs.getString("uid")}");
                        });
                        print("set state dışı uid $uid");
                        await Provider.of<DatabaseService>(context,
                                listen: false)
                            .createEmptyUser(docId: uid);
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => Falci()),
                            (route) => false);
                      },
                child: Image.asset("assets/images/kahvefali.png")),
          ),
          Container(
            padding: const EdgeInsets.only(
              left: 35,
            ),
            child: Text(
              "Kahve Falı Bak",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: "Caladea",
                fontStyle: FontStyle.italic,
              ),
            ),
          )

          ///sign out button for developer purpose
          // ElevatedButton(
          //   child: Text("test"),
          //   onPressed: () async {
          //     await Provider.of<DatabaseService>(context, listen: false)
          //         .signOut();
          //     Navigator.pushAndRemoveUntil(
          //         context,
          //         MaterialPageRoute(builder: (context) => TestView()),
          //         (route) => false);
          //   },
          // ),
        ],
      ),
    );
  }
}
