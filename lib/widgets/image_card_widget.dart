import 'package:flutter/material.dart';

class ImageCard extends StatelessWidget {

  ImageCard({this.img, this.icon, this.title, this.onTap});

  final String? img;
  final IconData? icon;
  final String? title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Card(
        elevation: 10.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            children: <Widget>[
              ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.asset(img!),
              ),
              Container(
                padding: EdgeInsets.symmetric(vertical: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        icon,
                        color: Colors.white,
                      )
                    ),
                    Text(title!, style: TextStyle(color: Colors.white),),
                  ],
                )
              ),
            ],
          ),
        ),
      ),
      onTap: onTap?? null,
    );
  }
}