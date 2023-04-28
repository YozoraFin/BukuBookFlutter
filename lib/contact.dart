import 'dart:io';

import 'package:flutter/material.dart';
import 'package:login_page/constants.dart';
import 'package:webview_flutter/webview_flutter.dart';

class Contact extends StatefulWidget {
  const Contact({super.key});

  @override
  State<Contact> createState() => _ContactState();
}

class _ContactState extends State<Contact> {

  @override
  void initState() {
    super.initState();
    if(Platform.isAndroid) WebView.platform = AndroidWebView();
  }

  @override
  Widget build(BuildContext context) {
    return const WebView(
      initialUrl: 'https://stackoverflow.com/questions/54464853/flutter-loading-an-iframe-from-webview',
    );
  }
}