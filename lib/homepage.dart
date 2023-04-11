import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/bestbook.dart';
import 'package:login_page/homearticle.dart';
import 'package:login_page/homebanner.dart';
import 'package:login_page/homecoupon.dart';
import 'package:login_page/popularbook.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: const [
            SizedBox(height: 48, width: double.infinity),
            HomeBanner(),
            SizedBox(height: 50,),
            PopularBook(),
            HomeCoupon(),
            SizedBox(height: 50,),
            BestBook(),
            SizedBox(height: 30,),
            HomeArticle(),
            SizedBox(height: 50,),
          ],
        ),
      )
    );
  }
}