# 仕様書
### 作者
青木優弥
### アプリ名
analyze_smile

##はじめに
これはMikitの練習に使用。
あまりアーキテクチャなどに拘っていない。

#### こだわったポイント
- シンプルかつ使いやすいデザインへ
- ギャラリーからもカメラからも画像をインポートできる

## 開発環境
### 開発環境
Android Studio 4.0

### 開発言語
flutter 2.0.5
dart 2.12.3


## 動作対象端末・OS
### 動作対象OS
ios 14.3
実機未確認

## アプリケーション機能

### 機能一覧

- 笑顔の数値化 :　MLKitを使用して画像から顔を認識し、その顔の笑顔を数値化する。



### 画面一覧
- 選択画面 ：ギャラリーもしくはカメラから写真を取得。履歴も閲覧可能。
- 結果画面 ：画像と分析結果を表示

### 使用しているAPI,SDK,ライブラリなど
- image_picker
- firebase_core
- firebase_ml_vision
- cloud_firestore
- firebase_storage


