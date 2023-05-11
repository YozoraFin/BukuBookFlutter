import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/articledetail.dart';
import 'package:login_page/constants.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class ArticleList extends StatefulWidget {
  const ArticleList({super.key, this.sKategori});
  final String? sKategori;

  @override
  State<ArticleList> createState() => _ArticleListState();
}

class _ArticleListState extends State<ArticleList> {
  List _articleList = [];
  List _articleData = [];
  List _kategori = [];
  int _offset = 0;
  bool _loading = true;
  bool _loadingKategori = true;
  // bool _loadingNext = false;
  bool _continue = true;
  final _scrollController = ScrollController();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  String? _curKategori = '';

  @override
  void initState() {
    super.initState();
    if(widget.sKategori?.isNotEmpty == true) {
      getArticleByKategori(widget.sKategori);
      setState(() {
        _curKategori = widget.sKategori;
      });
    } else {
      getArticle();
    }
    getKategori();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // ini nanti nambain offset
      int sub = _articleData.sublist(_offset).length;
      if(_continue) {
        if(sub > 5) {
          setState(() {
            _articleList.addAll(_articleData.sublist(_offset, _offset+5));
            _offset += 5;
          });
        } else {
          setState(() {
            _articleList.addAll(_articleData.sublist(_offset, _offset+sub));
            _continue = false;
          });
        }
      }
    }
  }

  getKategori() {
    Dio().get('${Constants.baseUrl}/kategori')
    .then((value) {
      setState(() {
        _kategori = value.data['data'];
        _loadingKategori = false;
      });
    });
  }

  getArticle() {
    Dio().get('${Constants.baseUrl}/artikel')
    .then((value) {
      if(value.data['data'].length > 5) {
        setState(() {
          _articleList = value.data['data'].sublist(0, 5);
          _articleData = value.data['data'];
          _offset = 5;
          _continue = true;
          _loading = false;
        });
      } else {
        setState(() {
          _articleList = value.data['data'];
          _continue = false;
          _loading = false;
        });
      }
      _refreshController.refreshCompleted();
    });
  }

  getArticleByKategori(kategori) {
    Dio().get('${Constants.baseUrl}/artikel/?kategori=$kategori')
    .then((value) {
      if(value.data['data'].length > 5) {
        setState(() {
          _articleList = value.data['data'].sublist(0, 5);
          _articleData = value.data['data'];
          _offset = 5;
          _continue = true;
          _loading = false;
        });
      } else {
        setState(() {
          _articleList = value.data['data'];
          _continue = false;
          _loading = false;
        });
      }
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // backgroundColor: Color(0xFFFAFAFA),
        shadowColor: const Color(0xFFCCE4FF),
        title: const Text('Daftar Artikel', style: TextStyle(fontFamily: 'SourceSans', letterSpacing: 0.5, wordSpacing: 1.1),),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: IconButton(
              onPressed: () {
                if(!_loadingKategori) {
                  showModalBottomSheet(
                    backgroundColor: Colors.white,
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
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.fromLTRB(16, 16, 16, 4),
                                child: Text('Kategori', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'SourceSans', letterSpacing: 0.7)),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16),
                                child: SizedBox(width: 100, child: Divider(color: Colors.black,)),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: Wrap(
                                  spacing: 8,
                                  children: [
                                    for(var kategori in _kategori) Padding(
                                      padding: const EdgeInsets.only(bottom: 10),
                                      child: ChoiceChip(
                                        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                        backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                                        selectedColor: Colors.blue,
                                        selected: _curKategori == kategori['Kategori'],
                                        onSelected: (_) {
                                          if(_curKategori == kategori['Kategori']) {
                                            getArticle();
                                            setState(() {
                                              _curKategori = '';
                                              _loading = true;
                                            });
                                          } else {
                                            getArticleByKategori(kategori['Kategori']);
                                            setState(() {
                                              _curKategori = kategori['Kategori'];
                                              _loading = true;
                                            });
                                          }
                                        },
                                        label: Text('${kategori['Kategori']} (${kategori['Total']})', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, fontSize: 16, color: _curKategori == kategori['Kategori'] ? Colors.white : Colors.black),),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16)
                            ],
                          ),
                        );
                      });
                    }
                  );
                }
              },
              icon: Icon(Icons.filter_alt, color: _loadingKategori ? Colors.white.withAlpha(150) : Colors.white,),
            )
          ),
        ]
      ),
      body: SmartRefresher(
        header: WaterDropMaterialHeader(backgroundColor: Theme.of(context).primaryColor),
        controller: _refreshController,
        onRefresh: () {
          getArticle();
          getKategori(); 
          setState(() {
            _loading = true;
            _loadingKategori = true;
          })
        ;},
        child: ListView(
          controller: _scrollController,
          shrinkWrap: true,
          children: [
            ..._loading ? ({for(var i = 0; i < 5; i++) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
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
            )}).expand((padding) => [padding]).toList() : ({for(var artikel in _articleList) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: GestureDetector(
                onTap: () {
                  pushNewScreen(context, screen: ArticleDetail(id: artikel['id'] ?? ''), withNavBar: false);
                },
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:  [
                    Center(
                      child: CachedNetworkImage(
                        imageUrl: artikel['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                        progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                          child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                        ),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      )
                    ),
                    const SizedBox(height: 10,),
                    RichText(text: TextSpan(
                      children: [
                        TextSpan(text: 'By ${artikel["Penulis"]} ', style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5)),
                        const WidgetSpan(child: Padding(
                          padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                          child: Icon(Icons.comment, size: 15, color: Color(0xFF777777),),
                        )),
                        TextSpan(text: '${artikel["JumlahKomen"]} Komentar', style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5))
                      ]
                    )),
                    const SizedBox(height: 10,),
                    Text(artikel['Judul'], style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1)),
                    const SizedBox(height: 10,),
                    Text(artikel['Teaser'], style: const TextStyle(color: Color(0xFF777777), fontFamily: 'OpenSans', letterSpacing: 0.5))
                  ],
                ),
              ),
            )}).expand((padding) => [padding]).toList(),
            // _loadingNext ? Container(
            //   color: Color(0xFFDDDDDD),
            //   height: 40,
            //   child: const Center(child: Text('Sedang memuat...', style: TextStyle(color: Color(0xFF384AEB)),)),
            // ) : SizedBox(height: 0, width: 0),
            // const SizedBox(height: 10,)
          ],
        ),
      ),
    );
  }
}