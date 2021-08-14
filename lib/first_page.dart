import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'history.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'widget.dart';
import 'model.dart';

final Global_Provider = ChangeNotifierProvider((ref) => Provider());

class Provider with ChangeNotifier {
  FindAFace(BuildContext context, File ImageFile) async {
    await FindFace(context, ImageFile);
    notifyListeners();
    return FindFace(context, ImageFile);
  }
}

class first_page extends HookWidget {
  @override
  Widget build(BuildContext context) {
    ///イメージピッカーの使用
    final ImagePicker _picker = ImagePicker();

    ///状態を表示する（読み込み中やら失敗から）
    String Message = "";

    ///trueの時にダイアログを表示
    bool spinner_flag = false;

    ///顔が認識できた時にtrue
    bool face_exist;

    ///MLkitに必要なやつ(顔の検出に必要なやつ)
    // final FaceDetector _faceDetector = FetchFaceDetector();

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
      home: Scaffold(
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
                        File ImageFile = await GetImage(
                            context, ImageSource.gallery, _picker);
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => history()));
                        await FindFace(context, ImageFile);
                      },
                    ),
                  ),
                  GallaryImmutableWord(context)
                ],
              ),
              Row(
                children: [
                  CameraImmutableWord(context),
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
                        File ImageFile = await GetImage(
                            context, ImageSource.camera, _picker);
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
                        Navigator.push(context,
                            MaterialPageRoute(builder: (_) => history()));
                      },
                    ),
                  ),
                  HistoryImmutableWord(context)
                ],
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
