import 'dart:ffi';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/bottomnavbar.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/homebanner.dart';
import 'package:login_page/login.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

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
      body: Column(
        children: [
          const SizedBox(height: 48, width: double.infinity),
          const HomeBanner(),
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const[
                  Text('Buku yang paling populer'),
                  Text('Buku populer')
                ],
              ),
            ],
          ),
          Text(box.read('accesstoken')),
          Center(
            child: ElevatedButton(
              onPressed: () {
                box.erase();
                Navigator.push(context,
                  MaterialPageRoute(
                    builder: (context) => const Login()
                  ),
                );
              },
              child: const Text('Logout')
            ),
          ),
        ],
      )
    );
  }
}