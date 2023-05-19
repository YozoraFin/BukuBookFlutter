import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/detailbook.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class Katalog extends StatefulWidget {
  const Katalog({super.key});

  @override
  State<Katalog> createState() => KatalogState();
}

class KatalogState extends State<Katalog> {
  List _bukuList = [];
  List _bukuData = [];
  bool _loading = true;
  List _genreList = [];
  bool _loadingGenre = true;
  int _offset = 10;
  bool _continue = true;
  final FocusNode searchFocusNode = FocusNode();
  final RefreshController _refreshController = RefreshController(initialRefresh: false);
  TextEditingController keywordController = TextEditingController();
  final _scrollController = ScrollController();
  
  final NumberFormat idr = NumberFormat('#,##0', 'id');

  String _keyword = '';
  String _genre = '';
  String _sort = '';
  String _min = '';
  String _max = '';
  bool _hideEmpty = true;

  int _showGenre = 5;
  RangeValues _rangeHarga = const RangeValues(0.0, 1.0);
  double _maxHarga = 0;

  @override
  void initState() {
    super.initState();
    getBuku();
    getGenre();
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
      int sub = _bukuData.sublist(_offset).length;
      if(_continue) {
        if(sub > 10) {
          setState(() {
            _bukuList.addAll(_bukuData.sublist(_offset, _offset+10));
            _offset += 10;
          });
        } else {
          setState(() {
            _bukuList.addAll(_bukuData.sublist(_offset, _offset+sub));
            _continue = false;
          });
        }
      }
    }
  }

  setFocus() {
    Future.delayed(const Duration(seconds: 1000),(){
      searchFocusNode.requestFocus();
    });
  }

  getGenre() {
    Dio().get('${Constants.baseUrl}/genre')
    .then((value) {
      setState(() {
        _genreList = value.data['data'];
        _loadingGenre = false;
      });
    });
  }

  getBuku() {
    Dio().get('${Constants.baseUrl}/buku?keyword=$_keyword&genre=$_genre&sort=$_sort&min=$_min&max=$_max')
    .then((value) {
      var min = 0.0;
      var max = value.data['max']/1.0;
      if (_min != '') {
        min = double.parse(_min);
      }
      if(_max != '') {
        max = double.parse(_max);
      }
      setState(() {
        var data = value.data['data'];
        if(_hideEmpty) {
          data = value.data['data'].where((val) => val['Stok'] != 0).toList();
        }
        var length = data.length;
        if(length > 10) {
          _bukuList = data.sublist(0, 10);
        } else {
          _bukuList = data.sublist(0, length);
        }
        _bukuData = data;
        _loading = false;
        _rangeHarga = RangeValues(min, max);
        _maxHarga = value.data['max']/1.0;
      });
    });
    _refreshController.refreshCompleted();
  }

  clearFilter(setter) {
      setter(() {
      _genre = '';
      _sort = '';
      _min = '';
      _max = '';
      _rangeHarga = RangeValues(0.0, _maxHarga);
      _offset = 10;
      _continue = true;
      _hideEmpty = true;
    });
    getBuku();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      
      child: Scaffold(
        appBar: AppBar(
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: Row(
              children: [
                Expanded(
                  flex: 6,
                  child: SizedBox(
                    height: 35,
                    child: TextFormField(
                      focusNode: searchFocusNode,
                      onFieldSubmitted: (val) {
                        setState(() {
                          _keyword = keywordController.text;
                        });
                        getBuku();
                      },
                      controller: keywordController,
                      style: const TextStyle(
                        fontFamily: 'OpenSans',
                        letterSpacing: 0.5
                      ),
                      decoration: InputDecoration(
                        fillColor:const Color(0xFFFAFAFA),
                        filled: true,
                        suffixIcon: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            setState(() {
                              _keyword = keywordController.text;
                            });
                            getBuku();
                          },
                          icon: const Icon(Icons.search),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                        ),
                        hintText: 'Cari...',
                        hintStyle: const TextStyle(
                          fontFamily: 'OpenSans',
                          letterSpacing: 0.5
                        ),
                        contentPadding: const EdgeInsets.only(left: 10)
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: IconButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if(!_loadingGenre && !_loading) {
                        showModalBottomSheet(
                          backgroundColor: Colors.white,
                          context: context, 
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical( 
                              top: Radius.circular(10.0),
                            ),
                          ),
                          isScrollControlled: true,
                          builder: (BuildContext context) {
                            return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom), 
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              const Text('Filter', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24, fontFamily: 'SourceSans', letterSpacing: 0.7)),
                                              const SizedBox(width: 10,),
                                              if(_genre != '' || _sort != '' || _min != '' || _max != '' || !_hideEmpty) GestureDetector(onTap: () => clearFilter(setState), child: const FaIcon(FontAwesomeIcons.filterCircleXmark, size: 20,),),
                                              const Spacer(),
                                              IconButton(
                                                onPressed: () => Navigator.pop(context), 
                                                icon: const Icon(Icons.clear)
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 25,),
                                          const Text('Urutkan dari: ', style: TextStyle(fontSize: 18, fontFamily: 'SourceSans', letterSpacing: 0.5),),
                                          const SizedBox(height: 15,),
                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: ChoiceChip(
                                                  labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                                                  selectedColor: Colors.blue,
                                                  selected: 'asc' == _sort,
                                                  onSelected: (_) {
                                                    setState(() {
                                                      _loading = true;
                                                      _offset = 10;
                                                      _continue = true;
                                                    });
                                                    if(_sort == 'asc') {
                                                      setState(() {
                                                        _sort = '';
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _sort = 'asc';
                                                      });
                                                    } 
                                                    getBuku();
                                                  },
                                                  label: Text('A-Z', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, color: 'asc' == _sort ? Colors.white : Colors.black),),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: ChoiceChip(
                                                  labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                                                  selectedColor: Colors.blue,
                                                  selected: 'desc' == _sort,
                                                  onSelected: (_) {
                                                    setState(() {
                                                      _loading = true;
                                                      _offset = 10;
                                                      _continue = true;
                                                    });
                                                    if(_sort == 'desc') {
                                                      setState(() {
                                                        _sort = '';
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _sort = 'desc';
                                                      });
                                                    } 
                                                    getBuku();
                                                  },
                                                  label: Text('Z-A', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, color: 'desc' == _sort ? Colors.white : Colors.black),),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: ChoiceChip(
                                                  labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                                                  selectedColor: Colors.blue,
                                                  selected: 'Termurah' == _sort,
                                                  onSelected: (_) {
                                                    setState(() {
                                                      _loading = true;
                                                      _offset = 10;
                                                      _continue = true;
                                                    });
                                                    if(_sort == 'Termurah') {
                                                      setState(() {
                                                        _sort = '';
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _sort = 'Termurah';
                                                      });
                                                    } 
                                                    getBuku();
                                                  },
                                                  label: Text('Termurah', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, color: 'Termurah' == _sort ? Colors.white : Colors.black),),
                                                ),
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: ChoiceChip(
                                                  labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                                                  selectedColor: Colors.blue,
                                                  selected: 'Termahal' == _sort,
                                                  onSelected: (_) {
                                                    setState(() {
                                                      _loading = true;
                                                      _offset = 10;
                                                      _continue = true;
                                                    });
                                                    if(_sort == 'Termahal') {
                                                      setState(() {
                                                        _sort = '';
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _sort = 'Termahal';
                                                      });
                                                    } 
                                                    getBuku();
                                                  },
                                                  label: Text('Termahal', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, color: 'Termahal' == _sort ? Colors.white : Colors.black),),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 25),
                                          Row(
                                            children: [
                                              const Text('Genre:', style: TextStyle(fontSize: 18, fontFamily: 'SourceSans', letterSpacing: 0.5),),
                                              const Spacer(),
                                              if(_showGenre == 5) GestureDetector(onTap: () => setState(() {_showGenre = _genreList.length;}), child: const Text('Tampilkan semua?', style: TextStyle(color: Colors.blue),))
                                              else GestureDetector(onTap: () => setState(() {_showGenre = 5;}), child: const Text('Sembunyikan', style: TextStyle(color: Colors.blue),),)
                                            ],
                                          ),
                                          const SizedBox(height: 15,),
                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              for(var genre in _genreList.sublist(0, _showGenre)) Padding(
                                                padding: const EdgeInsets.only(bottom: 10),
                                                child: ChoiceChip(
                                                  labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                  backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                                                  selectedColor: Colors.blue,
                                                  selected: genre['Genre'] == _genre,
                                                  onSelected: (_) {
                                                    setState(() {
                                                      _loading = true;
                                                      _offset = 10;
                                                      _continue = true;
                                                    });
                                                    if(_genre == genre['Genre']) {
                                                      setState(() {
                                                        _genre = '';
                                                      });
                                                    } else {
                                                      setState(() {
                                                        _genre = genre['Genre'];
                                                      });
                                                    }
                                                    getBuku();
                                                  },
                                                  label: Text('${genre['Genre']} (${genre['Total']})', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, color: genre['Genre'] == _genre ? Colors.white : Colors.black),),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 25),
                                          const Text('Harga: ', style: TextStyle(fontSize: 18, fontFamily: 'SourceSans', letterSpacing: 0.5),),
                                          const SizedBox(height: 15,),
                                          Row(
                                            children: [
                                              Expanded(
                                                flex: 1,
                                                child: Align(alignment: Alignment.centerRight, child: Text('Rp ${idr.format(_rangeHarga.start.round())}', style: const TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5),))
                                              ),
                                              RangeSlider( 
                                                values: _rangeHarga,
                                                divisions: _maxHarga~/5000.toInt(),
                                                min: 0.0,
                                                max: _maxHarga, 
                                                onChanged: (val) {
                                                  setState(() {
                                                    _rangeHarga = val;
                                                  });
                                                },
                                                onChangeEnd: (val) {
                                                  setState(() {
                                                    _loading = true;
                                                    _offset = 10;
                                                    _continue = true;
                                                    _min = '${val.start.round()}';
                                                    _max = '${val.end.round()}';
                                                  });
                                                  getBuku();
                                                },
                                                labels: RangeLabels(
                                                  'Rp ${idr.format(_rangeHarga.start.round())}',
                                                  'Rp ${idr.format(_rangeHarga.end.round())}'
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Text('Rp ${idr.format(_rangeHarga.end.round())}', style: const TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5),)
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 25,),
                                          const Text('Stok Habis:', style: TextStyle(fontSize: 18, fontFamily: 'SourceSans', letterSpacing: 0.5),),
                                          const SizedBox(height: 15,),
                                          Wrap(
                                            spacing: 8,
                                            children: [
                                              ChoiceChip(
                                                selected: _hideEmpty,
                                                labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                                backgroundColor: const Color.fromARGB(255, 244, 244, 244),
                                                selectedColor: Colors.blue,
                                                onSelected: (_) {
                                                  setState(() {
                                                    _loading = true;
                                                    _offset = 10;
                                                    _continue = true;
                                                    _hideEmpty = !_hideEmpty;
                                                    if(_hideEmpty) {
                                                      _bukuList = _bukuData;
                                                    } else {
                                                      _bukuList = _bukuData.where((element) => element['Stok'] != 0).toList();
                                                    }
                                                  });
                                                  getBuku();
                                                },
                                                label: Text('Sembunyikan', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, color: _hideEmpty ? Colors.white : Colors.black),),
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            });
                          }
                        ).then((value) {
                          setState(() {
                            _showGenre = 5;
                          });
                        });
                      }
                    }, 
                    icon: Icon(Icons.filter_alt, color: _loading || _loadingGenre ? Colors.white.withAlpha(100) : Colors.white,)
                  ),
                )
              ],
            ),
          ),
        ),
        body: SmartRefresher(
          controller: _refreshController,
          header: WaterDropMaterialHeader(backgroundColor: Theme.of(context).primaryColor),
          onRefresh: () {
            setState(() {
              _loading = true;
              _loadingGenre = true;
              _showGenre = 5;
            });
            keywordController.clear();
            clearFilter(setState);
            getGenre();
          },
          child: ListView(
            controller: _scrollController,
            shrinkWrap: true,
            children: [
              ..._loading 
              ? ({for(var i = 0; i < 10; i++)
              // ignore: prefer_const_constructors
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: const SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 120
                  ),
                ),
              )}).expand((padding) => [padding]).toList()
              : ({for(var buku in _bukuList) Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Card(
                  clipBehavior: Clip.hardEdge,
                  child: InkWell(
                    onTap: () {
                      pushNewScreen(context, screen: DetailBook(id: buku['ID']), withNavBar: false,);
                    },
                    child: SizedBox(
                      height: 120,
                      child: Row(
                        children: [
                          CachedNetworkImage(
                            imageUrl: buku['Sampul'][0]['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                            progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                              child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                            ),
                            errorWidget: (context, url, error) => const Icon(Icons.error),
                            width: 90,
                            height: 120,
                            fit: BoxFit.cover,
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(buku['Judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, overflow: TextOverflow.ellipsis, fontFamily: 'SourceSans', letterSpacing: 0.7), maxLines: 1,),
                                  const SizedBox(height: 5,),
                                  Text('by ${buku['Penulis']}', style: const TextStyle(fontSize: 14, fontFamily: 'OpenSans', letterSpacing: 0.5), overflow: TextOverflow.ellipsis, maxLines: 1,),
                                  const SizedBox(height: 8,),
                                  Row(
                                    children: [
                                      const Icon(Icons.category, size: 14,),
                                      const SizedBox(width: 3,),
                                      Text(buku['Genre']['Genre'], style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5),),
                                      const SizedBox(width: 15,),
                                      FaIcon(FontAwesomeIcons.box, size: 14, color: buku['Stok'] == 0 ? Colors.red : Colors.black),
                                      const SizedBox(width: 3,),
                                      Text('${buku['Stok']}', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5, color: buku['Stok'] == 0 ? Colors.red : Colors.black),)
                                    ],
                                  ),
                                  const Spacer(),
                                  Align(alignment: Alignment.bottomRight, child: Text('Rp ${idr.format(buku['Harga'])}', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'SourceSans', letterSpacing: 0.7),))
                                ],
                              ),
                            ),
                          )
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