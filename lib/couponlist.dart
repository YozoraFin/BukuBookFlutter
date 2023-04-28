import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

class _CouponListState extends State<CouponList> {
  List _couponList = [];
  List _couponData = [];
  // Kalo uda belajar cara bikin animasi baru dilanjut oke!
  // bool _toggleSrc = false;
  bool _loading = true;
  final NumberFormat idr = NumberFormat('#,##0', 'id');
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  TextEditingController keywordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getCoupon();
  }

  getCoupon() {
    Dio().get('${Constants.baseUrl}/kupon')
    .then((value) {
      setState(() {
        _couponList = value.data['data'];
        _couponData = value.data['data'];
        _loading = false;
      });
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
        // Kalo uda belajar cara bikin animasi baru dilanjut oke!
        // setState(() {
        //   _toggleSrc = false;
        // });
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Kode Kupon'),
          // Kalo uda belajar cara bikin animasi baru dilanjut oke!
          // actions: [
          //     Row(
          //       children: [
          //         _toggleSrc 
          //         ? Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: SizedBox(
          //             width: 150,
          //             height: 35,
          //             child: TextField(
          //               controller: keywordController,
          //               decoration: const InputDecoration(
          //                 hintText: 'Cari',
          //                 filled: true,
          //                 fillColor: Colors.white,
          //                 border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
          //                 contentPadding: EdgeInsets.symmetric(horizontal: 10)
          //               ),
          //               onChanged: (text) {
          //                 setState(() {
          //                   _couponList = _couponData.where((element) => element['Judul'].toLowerCase().contains(text) || element['Kode'].toLowerCase().contains(text)).toList();
          //                 });
          //               },
          //             ),
          //           ),
          //         )
          //         : Padding(
          //           padding: const EdgeInsets.all(8.0),
          //           child: IconButton(
          //             onPressed: () {
          //               setState(() {
          //                 _toggleSrc = true;
          //               });
          //             },
          //             icon: Icon(Icons.search),
          //           ),
          //         )
          //       ],
          //     ),
          // ],
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
          child: ListView(
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
              : ({for(var kupon in _couponList) Padding(
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
                                      Text(kupon['Judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      const SizedBox(height: 7),
                                      Text(kupon['Kode'], style: const TextStyle(fontWeight: FontWeight.bold, fontStyle: FontStyle.italic, color: Colors.blue, fontSize: 14)),
                                      const SizedBox(height: 7),
                                      RichText(
                                        text: TextSpan(
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
                                          const SnackBar(content: Text('Berhasil disalin'))
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
            ],
          ),
        ),
      ),
    );
  }
}