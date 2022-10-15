import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:falcigaci/services/adservice.dart';
import 'package:falcigaci/services/databaseservice.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_bubble/bubble_type.dart';
import 'package:flutter_chat_bubble/chat_bubble.dart';
import 'package:flutter_chat_bubble/clippers/chat_bubble_clipper_1.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Falci extends StatefulWidget {
  const Falci({Key? key}) : super(key: key);

  @override
  State<Falci> createState() => _FalciState();
}

class _FalciState extends State<Falci> {
  late String uid;
  void _getUid() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      uid = prefs.getString("uid")!;
    });

    print("uid falci: $uid");
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getUid();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => DatabaseService(),
        builder: (build, context) => SafeArea(
                child: StreamBuilder<QuerySnapshot>(
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  print("test");
                  AdService adService = AdService();

                  return Scaffold(
                    body: SafeArea(
                        child: Column(children: [
                      Expanded(
                        child: ListView.builder(
                            itemCount: snapshot.data!.docs.length,
                            itemBuilder: (context, index) {
                              int reverseIndex =
                                  snapshot.data!.docs.length - index - 1;
                              return GestureDetector(
                                child: ChatBubble(
                                  alignment: Alignment.topRight,
                                  clipper: ChatBubbleClipper1(
                                      type: BubbleType.sendBubble),
                                  backGroundColor: Color(0xffE7E7ED),
                                  margin: EdgeInsets.only(top: 20),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Image(
                                          image: NetworkImage(
                                              "${snapshot.data!.docs[reverseIndex]["falUrl"] == "" ? "https://resim.aydinli.com.tr/image-not-found.png" : snapshot.data!.docs[reverseIndex]["falUrl"]}"),
                                          width: 200,
                                          height: 200,
                                        ),
                                        snapshot.data!.docs[reverseIndex]
                                                ["isCevaplandi"]
                                            ? Text("Cevaplandı",
                                                style: TextStyle(
                                                    color: Colors.green,
                                                    fontWeight:
                                                        FontWeight.bold))
                                            : Text("Cevaplanmadı",
                                                style: TextStyle(
                                                    color: Colors.red,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                      ],
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.7,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  print("$reverseIndex numaralı fal tıklandı");
                                  if (snapshot.data!.docs[reverseIndex]
                                      ["isCevaplandi"]) {
                                    print("cevaplandı");
                                    AwesomeDialog(
                                      customHeader: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/popuplogo.jpg"),
                                                fit: BoxFit.cover)),
                                      ),
                                      context: context,
                                      dialogType: DialogType.success,
                                      animType: AnimType.bottomSlide,
                                      title: 'Falınız',
                                      desc: snapshot.data!.docs[reverseIndex]
                                          ["cevap"],
                                      btnOkText: "Tamam",
                                    )..show();
                                  } else {
                                    print("cevaplanmadı");
                                    AwesomeDialog(
                                      customHeader: Container(
                                        height: 100,
                                        width: 100,
                                        decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            image: DecorationImage(
                                                image: AssetImage(
                                                    "assets/images/popuplogo.jpg"),
                                                fit: BoxFit.cover)),
                                      ),
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.bottomSlide,
                                      title: 'Falınız',
                                      desc: "Falınız henüz cevaplanmadı",
                                      btnOkText: "Tamam",
                                    )..show();
                                  }
                                },
                                onLongPress: () {
                                  print("$reverseIndex numaralı fal silindi");
                                  AwesomeDialog(
                                    customHeader: Container(
                                      height: 100,
                                      width: 100,
                                      decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  "assets/images/popuplogo.jpg"),
                                              fit: BoxFit.cover)),
                                    ),
                                    context: context,
                                    dialogType: DialogType.warning,
                                    animType: AnimType.bottomSlide,
                                    title: 'Falı Sil',
                                    desc:
                                        'Falınızı silmek istediğinize emin misiniz?',
                                    btnOkText: "Evet",
                                    btnCancelText: "Hayır",
                                    btnCancelOnPress: () {},
                                    btnOkOnPress: () {
                                      DatabaseService().deleteFal(
                                          docId: uid,
                                          falId: snapshot
                                              .data!.docs[reverseIndex].id,
                                          falUrl: snapshot.data!
                                              .docs[reverseIndex]["falUrl"]);
                                    },
                                  )..show();
                                },
                              );
                            }),
                      ),

                      ///modern desinged send image button
                      Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          children: [
                            SizedBox(width: 10),
                            Container(
                              width: MediaQuery.of(context).size.width * 0.9,
                              child: FloatingActionButton(
                                backgroundColor: Color(0xFFB7A2DD),
                                foregroundColor: Color(0xFFB1384E),
                                onPressed: () async {
                                  print("test");

                                  await adService.showRewardedAd(
                                      uid: uid,
                                      count: snapshot.data!.docs.length);
                                },
                                child: Icon(Icons.send),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        ///show banner ad
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: AdWidget(
                          ad: adService.showBannerAd()..load(),
                          key: UniqueKey(),
                        ),
                      )
                    ])),
                  );
                }
                if (snapshot.hasError) {
                  return Scaffold(
                    body: Center(
                      child: Text(
                          "Hata oluştu, lütfen internet bağlantınızı kontrol edin ve uygulamayı yeniden başlatın hata kodu: ${snapshot.error}"),
                    ),
                  );
                } else {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
              },
              stream: FirebaseFirestore.instance
                  .collection("falcigaci")
                  .doc(uid)
                  .collection("fallar")
                  .snapshots(),
            )));
  }
}
