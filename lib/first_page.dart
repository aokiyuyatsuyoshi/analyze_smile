import 'package:flutter/material.dart';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'history.dart';

void main() async {
  //firebaseの設定の初期化にこの辺必要
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  //ここまで
  runApp(first_page());
}

class first_page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'first page',
        initialRoute: '/',
        routes: {
          '/history': (_) => new history(),
        },
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MyHomePage());
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ///状態を表示する（読み込み中やら失敗から）
  String Message = "";
  bool spinner_flag = false;

  ///MLkitに必要なやつ(顔の検出に必要なやつ)
  final FaceDetector _faceDetector = FirebaseVision.instance.faceDetector(
    ///オプション
    FaceDetectorOptions(

        ///正確にしたいのでaccurateを指定
        mode: FaceDetectorMode.accurate,

        ///鼻や目、口の検出も可能にする
        enableLandmarks: true,

        ///笑顔を数値化する上でtrueにしないといけないらしい
        enableClassification: true),
  );

  ///イメージピッカーの使用
  final ImagePicker _picker = ImagePicker();

  ///イメージを取得、ギャラリーからか写真から取得する
  Future<File> GetImage(
      BuildContext context, ImageSource Gallery_Or_Camera) async {
    ///この関数が呼び出された場合に表示
    setState(() {
      Message = "starting analyze...";
      spinner_flag = true;
    });

    ///取得するイメージがギャラリーか写真を撮るのか選択する(Source_image: gallery or camera)
    final PickedFile pickedImage =
        await _picker.getImage(source: Gallery_Or_Camera);

    ///取得したファイルのパスを代入
    final File imageFile = File(pickedImage.path);

    ///イメージファイルを返す
    return imageFile;
  }

  ///画像内で一番大きな顔を取得する
  Face findLargestFace(List<Face> faces) {
    ///現段階での最も大きな顔を再起的にチェックしていく
    Face largestFace = faces[0];
    for (Face face in faces) {
      ///顔を囲う四角の縦と横の合計が一番大きい画像がlargestFaceになる
      if (face.boundingBox.height + face.boundingBox.width >
          largestFace.boundingBox.height + largestFace.boundingBox.width) {
        largestFace = face;
      }
    }
    return largestFace;
  }

  ///顔を取得する
  void FindFace(BuildContext context, File imageFile) async {
    ///なんかML Vision使う時にこうやってファイル指定するらしい(firebasevisionimage形に変換する)
    final FirebaseVisionImage visionImage =
        FirebaseVisionImage.fromFile(imageFile);

    ///firebaseStorageのインスタンス
    var storage = FirebaseStorage.instance;

    ///実際に物体検知を行なって顔の情報がfacesの中へ入る
    List<Face> faces = await _faceDetector.processImage(visionImage);

    ///一つ以上の顔が存在すれば（画像の中に１つ以上の顔がある）
    if (faces.length > 0) {
      ///facesのレファレンス(参照先を指定する。この場合storage内のfacesフォルダに格納する)
      final ref = storage.ref().child('faces').child(imageFile.path);

      ///実際にファイルをストレージに保存する
      final StorageTaskSnapshot snapshot =
          await ref.putFile(imageFile).onComplete;

      print("debug 1");

      ///ストレージ保存に失敗した場合
      if (snapshot.error != null) {
        print("error is occured, perhaps, in storage.");
        print("debug 2");
      }

      ///成功した場合はダウンロードURLと画像内で最も大きい顔の情報を取得
      else {
        print("debug 3");

        ///ダウンロードURLを取得する
        final downloadURL = await snapshot.ref.getDownloadURL();

        ///最も大きい顔のデータを取得する
        Face largestFace = findLargestFace(faces);
        print("debug 4");

        ///firestoreにデータを挿入する
        FirebaseFirestore.instance.collection("smiles").add({
          "smile_prob": largestFace.smilingProbability,
          "image_url": downloadURL,
          "date": Timestamp.now(),
        });
        print("smile prob is ");
        print(largestFace.smilingProbability);
      }
      setState(() {
        Message = "";
        spinner_flag = false;
      });

      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => history(),
          ));
    }
  }

  ///appbarのタイトル
  Widget AppBar_title() {
    return AppBar(
      title: Text(
        "Analysis Your smile",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar_title(),
      body: ListView(children: [
        Column(
          children: <Widget>[
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.5),
                  child: RaisedButton(
                    color: Colors.orange,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.add_photo_alternate,
                      size: 50,
                    ),
                    onPressed: () async {
                      ///実際にギャラリーから画像をとってくる
                      File ImageFile =
                          await GetImage(context, ImageSource.gallery);
                      await FindFace(context, ImageFile);
                    },
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.5),
                  child: Container(
                    color: Colors.pinkAccent,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Analysis smile in Gallery",
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.5),
                  child: Container(
                    color: Colors.green,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Analysis smile on Camera",
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.keyboard_arrow_right,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.5),
                  child: RaisedButton(
                    color: Colors.blue,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.camera_alt,
                      size: 50,
                    ),
                    onPressed: () async {
                      ///実際にギャラリーから画像をとってくる
                      File ImageFile =
                          await GetImage(context, ImageSource.camera);
                      await FindFace(context, ImageFile);
                    },
                  ),
                ),
              ],
            ),
            Row(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.5),
                  child: RaisedButton(
                    color: Colors.orange,
                    textColor: Colors.white,
                    child: Icon(
                      Icons.history,
                      size: 50,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed('/history');
//                _getImageAndFindFace(context, ImageSource.gallery);
                    },
                  ),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints.expand(
                      height: MediaQuery.of(context).size.height * 0.3,
                      width: MediaQuery.of(context).size.width * 0.5),
                  child: Container(
                    color: Colors.pinkAccent,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "history",
                            style: TextStyle(color: Colors.white),
                          ),
                          Icon(
                            Icons.keyboard_arrow_left,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ]),
    );
  }
}
