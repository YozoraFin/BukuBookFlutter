import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:login_page/checkout.dart';
import 'package:login_page/constants.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class Cart extends StatefulWidget {
  // const Cart({super.key, required this.data, required this.total, required this.subtotal, required this.loading});
  const Cart({super.key});

  // final List data;
  // final num total;
  // final num subtotal;
  // final bool loading;

  @override
  CartState createState() => CartState();
}

class CartState extends State<Cart> {
  Timer? _debounceTimer;
  num _total = 0;
  num _subTotal = 0;
  RefreshController _refreshController = RefreshController();
  List _listItem = [];
  bool _loading = true;
  bool _pressed = false;
  bool _showed = false;
  final NumberFormat idr = NumberFormat('#,##0', 'id');
  final box = GetStorage();
  
  @override
  void initState() {
    super.initState();
    // setState(() {
    //   _listItem = widget.data;
    //   _subTotal = widget.subtotal;
    //   _loading = widget.loading;
    //   _total = widget.total;
    // });
    getCart();
  }

  checkStok() {
    for (var item in _listItem) {
      if(item['Buku']['Stok'] == 0) {
        return false;
      }
    }
    return true;
  }

  getCart() {
    Dio().post('${Constants.baseUrl}/cart/', data: {'AksesToken': box.read('accesstoken')})
    .then((value) { 
      num total = 0;
      num subtotal = 0;
      for (var item in value.data['data']) {
        total += item['Jumlah'];
        subtotal += item['Jumlah']*item['Buku']['Harga'];
      }
      setState(() {
        _total = 0;
        _listItem = value.data['data']; 
        _loading = false;
        _total = total;
        _subTotal = subtotal;
      });
    });
    _refreshController.refreshCompleted();
  }

