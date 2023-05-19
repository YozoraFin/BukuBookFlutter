import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/coupondetail.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class CouponList extends StatefulWidget {
  const CouponList({super.key});

  @override
  State<CouponList> createState() => _CouponListState();
}

class _CouponListState extends State<CouponList> with SingleTickerProviderStateMixin {
  List _couponList = [];
  List _couponData = [];
  List _couponPrivateList = [];
  List _couponPrivateData = [];
  bool _toggleSrc = false;
  double _searchSize = 60;
  // Kalo uda belajar cara bikin animasi baru dilanjut oke!
  // bool _toggleSrc = false;
  bool _loading = true;
  final NumberFormat idr = NumberFormat('#,##0', 'id');
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  final box = GetStorage();
  late TabController _tabController;
  TextEditingController keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCoupon();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  getCoupon() {
    Dio().post('${Constants.baseUrl}/kupon/get', data: {'AksesToken': box.read('accesstoken')})
    .then((value) {
      setState(() {
        _couponList = value.data['data'].where((kup) => !kup['Akses'] ).toList();
        _couponData = value.data['data'].where((kup) => !kup['Akses'] ).toList();
        _couponPrivateList = value.data['data'].where((kup) => kup['Akses'] == true ).toList();
        _couponPrivateData = value.data['data'].where((kup) => kup['Akses'] == true ).toList();
        _loading = false;
      });
    });
    _refreshController.refreshCompleted();
  }

  getView(data) {
    return ListView(
      shrinkWrap: true,
      children: [
        ..._loading 
        // ignore: prefer_const_constructors
        ? ({for(var i = 0; i < 5; i++) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: const SkeletonLine(
            style: SkeletonLineStyle(
                width: double.infinity,
                height: 80,
                borderRadius: BorderRadius.all(Radius.circular(15))
              ),
          )
        )}).expand((padding) => [padding]).toList()
        : data.length > 0 
        ? ({for(var kupon in data) Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15)
            ),
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: double.infinity,
              height: 80,
              child: InkWell(
                onTap: () {
                  pushNewScreen(context, screen: CouponDetail(id: kupon['id']));
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Center(
                        child: CachedNetworkImage(
                          imageUrl: kupon['SrcGambar'] != '' ? kupon['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl) : "${Constants.baseUrl}/foto/kupon/SrcGambar-1680162638483.png",
                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                            child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          alignment: Alignment.topLeft,
                        )
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(kupon['Judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'SourceSans', letterSpacing: 0.5, wordSpacing: 1.1)),
                                const SizedBox(height: 5),
                                Text(kupon['Kode'], style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blue, fontSize: 14, fontFamily: 'OpenSans')),
                                const SizedBox(height: 5),
                                RichText(
                                  text: TextSpan(
                                    style: const TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, wordSpacing: 1.1),
                                    children: [
                                      TextSpan(
                                        text: kupon['Tipe'] ? 'Diskon sebesar ' : 'Potongan sebesar ',
                                        style: const TextStyle(fontSize: 14, color: Colors.black)
                                      ),
                                      TextSpan(
                                        text: kupon['Tipe'] ? '${kupon['Potongan']}%' : 'Rp ${idr.format(kupon['Potongan'])}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black)
                                      )
                                    ]
                                  ) 
                                ),
                              ],
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                FlutterClipboard.copy(kupon['Kode']).then((value) => {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Berhasil disalin', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5),), duration: Duration(milliseconds: 500),)
                                  )
                                });
                              },
                              child: const Icon(Icons.content_copy, size: 18,),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        )}).expand((padding) => [padding]).toList()
        : {const Padding(padding: EdgeInsets.all(20), child: Text('Kupon tidak ditemukan...', style: TextStyle(fontSize: 18, color: Colors.grey),)) }.expand((padding) => [padding]).toList()
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        // Kalo uda belajar cara bikin animasi baru dilanjut oke!
        setState(() {
          _toggleSrc = false;
          _searchSize = 60;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kode Kupon', style: TextStyle(fontFamily: 'SourceSans', letterSpacing: 0.5, wordSpacing: 1.1),),
          bottom: TabBar(
            controller: _tabController,
            labelStyle: const TextStyle(fontFamily: 'SourceSans', letterSpacing: 0.5),
            tabs: const [
              Tab(text: 'Kode Kupon'),
              Tab(text: 'Kupon Saya')
            ]
          ),
          // Kalo uda belajar cara bikin animasi baru dilanjut oke!
          actions: [
              Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    height: 35,
                    width: _searchSize,
                    padding: const EdgeInsets.only(right: 16),
                    child: TextField(
                      controller: keywordController,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            if(!_toggleSrc) {
                              setState(() {
                                _toggleSrc = true;
                                _searchSize = 170;
                              });
                            }
                          },
                          icon: const Icon(Icons.search),
                        ),
                        hintText: 'Cari',
                        filled: true,
                        fillColor: Colors.white,
                        border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                        focusedBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.black), borderRadius: BorderRadius.all(Radius.circular(15)))
                      ),
                      onChanged: (text) {
                        setState(() {
                          _couponList = _couponData.where((element) => element['Judul'].toLowerCase().contains(text) || element['Kode'].toLowerCase().contains(text)).toList();
                        });
                      },
                    ),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(8.0),
                  //   child: AnimatedContainer(
                  //     duration: const Duration(milliseconds: 500),
                  //     width: _searchSize,
                  //     height: 35,
                  //     child: _toggleSrc
                  //     ? TextField(
                  //       controller: keywordController,
                  //       decoration: const InputDecoration(
                  //         hintText: 'Cari',
                  //         filled: true,
                  //         fillColor: Colors.white,
                  //         border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
                  //         contentPadding: EdgeInsets.symmetric(horizontal: 10)
                  //       ),
                  //       onChanged: (text) {
                  //         setState(() {
                  //           _couponList = _couponData.where((element) => element['Judul'].toLowerCase().contains(text) || element['Kode'].toLowerCase().contains(text)).toList();
                  //         });
                  //       },
                  //     )
                  //     : SizedBox()
                  //   ),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.only(right: 8.0),
                  //   child: IconButton(
                  //     onPressed: () {
                  //       setState(() {
                  //         _toggleSrc = true;
                  //         _searchSize = 150;
                  //       });
                  //     },
                  //     icon: const Icon(Icons.search),
                  //   ),
                  // )
                ],
              ),
          ],
        ),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            keywordController.clear();
            setState(() {
              _loading = true;
              _couponList = _couponData;
              getCoupon();
            });
          },
          child: TabBarView(
            controller: _tabController,
            children: [
              getView(_couponList),
              getView(_couponPrivateList)
            ],
          ),
        ),
      ),
    );
  }
}