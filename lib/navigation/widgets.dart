import 'dart:math';
import 'package:flutter_advanced_networkimage/flutter_advanced_networkimage.dart';
import 'package:flutter/material.dart';

class NewsContainer extends StatelessWidget {
  final Widget child;
  NewsContainer({this.child});
  @override
  Widget build(context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(const Radius.circular(7.5)),
        boxShadow: [
          BoxShadow(
              color: Colors.black26, blurRadius: 2.5, offset: Offset(0.0, 2.5))
        ],
      ),
      child: child,
    );
  }
}

Widget loading(Color color) {
  return Center(
      child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(color)));
}

class CardText extends StatelessWidget {
  final String title;
  final String body;
  CardText({this.title, this.body});
  @override
  Widget build(context) {
    return Column(
      children: <Widget>[
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            title,
            style: TextStyle(fontSize: 15.0),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            body,
            maxLines: 3,
            overflow: TextOverflow.fade,
            style: TextStyle(fontSize: 13.0, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }
}

Widget profilePicture(String url) {
  return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(76.0),
            boxShadow: [
              BoxShadow(
                  color: Colors.black54,
                  blurRadius: 0.75,
                  offset: Offset(0.0, 1.0))
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(76.0),
            child: Image(
              image: AdvancedNetworkImage(url, useDiskCache: true),
            ),
          )));
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
              child: Image(
                height: 75.0,
                width: 75.0,
                image: AdvancedNetworkImage(url),
                fit: BoxFit.cover,
                // placeholder:
                //     Icon(Icons.image, size: 48.0, color: Colors.grey[700]),
              ),
            ),
          )
        : Container(
            width: 0.0,
            height: 0.0,
          );
  }
}

class NewsCard extends StatelessWidget {
  final customPopUpMenu;
  final bookMarkItem;
  final showDate;
  NewsCard({this.bookMarkItem, this.customPopUpMenu, this.showDate});
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 5.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                showDate
                    ? Text(
                        (DateTime.now().difference(
                                    DateTime.parse(bookMarkItem.published)))
                                .inHours
                                .toString() +
                            " hr ago · " +
                            bookMarkItem.source,
                        style:
                            TextStyle(fontSize: 13.0, color: Colors.grey[700]),
                      )
                    : Text(
                        bookMarkItem.source,
                        style:
                            TextStyle(fontSize: 13.0, color: Colors.grey[700]),
                      ),
                customPopUpMenu,
              ],
            ),
          ),
          Row(
            children: <Widget>[
              Flexible(
                  child: CardText(
                title: bookMarkItem.title,
                body: bookMarkItem.description,
              )),
              ImageContainer(
                url: bookMarkItem.imageURL,
              )
            ],
          ),
        ],
      ),
    );
  }
}

Widget recommendations(List recommend) {
  return ListView.builder(
    // padding: EdgeInsets.only(top: 4.0, bottom: 0.0),
    itemCount: recommend.length,
    itemBuilder: (context, index) {
      return GestureDetector(
        onTap: () {},
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text(recommend[index], textAlign: TextAlign.center),
        ),
      );
    },
  );
}

class LoadingCard extends StatefulWidget {
  LoadingCardState createState() => LoadingCardState();
}

class LoadingCardState extends State<LoadingCard>
    with SingleTickerProviderStateMixin {
  AnimationController _loadingOpacity;
  Animation _opacity;
  Random _rand;
  double _divideFactor;

  @override
  void initState() {
    _rand = Random();
    _divideFactor = (_rand.nextInt(5) + 1.4);
    _loadingOpacity = AnimationController(
        vsync: this, duration: Duration(milliseconds: 1500));
    _opacity = Tween(begin: 0.4, end: 1.0).animate(_loadingOpacity)
      ..addListener(() {
        setState(() {});
      });
    _animateForward();
    super.initState();
  }

  @override
  void dispose() {
    _loadingOpacity.dispose();
    super.dispose();
  }

  void _animateForward() async {
    await _loadingOpacity.forward().then((_) {
      _animateReverse();
    });
  }

  void _animateReverse() async {
    await _loadingOpacity.reverse().then((_) {
      _animateForward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 8.0, right: 8.0, top: 6.0, bottom: 6.0),
      child: NewsContainer(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Align(
                alignment: Alignment.centerLeft,
                              child: Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Container(
                    height: 13.0,
                    width: MediaQuery.of(context).size.width / _divideFactor,
                    // constraints: BoxConstraints.expand(),
                    decoration: BoxDecoration(
                        color: Colors.grey[350].withOpacity(_opacity.value),
                        borderRadius: BorderRadius.circular(6.5)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Container(
                  height: 13.0,
                  decoration: BoxDecoration(
                      color: Colors.grey[350].withOpacity(_opacity.value),
                      borderRadius: BorderRadius.circular(6.5)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Container(
                  height: 13.0,
                  decoration: BoxDecoration(
                      color: Colors.grey[350].withOpacity(_opacity.value),
                      borderRadius: BorderRadius.circular(6.5)),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Container(
                  height: 13.0,
                  decoration: BoxDecoration(
                      color: Colors.grey[350].withOpacity(_opacity.value),
                      borderRadius: BorderRadius.circular(6.5)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
