import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/paint/detailbookpaint.dart';

class DetailBook extends StatefulWidget {
  const DetailBook({super.key, required this.id});
  final num id;

  @override
  State<DetailBook> createState() => _DetailBookState();
}

class _DetailBookState extends State<DetailBook> {
  final NumberFormat idr = NumberFormat('#,##0', 'id');
  num _jumlah = 1;

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
      });
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
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          CustomPaint(
            painter: DetailBookPaint(),
            child: const SizedBox(
              height: 100,
              width: double.infinity,
            ),
          ),
          Center(
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
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('${_detailbook["Judul"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('Rp ${idr.format(_detailbook["Harga"])}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 28, color: Color(0xFF384AEB))),
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
                              children: const [
                                Text('Genre', style: TextStyle(fontSize: 18)),
                                Text('Stok', style: TextStyle(fontSize: 18)),
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
                                Text(': ${_detailbook["Genre"]["Genre"]}', style: const TextStyle(color: Color(0xFF384AEB), fontSize: 18),),
                                Text(': ${_detailbook["Stok"]}', style: const TextStyle(fontSize: 18)),
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
                  child: SizedBox(
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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 2),
            child: Text('Sinopsis :', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Html(
              data: _detailbook['Sinopsis'],
            )
          )
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          //   child: Text('Stok: ${_detailbook["Stok"]}', style: const TextStyle(fontSize: 18)),
          // ),
        ],
      ),
    );
  }
}