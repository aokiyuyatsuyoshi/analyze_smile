import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

///イメージを取得、ギャラリーからか写真から取得する
Future<File> GetImage(BuildContext context, ImageSource Gallery_Or_Camera,
    ImagePicker _picker) async {
  ///取得するイメージがギャラリーか写真を撮るのか選択する(Source_image: gallery or camera)
  final PickedFile pickedImage =
      await _picker.getImage(source: Gallery_Or_Camera);

  ///取得したファイルのパスを代入
  final File imageFile = File(pickedImage.path);

  ///イメージファイルを返す
  return imageFile;
}

ErrorDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(
          '顔を検出することができませんでした。',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            child: Text(
              "閉じる",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            elevation: 16.0,
            color: Colors.orange.withOpacity(0.8),
            splashColor: Colors.blue,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

NormalDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        content: Text(
          '分析が完了しました。',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          RaisedButton(
            child: Text(
              "閉じる",
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            elevation: 16.0,
            color: Colors.orange.withOpacity(0.8),
            splashColor: Colors.blue,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      );
    },
  );
}

///顔の検出に使用する
FetchFaceDetector() {
  FirebaseVision.instance.faceDetector(
    ///オプション
    FaceDetectorOptions(

        ///正確にしたいのでaccurateを指定
        mode: FaceDetectorMode.accurate,

        ///鼻や目、口の検出も可能にする
        enableLandmarks: true,

        ///笑顔を数値化する上でtrueにしないといけないらしい
        enableClassification: true),
  );
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
FindFace(BuildContext context, File imageFile) async {
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
  bool face_exist = false;

  ///なんかML Vision使う時にこうやってファイル指定するらしい(firebasevisionimage形に変換する)
  final FirebaseVisionImage visionImage =
      FirebaseVisionImage.fromFile(imageFile);

  ///firebaseStorageのインスタンス
  var storage = FirebaseStorage.instance;

  print("これから分析します");

  ///実際に物体検知を行なって顔の情報がfacesの中へ入る
  ///ここでエラー吐いてる
  List<Face> faces = await _faceDetector.processImage(visionImage);
  print("レングスは");
  print(faces.length);

  ///一つ以上の顔が存在すれば（画像の中に１つ以上の顔がある）
  if (faces.length > 0) {
    ///顔が認識できた場合true
    face_exist = true;

    NormalDialog(context);

    ///facesのレファレンス(参照先を指定する。この場合storage内のfacesフォルダに格納する)
    final ref = storage.ref().child('faces').child(imageFile.path);

    ///実際にファイルをストレージに保存する
    final StorageTaskSnapshot snapshot =
        await ref.putFile(imageFile).onComplete;

    ///ストレージ保存に失敗した場合
    if (snapshot.error != null) {
      print("error is occured, perhaps, in storage.");
    }

    ///成功した場合はダウンロードURLと画像内で最も大きい顔の情報を取得
    else {
      ///ダウンロードURLを取得する
      final downloadURL = await snapshot.ref.getDownloadURL();

      ///最も大きい顔のデータを取得する
      Face largestFace = findLargestFace(faces);

      ///firestoreにデータを挿入する
      FirebaseFirestore.instance.collection("smiles").add({
        "smile_prob": largestFace.smilingProbability,
        "image_url": downloadURL,
        "date": Timestamp.now(),
      });
    }
  } else {
    ErrorDialog(context);
  }
}
