import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:login_page/articledetail.dart';
import 'package:login_page/constants.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:skeletons/skeletons.dart';

class HomeArticle extends StatefulWidget {
  const HomeArticle({super.key, required this.newArticle, required this.loading});
  final List newArticle;
  final bool loading;

  @override
  State<HomeArticle> createState() => _HomeArticleState();
}

class _HomeArticleState extends State<HomeArticle> {
  int _current = 0;
  final CarouselController _controller = CarouselController();

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
                    Text('Artikel terkait', style: TextStyle(color: Color(0xFF777777), fontSize: 18, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1, height: 1.2),),
                    Text('Artikel Terbaru', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 32, fontFamily: 'Baskerville', letterSpacing: 1.3, wordSpacing: 1.2, height: 1.3),),
                  ],
                ),
              ),
              const SizedBox(height: 20,),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widget.loading 
                  ? ({for(var i = 0; i < 3; i++) Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                    child: SizedBox(
                      width: 360,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: SkeletonLine(
                              style: SkeletonLineStyle(
                                width: double.infinity,
                                height: 200
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: const [
                              SkeletonLine(
                                style: SkeletonLineStyle(
                                  width: 120,
                                  height: 15
                                ),
                              ),
                              SizedBox(width: 10),
                              SkeletonLine(
                                style: SkeletonLineStyle(
                                  width: 80,
                                  height: 15
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const SkeletonLine(
                            style: SkeletonLineStyle(
                              width: 300,
                              height: 20
                            ),
                          ),
                          const SizedBox(height: 10),
                          SkeletonParagraph(
                            style: const SkeletonParagraphStyle(
                              padding: EdgeInsets.zero,
                              lines: 3,
                              spacing: 6,
                              lineStyle: SkeletonLineStyle(
                                randomLength: true,
                                minLength: 120,
                                height: 15
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  )}).expand((padding) => [padding]).toList()
                  : widget.newArticle.sublist(0, 3).map((e) => 
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: SizedBox(
                        width: 320,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: GestureDetector(     
                            onTap: () {
                              pushNewScreen(context, screen: ArticleDetail(id: e['id'] ?? ''), withNavBar: false);
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Center(
                                  child: CachedNetworkImage(
                                    imageUrl: e['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                                    progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                      child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                                    ),
                                    errorWidget: (context, url, error) => const Icon(Icons.error),
                                    width: 320,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                ),
                                const SizedBox(height: 10,),
                                RichText(text: TextSpan(
                                  children: [
                                    TextSpan(text: 'By ${e["Penulis"]} ', style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5)),
                                    const WidgetSpan(child: Padding(
                                      padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                      child: Icon(Icons.comment, size: 15, color: Color(0xFF777777)),
                                    )),
                                    TextSpan(text: '${e["JumlahKomen"]} Komentar', style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5))
                                  ]
                                )),
                                const SizedBox(height: 10,),
                                Text(e['Judul'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1, height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis,),
                                const SizedBox(height: 10,),
                                Text(e['Teaser'], style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5, height: 1.2), maxLines: 3, overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 10,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}