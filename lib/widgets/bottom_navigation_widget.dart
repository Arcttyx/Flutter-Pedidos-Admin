import 'package:flutter/material.dart';
import 'package:mercadito_a_distancia/widgets/fab_home.dart';

class BottomNavUser extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Container(
      child: Positioned(
        bottom: 0,
        left: 0,
        child: Container(
          width: size.width,
          height: 80,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              CustomPaint(
                size: Size(size.width, 80),
                painter: CurvePainter(),
              ),
              Center(
                heightFactor: 0.6,
                child: FABHome()
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.color = Color.fromRGBO(25, 171, 131, 1);
    paint.style = PaintingStyle.fill;

    var path = Path();

    path.moveTo(0, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.15, size.height * 0.2, size.width * 0.5, size.height * 0.7);
    path.quadraticBezierTo(size.width * 0.85, size.height * 0.7, size.width * 1.0, size.height * 0.3);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}