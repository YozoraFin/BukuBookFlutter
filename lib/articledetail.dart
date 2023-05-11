import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/bottomnavbar.dart';
import 'package:login_page/constants.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class ArticleDetail extends StatefulWidget {
  const ArticleDetail({super.key, required this.id});
  final num id;

  @override
  State<ArticleDetail> createState() => _ArticleDetailState();
}

class _ArticleDetailState extends State<ArticleDetail> {
  TextEditingController komentarController = TextEditingController();
  final box = GetStorage();
  Map<String, dynamic> _detailArticle = {
    'Judul': '',
    'Isi': '',
    'Penulis': '',
    'Kategori': '',
    'KategoriID': 0,
    'SrcGambar': '',
    'Tanggal': '',
    'Next': {
      'id': 0,
      'Judul': '',
      'SrcGambar': ''
    },
    'Prev': {
      'id': 0,
      'Judul': '',
      'SrcGambar': ''
    },
    'Komentar': [],
    'JumlahKomen': 0
  };
  bool _loading = true;
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  @override
  void initState() {
    super.initState();
    getArticle();
  }

  getArticle() {
    Dio().get('${Constants.baseUrl}/artikel/${widget.id}')
    .then((value) {
      setState(() {
        _detailArticle = value.data['data'];
        _loading = false;
      });
    });
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          shadowColor: Colors.transparent,
          title: Text('${_detailArticle['Judul']}', style: const TextStyle(fontFamily: 'SourceSans', letterSpacing: 0.5),),
        ),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: () {
            setState(() {
              _loading = true;
            });
            getArticle();
            komentarController.clear();
          },
          child: ListView(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            children: [
              const SizedBox(height: 100,),
              _loading 
              ? const SkeletonLine(
                style: SkeletonLineStyle(
                  width: 350,
                  height: 250,
                  alignment: Alignment.center
                ),
              )
              : Center(
                child: CachedNetworkImage(
                  imageUrl: _detailArticle['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                    child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  width: 350,
                  height: 250,
                  fit: BoxFit.cover,
                )
              ),
              const SizedBox(height: 25),
              _detailArticle['Kategori'] == 'Kategori' ?  
                const SizedBox(height: 0,)
              : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: _loading 
                ? const SkeletonLine(
                  style: SkeletonLineStyle(
                    width: 120,
                    height: 20,
                  ),
                )
                : GestureDetector(
                  onTap: () {
                    pushNewScreen(context, screen: BottomNavbar(initial: 1, kategori: _detailArticle['Kategori'],));
                  },
                  child: Row(
                    children: [
                      const Icon(Icons.category),
                      const SizedBox(width: 5,),
                      Text(_detailArticle['Kategori'], style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5))
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: _loading 
                ? const SkeletonLine(
                  style: SkeletonLineStyle(
                    width: 100,
                    height: 20,
                  ),
                )
                : Row(
                  children: [
                    const Icon(Icons.person),
                    const SizedBox(width: 5,),
                    Text(_detailArticle['Penulis'], style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: _loading 
                ? const SkeletonLine(
                  style: SkeletonLineStyle(
                    width: 110,
                    height: 20,
                  ),
                )
                : Row(
                  children: [
                    const Icon(Icons.calendar_month),
                    const SizedBox(width: 5,),
                    Text(_detailArticle['Tanggal'], style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5))
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: _loading 
                ? const SkeletonLine(
                  style: SkeletonLineStyle(
                    width: 110,
                    height: 20,
                  ),
                )
                : Row(
                  children: [
                    const Icon(Icons.chat_bubble),
                    const SizedBox(width: 5,),
                    Text('${_detailArticle['JumlahKomen']} Komentar', style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5))
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _loading 
                ? const SkeletonLine(
                  style: SkeletonLineStyle(
                    width: 250,
                    height: 25,
                  ),
                )
                : Text(_detailArticle['Judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.2, height: 1.2),),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                child: _loading 
                ? SkeletonParagraph(
                  style: const SkeletonParagraphStyle(
                    padding: EdgeInsets.zero,
                    lines: 3,
                    spacing: 6,
                    lineStyle: SkeletonLineStyle(
                      minLength: 200,
                      randomLength: true,
                      height: 12
                    ),
                  ) 
                )
                : Html(
                  data: _detailArticle['Isi'],
                  style: {
                    '*': Style(
                      padding: EdgeInsets.zero,
                      margin: EdgeInsets.zero,
                      fontFamily: 'OpenSans',
                      letterSpacing: 0.5,
                      lineHeight: LineHeight.percent(120)
                    )
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _loading 
                ? const SkeletonLine(
                  style: SkeletonLineStyle(
                    width: 180,
                    height: 25,
                  ),
                )
                : const Text('Artikel Lainnya', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.2),),
              ),
              _detailArticle['Prev']['id'] != 0 ? GestureDetector(     
                onTap: () {
                  pushNewScreen(context, screen: ArticleDetail(id: _detailArticle['Prev']['id'] ?? ''));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _loading 
                      ? SkeletonLine(
                        style: SkeletonLineStyle(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width*0.60,
                        ),
                      )
                      : Center(
                        child: CachedNetworkImage(
                          imageUrl: _detailArticle['Prev']['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                            child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width*0.60,
                          fit: BoxFit.cover,
                        )
                      ),
                      const SizedBox(height: 10),
                      _loading 
                      ? SkeletonParagraph(
                        style: const SkeletonParagraphStyle(
                          padding: EdgeInsets.zero,
                          lines: 2,
                          spacing: 6,
                          lineStyle: SkeletonLineStyle(
                            minLength: 200,
                            height: 14,
                            randomLength: true
                          )
                        )
                      )
                      : Text(_detailArticle['Prev']['Judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'OpenSans', letterSpacing: 0.5),)
                    ],
                  ),
                ),
              ) : const SizedBox(height: 0, width: 0,),
              _detailArticle['Next']['id'] != 0 ? GestureDetector(     
                onTap: () {
                  pushNewScreen(context, screen: ArticleDetail(id: _detailArticle['Next']['id'] ?? ''));
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _loading 
                      ? SkeletonLine(
                        style: SkeletonLineStyle(
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width*0.60,
                        ),
                      )
                      : Center(
                        child: CachedNetworkImage(
                          imageUrl: _detailArticle['Next']['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                            child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                          ),
                          errorWidget: (context, url, error) => const Icon(Icons.error),
                          width: double.infinity,
                          height: MediaQuery.of(context).size.width*0.60,
                          fit: BoxFit.cover,
                        )
                      ),
                      const SizedBox(height: 10),
                      _loading 
                      ? SkeletonParagraph(
                        style: const SkeletonParagraphStyle(
                          padding: EdgeInsets.zero,
                          lines: 2,
                          spacing: 6,
                          lineStyle: SkeletonLineStyle(
                            minLength: 200,
                            height: 14,
                            randomLength: true
                          )
                        )
                      )
                      : Text(_detailArticle['Next']['Judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'OpenSans', letterSpacing: 0.5),)
                    ],
                  ),
                ),
              ) : const SizedBox(width: 0, height: 0,),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Divider(color: Colors.black),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _loading 
                ? const SkeletonLine(
                  style: SkeletonLineStyle(
                    width: 140,
                    height: 25,
                  ),
                )
                : const Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.2)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: _loading 
                ? const SkeletonLine(
                  style: SkeletonLineStyle(
                    width: double.infinity,
                    height: 200,
                  ),
                )
                : TextFormField(
                  controller: komentarController,
                  minLines: 6,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  style: const TextStyle(
                    fontFamily: 'OpenSans',
                    letterSpacing: 0.5
                  ),
                  decoration: const InputDecoration(
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                    labelText: 'Komentar',
                    labelStyle: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5)
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: _loading 
                  ? const SkeletonLine(
                    style: SkeletonLineStyle(
                      width: 60,
                      height: 30,
                      alignment: Alignment.topRight
                    ),
                  )
                  : ElevatedButton(
                    onPressed: () {
                      if(komentarController.text == '') {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Komentar tidak boleh kosong!', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5),)),
                        );
                      } else {
                        Dio().post('${Constants.baseUrl}/komentar/send', data: {'AksesToken': box.read('accesstoken'), 'ArticleID': widget.id, 'Komentar': komentarController.text})
                        .then((value) {
                          getArticle();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Komentar berhasil ditambahkan')),
                          );
                          komentarController.clear();
                        });
                      }
                    },
                    child: const Text('Kirim'),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Center(
                  child: _loading 
                  ? const SkeletonLine(
                    style: SkeletonLineStyle(
                      width: 140,
                      height: 25,
                      alignment: Alignment.center
                    ),
                  )
                  : Text('${_detailArticle['JumlahKomen']} Komentar', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, fontFamily: 'SourceSans', letterSpacing: 0.6, wordSpacing: 1.1),),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ..._loading 
                    ? ({for(var i = 0; i < 4; i++) Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: const [
                                SkeletonLine(
                                  style: SkeletonLineStyle(
                                    width: 75,
                                    height: 75,
                                  ),
                                ),
                              ],
                            )
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                children: [
                                  const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 150,
                                      height: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  const SkeletonLine(
                                    style: SkeletonLineStyle(
                                      width: 100,
                                      height: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  SkeletonParagraph(
                                    style: const SkeletonParagraphStyle(
                                      padding: EdgeInsets.zero,
                                      lines: 3,
                                      spacing: 6,
                                      lineStyle: SkeletonLineStyle(
                                        minLength: 100,
                                        randomLength: true,
                                        height: 12
                                      )
                                    ),
                                  )
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    )})
                    : ({for(var komentar in _detailArticle['Komentar']) Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: komentar['Customer']['Profil'] == '' ? Constants.emptProfile : komentar['Customer']['Profil'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                    child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 3,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(komentar['Customer']['NamaLengkap'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, fontFamily: 'SourceSans', letterSpacing: 0.5, wordSpacing: 1.1)),
                                  const SizedBox(height: 7),
                                  Text(komentar['Tanggal'], style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5, wordSpacing: 1.1),),
                                  const SizedBox(height: 10),
                                  Text(komentar['Komentar'], style: const TextStyle(color: Color(0xFF555555), height: 1.5, letterSpacing: 0.5, fontFamily: 'OpenSans'),)
                                ],
                              ),
                            )
                          )
                        ],
                      ),
                    )})
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}