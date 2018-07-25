import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_database/ui/firebase_animated_list.dart';
import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {
  final Widget child;
  NewsCard({this.child});
  @override
  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(const Radius.circular(7.5)),
        boxShadow: [
          new BoxShadow(
              color: Colors.black26, blurRadius: 2.5, offset: Offset(0.0, 2.5))
        ],
      ),
      child: child,
    );
  }
}

class CardText extends StatelessWidget {
  final String title;
  final String body;
  CardText({this.title, this.body});
  @override
  Widget build(context) {
    return Column(
      children: <Widget>[
        Text(
          title,
          style: TextStyle(fontSize: 15.0),
        ),
        Text(
          body != null ? body : "",
          maxLines: 3,
          style: TextStyle(fontSize: 13.0, color: Colors.grey[600]),
        ),
      ],
    );
  }
}

class ImageContainer extends StatelessWidget {
  final String url;
  ImageContainer({this.url});
  @override
  Widget build(context) {
    return url != null
        ? Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7.5),
              child: CachedNetworkImage(
                height: 75.0,
                width: 75.0,
                imageUrl: url,
                fit: BoxFit.cover,
              ),
            ),
          )
        : Container(
            width: 0.0,
            height: 0.0,
          );
  }
}
