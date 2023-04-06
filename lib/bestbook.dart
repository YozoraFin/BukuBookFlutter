import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';

class BestBook extends StatefulWidget {
  const BestBook({super.key});

  @override
  State<BestBook> createState() => _BestBookState();
}

class _BestBookState extends State<BestBook> {
  final NumberFormat idr = NumberFormat('#,##0', 'id');
  List _bestBook = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getBook();
  }

  getBook() async{
    Dio().get('${Constants.baseUrl}/buku/best').then((value) {
      setState(() {
        _bestBook = value.data['data'];
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const[
                    Text('Buku dengan penjualan terbanyak', style: TextStyle(color: Color(0xFF777777), fontSize: 16),),
                    Text('Buku Terlaris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),),
                  ],
                ),
              ),
              CarouselSlider(
                options: CarouselOptions(
                  height: 380,
                  viewportFraction: 0.5,
                  enlargeCenterPage: true,
                  enableInfiniteScroll: false
                ),
                items: _bestBook.map((e) => 
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: CachedNetworkImage(
                          imageUrl: e['Sampul'][0]['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                          progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                            child: Center(
                              child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                            ),
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          width: 150,
                          height: 200,
                          fit: BoxFit.cover,
                        )
                      ),
                      const SizedBox(height: 10,),
                      Text(e['Penulis'], style: const TextStyle(color: Color(0xFF384AEB)), textAlign: TextAlign.center,),
                      const SizedBox(height: 10,),
                      Text(e['Judul'], style: const TextStyle(fontSize: 15), textAlign: TextAlign.center,),
                      const SizedBox(height: 10,),
                      Text('Rp ${idr.format(e["Harga"])}', style: const TextStyle(color: Color(0xFF384AEB)), textAlign: TextAlign.center,)     
                    ],
                  ),
                ).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}