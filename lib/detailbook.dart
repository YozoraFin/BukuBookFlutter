import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';
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
  num _jumlah = 1;
  bool _loading = true;
  RefreshController _refreshController = RefreshController(initialRefresh: false);

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
            : Center(
              child: CachedNetworkImage(
                imageUrl: _detailbook['Sampul'].length < 1 ? '' : _detailbook['Sampul'][0]['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                  child: Center(
                    child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                  ),
                ),
                errorWidget: (context, url, error) => const Icon(Icons.error),
                width: 250,
                height: 350,
                fit: BoxFit.cover,
              )
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _loading
              ? const SkeletonLine(
                style: SkeletonLineStyle(
                  width: 200,
                  height: 25,
                ),
              )
              : Text('${_detailbook["Judul"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _loading
              ? const SkeletonLine(
                style: SkeletonLineStyle(
                  width: 160,
                  height: 28,
                ),
              )
              : Text('Rp ${idr.format(_detailbook["Harga"])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF384AEB))),
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
                                  : Text('Genre', style: TextStyle(fontSize: 18)),
                                  _loading
                                  ? const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 40,
                                      height: 18,
                                    ),
                                  )
                                  : Text('Stok', style: TextStyle(fontSize: 18)),
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
                                  : Text(': ${_detailbook["Genre"]["Genre"]}', style: const TextStyle(color: Color(0xFF384AEB), fontSize: 18),),
                                  _loading
                                  ? const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 30,
                                      height: 18,
                                    ),
                                  )
                                  : Text(': ${_detailbook["Stok"]}', style: const TextStyle(fontSize: 18)),
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
                                            child: Text('x', style: TextStyle(color: Color(0xFF384AEB), fontSize: 25),),
                                          ),
                                        )
                                      ),
                                      Row(
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                                            child: Center(
                                              child: CachedNetworkImage(
                                                imageUrl: _detailbook['Sampul'][0]['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                                                progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                                                  child: Center(
                                                    child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                                                  ),
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
                                              Text('${_detailbook['Judul']}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                                              Text('Rp ${idr.format(_detailbook["Harga"])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF384AEB))),
                                              Row(
                                                children: [
                                                  IconButton(
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
                                                    icon: Icon(Icons.remove, color: Color(0xFF384AEB),)
                                                  ),
                                                  Text('${_jumlah}'),
                                                  IconButton(
                                                    onPressed: () {
                                                      if(_jumlah < _detailbook['Stok']) {
                                                        setState(() {
                                                          _jumlah++;
                                                        });
                                                      } else {
                                                        setState(() {
                                                          _jumlah = _detailbook['Stok'];
                                                        });
                                                      }
                                                    }, 
                                                    icon: Icon(Icons.add, color: Color(0xFF384AEB),)
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
                                                                        
                                            }, 
                                            child: Text('Tambahkan ke Keranjang') 
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
              : Text('Sinopsis :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
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