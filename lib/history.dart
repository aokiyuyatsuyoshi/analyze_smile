import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MyAIApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "history",
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: history(),
    );
  }
}

class history extends StatefulWidget {
  @override
  _MainFormState createState() => _MainFormState();
}

class _MainFormState extends State<history> {
  //投稿内容
  Widget _context(double probably) {
    ///数値をパーセンテージにする
    var result_double = probably * 100;

    ///文字列に変換
    String result_string = result_double.toString().substring(0, 5);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          result_string,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
          ),
        ),
        Text(
          "%",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
        )
      ],
    );
  }

  //投稿した写真
  Widget _postPicture(String post_picture) {
    return Image.network(
      post_picture,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("history"),
      ),
      body: StreamBuilder<QuerySnapshot>(
          stream: Firestore.instance
              .collection('smiles')
              .orderBy("date", descending: true)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children:
                    snapshot.data.documents.map((DocumentSnapshot document) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: MediaQuery.of(context).size.height * 0.25,
                        child: _postPicture(document['image_url']),
                      ),
                      _context(document["smile_prob"]),
                      Divider(
                        height: 40,
                        color: Colors.blue,
                      )
                    ],
                  );
                }).toList(),
              ),
            );
          }),
    );
  }
}
