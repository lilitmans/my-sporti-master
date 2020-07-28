import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

//class ClubImage extends StatelessWidget {
//  @override
//  Widget build(BuildContext context) {
//    return Container();
//  }
//}

thereIsClubImage(Map<String, dynamic> club) {
  if (club["image_url_bottom_left"] == "") {
    if (club["image_url_bottom_right"] == "") {
      return Container();
    } else {
      return Expanded(
          flex: 1,
          child: Container(
            child: Align(
              alignment: Alignment.center,
              child: Image.network(club["image_url_bottom_right"]),
            ),
          ),
      );
    }
  } else {
    return Align(
      alignment: Alignment.center,
      child: Image.network(club["image_url_bottom_left"]),
    );
  }
}
