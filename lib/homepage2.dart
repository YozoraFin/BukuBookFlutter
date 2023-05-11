import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/bestbook.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/homearticle.dart';
import 'package:login_page/homebanner.dart';
import 'package:login_page/homecoupon.dart';
import 'package:login_page/popularbook.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final box = GetStorage();
  bool _loadingPopular = true;
  bool _loadingBest = true;
  bool _loadingArticle = true;
  bool _loadingBanner = true;
  bool _loadingCoupon = true;

  List _popularBook = [];
  List _bestBook = [];
  List _newArticle = [];
  List _banner = [];
  Map<String, dynamic> _coupon = {
    'Judul': '',
    'Kode': '',
    'Teaser': '',
    'SrcGambar': ''
  };

  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    loadCall();
  }

  loadCall() {
    getPopular();
    getBest();
    getArticle();
    getBanner();
    getCoupon();
    _refreshController.refreshCompleted();
  }

  getPopular() {
    Dio().get('${Constants.baseUrl}/buku/rekomended').then((value) {
      setState(() {
        _popularBook = value.data['data'];
        _loadingPopular = false;
      });
    });
  }

  getBest() {
    Dio().get('${Constants.baseUrl}/buku/best').then((value) {
      setState(() {
        _bestBook = value.data['data'];
        _loadingBest = false;
      });
    });
  }

  getArticle() {
    Dio().get('${Constants.baseUrl}/artikel').then((value) {
      setState(() {
        _newArticle = value.data['data'];
        _loadingArticle = false;
      });
    });
  }

  getBanner() {
    Dio().get('${Constants.baseUrl}/banner').then((value) {
      setState(() {
        _banner = value.data['data'];
        _loadingBanner = false;
      });
    });
  }

  getCoupon() {
    Dio().post('${Constants.baseUrl}/kupon/get', data: {'AksesToken': box.read('accesstoken')}).then((value) {
      setState(() {
        _coupon = value.data['hData'];
        _loadingCoupon = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        // appBar: AppBar(
        //   backgroundColor: Colors.white,
        //   title: Row(
        //     children: const [
        //       FaIcon(FontAwesomeIcons.book, color: Colors.blue,),
        //       Text(' BukuBook', style: TextStyle(color: Colors.black),)
        //     ],
        //   ),
        //   bottom: AppBar(
        //     title: Text('halo'),
        //   ),
        // ),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            loadCall();
            setState(() {
              _loadingPopular = true;
              _loadingBest = true;
              _loadingArticle = true;
              _loadingBanner = true;
              _loadingCoupon = true;
            });
          },
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                title: Row(
                  children: const [
                    FaIcon(FontAwesomeIcons.book, color: Colors.blue,),
                    Text(' BukuBook', style: TextStyle(color: Colors.black),)
                  ],
                ),
                backgroundColor: Colors.white,
                floating: true,
                pinned: true,
                bottom: AppBar(
                  backgroundColor: Colors.white,
                  title: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: SizedBox(
                            height: 35,
                            child: TextFormField(
                              decoration: InputDecoration(
                                fillColor:const Color(0xFFFAFAFA),
                                filled: true,
                                suffixIcon: IconButton(
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
    
                                  },
                                  icon: const Icon(Icons.search),
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10)
                                ),
                                hintText: 'Cari...',
                                contentPadding: const EdgeInsets.only(left: 10)
                              ),
                            )
                          )
                        ),
                        const Spacer(),
                        const Expanded(
                          flex: 1,
                          child: Icon(CupertinoIcons.cart, color: Colors.blue,),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate([
                  Column(
                    children: [
                      const SizedBox(height: 48, width: double.infinity),
                      _loadingBanner 
                      ? const SkeletonLine(
                        style: SkeletonLineStyle(
                          width: double.infinity,
                          height: 248,
                          alignment: Alignment.center
                        ),
                      )
                      : HomeBanner(bannerData: _banner),const SizedBox(height: 50,),
                      PopularBook(popularBook: _popularBook, loading: _loadingPopular,),
                      _loadingCoupon
                      ? const SkeletonLine(
                        style: SkeletonLineStyle(
                          width: double.infinity,
                          height: 248,
                          alignment: Alignment.center
                        ),
                      )
                      : HomeCoupon(coupon: _coupon,),
                      const SizedBox(height: 50,),
                      BestBook(bestBook: _bestBook, loading: _loadingBest,),
                      const SizedBox(height: 30,),
                      HomeArticle(newArticle: _newArticle, loading: _loadingArticle,),
                      const SizedBox(height: 50,),
                    ],
                  ),
                ])
              )
            ],
          ),
        )
      ),
    );
  }
}