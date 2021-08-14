import 'package:flutter/material.dart';

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

Widget GallaryImmutableWord(BuildContext context) {
  return ConstrainedBox(
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
  );
}

Widget CameraImmutableWord(BuildContext context) {
  return ConstrainedBox(
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
  );
}

Widget HistoryImmutableWord(BuildContext context) {
  return ConstrainedBox(
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
  );
}
