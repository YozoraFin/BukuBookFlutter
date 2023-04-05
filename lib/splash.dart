import 'package:flutter/material.dart';
import 'package:login_page/paint/bottompaint.dart';
import 'package:login_page/paint/mainpaint.dart';

class SplashScreenBukuBook extends StatelessWidget {
  const SplashScreenBukuBook({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        painter: MainPaint(),
        child: CustomPaint(
          painter: BottomPaint(),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/buku.png'),
                const Text('BukuBook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}