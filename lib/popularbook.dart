import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/constants.dart';
import 'package:intl/intl.dart';
import 'package:login_page/detailbook.dart';
import 'package:shimmer/shimmer.dart';
import 'package:skeletons/skeletons.dart';

class PopularBook extends StatefulWidget {
  const PopularBook({super.key, required this.popularBook, required this.loading});
  final List popularBook;
  final bool loading;

  @override
  State<PopularBook> createState() => _PopularBookState();
}

class _PopularBookState extends State<PopularBook> {
  final NumberFormat idr = NumberFormat('#,##0', 'id');

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
                    Text('Buku yang paling populer', style: TextStyle(color: Color(0xFF777777), fontSize: 16),),
                    Text('Buku Populer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 32),),
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
                items: widget.loading 
                ? ({for(var i = 0; i < 8; i++) Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        width: 150,
                        height: 200,
                        alignment: Alignment.center
                      ),
                    ),
                    SizedBox(height: 10,),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        width: 70,
                        height: 12,
                        alignment: Alignment.center
                      ),
                    ),
                    SizedBox(height: 10,),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        width: 140,
                        height: 12,
                        alignment: Alignment.center
                      ),
                    ),
                    SizedBox(height: 10,),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        width: 90,
                        height: 12,
                        alignment: Alignment.center
                      ),
                    ),
                  ],
                )}).toList()
                : widget.popularBook.map((e) => 
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                        builder: (context) => DetailBook(id: e['id'] ?? '')
                      ));
                    },
                    child: Column(
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