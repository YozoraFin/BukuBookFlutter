import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/constants.dart';

class ArticleDetail extends StatefulWidget {
  const ArticleDetail({super.key, required this.id});
  final num id;

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {

  @override
  void initState() {
    super.initState();
  }

  getArticle() {
    Dio().get('${Constants.baseUrl}/artikel/${widget.id}')
    .then((value) {
      
    });
  }

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

        ],
      ),
    );
  }
}