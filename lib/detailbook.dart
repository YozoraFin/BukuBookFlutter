import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:login_page/bottomnavbar.dart';
import 'package:login_page/cart.dart';
import 'package:login_page/constants.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class DetailBook extends StatefulWidget {
  const DetailBook({super.key, required this.id});
  final num id;

  @override
  State<DetailBook> createState() => _DetailBookState();
}

class _DetailBookState extends State<DetailBook> {
  final NumberFormat idr = NumberFormat('#,##0', 'id');
  final box = GetStorage();
  num _jumlah = 1;
  bool _loading = true;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  Map<String, dynamic> _detailbook = {
    'Judul': '',
    'Sinopsis': '',
    'Penulis': '',
    'Harga': 0,
    'Stok': 0,
    'Sampul': [],
    'Genre': {
      'Genre': '',
      'id': 0
    }
  };
  
  @override
  void initState() {
    super.initState();
    getBuku();
  }

  getBuku() {
    Dio().get('${Constants.baseUrl}/buku/${widget.id}')
    .then((value) {
      setState(() {
        _detailbook = value.data['data'];
        _jumlah = 1;
        _loading = false;
      });
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {
              pushNewScreen(context, screen: const Cart());
            }, 
            icon: const Icon(CupertinoIcons.cart)
          )
        ],
      ),
      body: SmartRefresher(
        controller: _refreshController,
        onRefresh: () {
          setState(() {
            _loading = true;
          });
          getBuku();
        },
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const SizedBox(height: 40,),
            _loading
            ? const SkeletonLine(
              style: SkeletonLineStyle(
                width: 250,
                height: 350,
                alignment: Alignment.center
              ),
            )
            : CarouselSlider(
              options: CarouselOptions(
                viewportFraction: 0.7,
                enableInfiniteScroll: false,
                height: 350
              ),
              items: _detailbook['Sampul'].map((item) => 
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Center(
                      child: CachedNetworkImage(
                        imageUrl: item['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: 250,
                        height: 350,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                )
              ).cast<Widget>().toList(), 
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _loading
              ? const SkeletonLine(
                style: SkeletonLineStyle(
                  width: 200,
                  height: 25,
                ),
              )
              : Text('${_detailbook["Judul"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'Baskerville', letterSpacing: 0.7, wordSpacing: 1.1)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: _loading
              ? const SkeletonLine(
                style: SkeletonLineStyle(
                  width: 160,
                  height: 28,
                ),
              )
              : Text('Rp ${idr.format(_detailbook["Harga"])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF384AEB), fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _loading
                                  ? const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 50,
                                      height: 18,
                                      padding: EdgeInsets.only(bottom: 5)
                                    ),
                                  )
                                  : const Text('Genre', style: TextStyle(fontSize: 18, fontFamily: 'OpenSans', letterSpacing: 0.5)),
                                  _loading
                                  ? const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 40,
                                      height: 18,
                                    ),
                                  )
                                  : const Text('Stok', style: TextStyle(fontSize: 18, fontFamily: 'OpenSans', letterSpacing: 0.5)),
                                  // Text('Jumlah', style: TextStyle(fontSize: 18))
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 4,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _loading
                                  ? const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 80,
                                      height: 18,
                                      padding: EdgeInsets.only(bottom: 5)
                                    ),
                                  )
                                  : Text(': ${_detailbook["Genre"]["Genre"]}', style: const TextStyle(color: Color(0xFF384AEB), fontSize: 18, fontFamily: 'OpenSans', letterSpacing: 0.5),),
                                  _loading
                                  ? const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 30,
                                      height: 18,
                                    ),
                                  )
                                  : Text(': ${_detailbook["Stok"]}', style: const TextStyle(fontSize: 18, fontFamily: 'OpenSans', letterSpacing: 0.5)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: _loading
                      ? const SkeletonLine(
                        style: SkeletonLineStyle(
                          width: 80,
                          height: 40,
                        ),
                      )
                      : SizedBox(
                      width: 40,
                      height: 40,
                      child: ElevatedButton(
                        onPressed: () {
                          showModalBottomSheet(
                            context: context, 
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical( 
                                top: Radius.circular(25.0),
                              ),
                            ),
                            isScrollControlled: true,
                            builder: (BuildContext context) {
                              return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Align(
                                        alignment: Alignment.topRight,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Icon(Icons.clear, color: Color(0xFF384AEB),),
                                          ),
                                        )
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                            child: Center(
                                              child: CachedNetworkImage(
                                                imageUrl: _detailbook['Sampul'][0]['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                                                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                                  child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                                                ),
                                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                                width: 75,
                                                height: 100,
                                                fit: BoxFit.cover,
                                              )
                                            ),
                                          ),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${_detailbook['Judul']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Baskerviller', height: 1.2, letterSpacing: 0.7)),
                                              Text('Rp ${idr.format(_detailbook["Harga"])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF384AEB), fontFamily: 'SourceSans', height: 1.2, letterSpacing: 0.7)),
                                              Row(
                                                children: [
                                                  IconButton(
                                                    splashRadius: 24,
                                                    onPressed: () {
                                                      if(_jumlah > 1) {
                                                        setState(() {
                                                          _jumlah--;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _jumlah = 1;
                                                        });
                                                      }
                                                    }, 
                                                    icon: const Icon(Icons.remove, color: Color(0xFF384AEB),)
                                                  ),
                                                  Text('$_jumlah', style: const TextStyle(fontFamily: 'OpenSans'),),
                                                  IconButton(
                                                    splashRadius: 24,
                                                    onPressed: () {
                                                      if(_jumlah < _detailbook['Stok'] && _jumlah < 50) {
                                                        setState(() {
                                                          _jumlah++;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          if(_detailbook['Stok'] == 0) {
                                                            _jumlah = 1;
                                                          } else {
                                                            _jumlah = _detailbook['Stok'];
                                                          }
                                                        });
                                                      }
                                                    }, 
                                                    icon: const Icon(Icons.add, color: Color(0xFF384AEB),)
                                                  ),
                                                ],
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton(
                                            onPressed: () {
                                              if(_detailbook['Stok'] == 0) {
                                                showDialog(
                                                  context: context, 
                                                  builder: (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text('Stok Habis!'),
                                                      content: const Text('Anda tidak dapat membelinya karena saat ini stok sedang kosong'),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.pop(context);
                                                          }, 
                                                          child: const Text('Ok')
                                                        )
                                                      ],
                                                    );
                                                  }
                                                );
                                              } else {
                                                Dio().post('${Constants.baseUrl}/cart/add', data: {'AksesToken': box.read('accesstoken'), 'BukuID': widget.id, 'qty': _jumlah})
                                                .then((value) => Navigator.pop(context));  
                                                setState(() {
                                                _jumlah = 1; 
                                                });    
                                              }    
                                            }, 
                                            child: const Text('Tambahkan ke Keranjang', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5),) 
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              });
                            }
                          );
                        },
                        child: const Icon(Icons.add_shopping_cart, size: 20),
                      ),
                    )
                  )
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: _loading
              ? const SkeletonLine(
                style: SkeletonLineStyle(
                  width: 90,
                  height: 20,
                ),
              )
              : const Text('Sinopsis :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'SourceSans', letterSpacing: 0.7, height: 1.2)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: _loading
                ? SkeletonParagraph(
                  style: const SkeletonParagraphStyle(
                    padding: EdgeInsets.only(top: 16),
                    lines: 5,
                    spacing: 6,
                    lineStyle: SkeletonLineStyle(
                      height: 12,
                      minLength: 120,
                      randomLength: true
                    )
                  ),
                )
                : Html(
                  data: _detailbook['Sinopsis'],
                  style: {
                    '*': Style(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      fontFamily: 'OpenSans',
                      letterSpacing: 0.5,
                      lineHeight: LineHeight.percent(120)
                    )
                  },
                )
            )
            // Padding(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   child: Text('Stok: ${_detailbook["Stok"]}', style: const TextStyle(fontSize: 18)),
            // ),
          ],
        ),
      ),
    );
  }
}