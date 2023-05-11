import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/detailorder.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class HistoryOrder extends StatefulWidget {
  const HistoryOrder({super.key});

  @override
  State<HistoryOrder> createState() => _HistoryOrderState();
}

class _HistoryOrderState extends State<HistoryOrder> {
  final box = GetStorage();
  final NumberFormat idr = NumberFormat('#,##0', 'id');
  final _scrollController = ScrollController();
  int _offset = 0;
  List _data = [];
  List _list = [];
  bool _loading = true;
  bool _continue = true;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    getData();
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
      int sub = _data.sublist(_offset).length;
      if(_continue) {
        if(sub > 10) {
          setState(() {
            _list.addAll(_data.sublist(_offset, _offset+10));
            _offset += 10;
          });
        } else {
          setState(() {
            _list.addAll(_data.sublist(_offset, _offset+sub));
            _continue = false;
          });
        }
      }
    }
  }

  getData() {
    Dio().post('${Constants.baseUrl}/order', data: {'AksesToken': box.read('accesstoken')})
    .then((value) {
      setState(() {
        if(value.data['data'].length > 10) {
          _data = value.data['data'];
          _list = value.data['data'].sublist(0, 10);
          _offset = 10;
          _continue = true;
        } else {
          _list = value.data['data'];
          _continue = false;
        }
        _loading = false;
      });
      _refreshController.refreshCompleted();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pembelian', style: TextStyle(fontFamily: 'SourceSans', letterSpacing: 0.5, wordSpacing: 1.1),),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        header: const WaterDropMaterialHeader(),
        onRefresh: () {
          setState(() {
            _loading = true;
          });
          getData();
        },
        child: ListView(
          controller: _scrollController,
          shrinkWrap: true,
          children: [
            ..._loading
            ? ({for(var i = 0; i < 10; i++) Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonLine(
                        style: SkeletonLineStyle(
                          width: 200,
                          height: 18
                        ),
                      ),
                      SizedBox(height: 10,),
                      SkeletonLine(
                        style: SkeletonLineStyle(
                          width: 90,
                          height: 16
                        ),
                      )
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: const [
                      SkeletonLine(
                        style: SkeletonLineStyle(
                          width: 80,
                          height: 16
                        ),
                      ),
                      SizedBox(height: 10,),
                      SkeletonLine(
                        style: SkeletonLineStyle(
                          width: 100,
                          height: 18
                        ),
                      ),
                    ],
                  )
                ],
              ),
            )}).expand((padding) => [padding]).toList()
            : ({for(var data in _list) InkWell(
              onTap: () {
                pushNewScreen(context, screen: DetailOrder(id: data['ID']));
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(data['Invoice'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'SourceSans', letterSpacing: 0.7),),
                        const SizedBox(height: 10,),
                        Text(data['Tanggal'], style: const TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'OpenSans', letterSpacing: 0.5),)
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Total Harga', style: TextStyle(fontSize: 16, fontFamily: 'OpenSans', letterSpacing: 0.5),),
                        const SizedBox(height: 10,),
                        Text('Rp ${idr.format(data['Total'])}', style: const TextStyle(fontSize: 18, color: Colors.blue, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1),)
                      ],
                    )
                  ],
                ),
              ),
            )}).expand((padding) => [padding]).toList()
          ],
        ),
      ),
    );
  }
}