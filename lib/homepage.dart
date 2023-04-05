import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/login.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.data});
  final String data;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'),
      ),
      body: Column(
        children: [
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