  updateCart(index) {
    if(_debounceTimer != null) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      var item = _listItem[index];
      Dio().post('${Constants.baseUrl}/cart/update', data: {'qty': item['Jumlah'], 'BukuID': item['Buku']['id'], 'AksesToken': box.read('accesstoken')});
    });
  }

  deleteCart(index) {
    Dio().post('${Constants.baseUrl}/cart/remove', data: {'BukuID': _listItem[index]['Buku']['id'], 'AksesToken': box.read('accesstoken')})
    .then((value) => getCart());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang'),
      ),
      body: Stack(
        children: [
          SmartRefresher(
            controller: _refreshController,
            onRefresh: () {
              setState(() {
                _loading = true;
                _subTotal = 0;
              });
              getCart();
            },
            child: ListView(
              shrinkWrap: true,
              children: [
                ..._loading
                // ignore: prefer_const_constructors
                ? ({for(var i = 0; i < 3; i++) Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  child: const SkeletonLine(
                    style: SkeletonLineStyle(
                      height: 120,
                      width: double.infinity
                    ),
                  ),
                )})
                : ({for(var i = 0; i < _listItem.length; i++) 
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      Expanded(
                        flex: 2,
                        child: Row(
                          children: [
                            CachedNetworkImage(
                              imageUrl: _listItem[i]['Buku']['Sampul'][0]['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                              progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                                child: Center(
                                  child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(Icons.error),
                              width: 90,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                      ),
                      // Info & Button
                      Expanded(
                        flex: 5,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_listItem[i]['Buku']['Judul'], style: TextStyle(color: _listItem[i]['Buku']['Stok'] == 0 ? Colors.red : const Color(0xFF777777), fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis,),
                              const SizedBox(height: 10,),
                              Text('Rp ${idr.format(_listItem[i]['Buku']['Harga'])}', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _listItem[i]['Buku']['Stok'] == 0 ? Colors.red : Colors.black,),),
                              const SizedBox(height: 10,),
                              Text('Stok: ${_listItem[i]['Buku']['Stok']}', style: TextStyle(color: _listItem[i]['Buku']['Stok'] == 0 ? Colors.red : const Color(0xFF777777), fontSize: 14)),
                              const SizedBox(height: 10,),
                              Row(
                                children: [
                                  GestureDetector(
                                    onLongPressUp: () {
                                      setState(() {
                                        _pressed = false;
                                      });
                                      updateCart(i);
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        _pressed = true;
                                      });
                                      Timer.periodic(const Duration(milliseconds: 50), (timer) {
                                        if (!_pressed) {
                                          timer.cancel();
                                        } else {
                                          setState(() {
                                            if(_listItem[i]['Jumlah'] > 1) {
                                              _listItem[i]['Jumlah'] -= 1;
                                              _subTotal -= _listItem[i]['Buku']['Harga'];
                                              _total -= 1;
                                            }
                                          });
                                        }
                                      });
                                    },
                                    child: IconButton(
                                      splashRadius: 24,
                                      splashColor: const Color(0x22384AEB),
                                      onPressed: () {
                                        setState(() {
                                          if(_listItem[i]['Jumlah'] >= 1) {
                                            _listItem[i]['Jumlah'] -= 1;
                                            _total -= 1;
                                            _subTotal -= _listItem[i]['Buku']['Harga'];
                                            updateCart(i);
                                          }
                                          if(_listItem[i]['Jumlah'] < 1) {
                                            if(_listItem[i]['Buku']['Stok'] == 0) {
                                              deleteCart(i);
                                            } else {
                                              showDialog(
                                                context: context, 
                                                builder: (BuildContext context) {
                                                  return AlertDialog(
                                                    title: const Text('Apakah anda yakin?'),
                                                    content: const Text('Setelah dihapus anda harus menambahkannya kembali dari katalog'),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            _listItem[i]['Jumlah'] = 1;
                                                            _subTotal += _listItem[i]['Buku']['Harga'];
                                                          });
                                                          Navigator.pop(context);
                                                        }, 
                                                        child: const Text('Tidak')
                                                      ),
                                                      TextButton(
                                                        onPressed: () {
                                                          deleteCart(i);
                                                          Navigator.pop(context);
                                                        }, 
                                                        child: const Text('Ya')
                                                      )
                                                    ],
                                                  );
                                                }
                                              );
                                            }
                                          }
                                        });
                                      }, 
                                      icon: const Icon(Icons.remove, color: Color(0xFF384AEB),)
                                    ),
                                  ),
                                  Text('${_listItem[i]['Jumlah']}'),
                                  GestureDetector(
                                    onLongPressUp: () {
                                      setState(() {
                                        _pressed = false;
                                        _showed = false;
                                      });
                                      updateCart(i);
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        _pressed = true;
                                      });
                                      Timer.periodic(const Duration(milliseconds: 50), (timer) {
                                        if (!_pressed) {
                                          timer.cancel();
                                        } else {
                                          setState(() {
                                            if(_listItem[i]['Jumlah'] < _listItem[i]['Buku']['Stok'] && _total < 50) {
                                              _listItem[i]['Jumlah'] += 1;
                                              _subTotal += _listItem[i]['Buku']['Harga'];
                                              _total += 1;
                                            } else {
                                              if(!_showed) {
                                                if(_listItem[i]['Buku']['Stok'] > _listItem[i]['Jumlah']) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Tidak bisa membeli lebih dari jumlah stok!'), padding: EdgeInsets.only(bottom: 40, top: 20, left: 15)),
                                                  );
                                                } else {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    const SnackBar(content: Text('Tidak bisa membeli lebih dari 50 barang!'), padding: EdgeInsets.only(bottom: 40, top: 20, left: 15)),
                                                  );
                                                }
                                              }
                                              setState(() {
                                                _showed = true;
                                              });
                                            }
                                          });
                                        }
                                      });
                                    },
                                    child: IconButton(
                                      splashRadius: 24,
                                      splashColor: const Color(0x22384AEB),
                                      onPressed: () {
                                        setState(() {
                                          if(_listItem[i]['Jumlah'] < _listItem[i]['Buku']['Stok'] && _total < 50) {
                                            _listItem[i]['Jumlah'] += 1;
                                            _total += 1;
                                            _subTotal += _listItem[i]['Buku']['Harga'];
                                            updateCart(i);
                                          } else {
                                            if(_listItem[i]['Buku']['Stok'] < _listItem[i]['Jumlah']) {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Tidak bisa membeli lebih dari jumlah stok!'), padding: EdgeInsets.only(bottom: 40, top: 20, left: 15)),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(content: Text('Tidak bisa membeli lebih dari 50 barang!'), padding: EdgeInsets.only(bottom: 40, top: 20, left: 15)),
                                              );
                                            }
                                          }
                                        });
                                      }, 
                                      icon: const Icon(Icons.add, color: Color(0xFF384AEB),)
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    splashRadius: 24,
                                    splashColor: Colors.red.withAlpha(34),
                                    onPressed: () {
                                      if(_listItem[i]['Buku']['Stok'] == 0) {
                                        deleteCart(i);
                                      } else {
                                        showDialog(
                                          context: context, 
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text('Apakah anda yakin?'),
                                              content: const Text('Setelah dihapus anda harus menambahkannya kembali dari katalog'),
                                              actions: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  }, 
                                                  child: const Text('Tidak')
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    deleteCart(i);
                                                    Navigator.pop(context);
                                                  }, 
                                                  child: const Text('Ya')
                                                )
                                              ],
                                            );
                                          }
                                        );
                                      }
                                    }, 
                                    icon: const FaIcon(FontAwesomeIcons.trash, size: 16, color: Colors.red,)
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                )}),
                const SizedBox(height: 70,)
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: 0,
            left: 0,
            child: Container(
              color: Colors.white,
              height: 70,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 10),
                child: Row(
                  children: [
                    Text('Subtotal: Rp ${idr.format(_subTotal)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                    const Spacer(),
                    ElevatedButton(
                      onPressed: () {
                        if(checkStok() && _total < 50) {
                          pushNewScreen(context, screen: CheckOut(), withNavBar: false);
                        } else {
                          if(!checkStok()) {
                            showDialog(
                              context: context, 
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Stok habis!'),
                                  content: const Text('Salah satu dari barang yang ingin anda beli telah kehabisan stok, tolong hapus terlebih dahulu agar bisa melanjutkan pembayaran'),
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
                            showDialog(
                              context: context, 
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Barang kelebihan!'),
                                  content: const Text('Tolong pastikan jumlah barang yang anda beli tidak melebihi 50'),
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
                          }
                        }
                      }, 
                      child: const Text('Bayar!')
                    )
                  ],
                ),
              ),
            )
          )
        ]
      ),
    );
  }
}