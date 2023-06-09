import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/detailbook.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:skeletons/skeletons.dart';

class BestBook extends StatefulWidget {
  const BestBook({super.key, required this.bestBook, required this.loading});
  final List bestBook;
  final bool loading;

  @override
  State<BestBook> createState() => _BestBookState();
}

class _BestBookState extends State<BestBook> {
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
                    Text('Buku dengan penjualan terbanyak', style: TextStyle(color: Color(0xFF777777), fontSize: 18, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1, height: 1.2),),
                    Text('Buku Terlaris', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, fontFamily: 'Baskerville', letterSpacing: 1.3, wordSpacing: 1.2, height: 1.3),),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: widget.loading 
                    ? ({for(var i = 0; i < 8; i++) SizedBox(
                      height: 300,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                              width: 0.3
                            ),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                blurRadius: 1,
                                spreadRadius: 1,
                                offset: const Offset(0, 2)
                              )
                            ]
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              width: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(13),
                                    child: const SkeletonLine(
                                      style: SkeletonLineStyle(
                                        width: 150,
                                        height: 200,
                                        alignment: Alignment.center
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 70,
                                      height: 12,
                                      alignment: Alignment.center
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 140,
                                      height: 12,
                                      alignment: Alignment.center
                                    ),
                                  ),
                                  const SizedBox(height: 10,),
                                  const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 90,
                                      height: 12,
                                      alignment: Alignment.center
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    )}).toList()
                    : widget.bestBook.map((e) => 
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: GestureDetector(
                          onTap: () {
                            pushNewScreen(context, screen: DetailBook(id: e['id'] ?? ''), withNavBar: false);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.5),
                                  blurRadius: 1,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 1)
                                )
                              ]
                            ),
                            child: SizedBox(
                              width: 150,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Center(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                                      child: CachedNetworkImage(
                                        imageUrl: e['Sampul'][0]['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                          child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                                        ),
                                        errorWidget: (context, url, error) => const Icon(Icons.error),
                                        width: 150,
                                        height: 200,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  ),
                                  const SizedBox(height: 10,),
                                  Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      children: [
                                        Text(e['Judul'], style: const TextStyle(fontSize: 15, fontFamily: 'OpenSans', letterSpacing: 0.5), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 5,),
                                        Text('By ${e['Penulis']}', style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF384AEB), fontFamily: 'OpenSans', fontSize: 13, letterSpacing: 0.5), textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 5,),
                                        Text('Rp ${idr.format(e["Harga"])}', style: const TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5), textAlign: TextAlign.center,),     
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 5,),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}