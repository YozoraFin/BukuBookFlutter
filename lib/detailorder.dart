// ignore_for_file: prefer_const_constructors

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class DetailOrder extends StatefulWidget {
  const DetailOrder({super.key, required this.id});
  final num id;

  @override
  State<DetailOrder> createState() => _DetailOrderState();
}

class _DetailOrderState extends State<DetailOrder> {
  final box = GetStorage();
  final NumberFormat idr = NumberFormat('#,##0', 'id');

  Map<String, dynamic> _data = {
    'Alamat': '',
    'Email' : '',
    'Invoice': '',
    'Kodepos': 0,
    'Kota': '',
    'Nama': '',
    'NoTelp': '',
    'Ongkir': 0,
    'Provinsi': '',
    'Tanggal': '',
    'Total': 0,
    'Subtotal': 0,
    'Potongan': 0,
    'PPN': 0,
    'Detail': []
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() {
    Dio().post('${Constants.baseUrl}/order/detail/${widget.id}', data: {'AksesToken': box.read('accesstoken')})
    .then((value) {
      print(value);
      setState(() {
        _data = value.data['data'];
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_data['Invoice']),
      ),
      body: ListView(
        shrinkWrap: true,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Color.fromARGB(255, 230, 242, 248),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Order', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 250, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Invoice', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['Invoice']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 200, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Tanggal', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['Tanggal']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 180, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Total', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': Rp ${idr.format(_data['Total'])}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Color.fromARGB(255, 230, 242, 248),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Informasi Pembeli', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 300, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Nama', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['Nama']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 200, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Telp', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['NoTelp']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 300, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Email', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['Email']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Color.fromARGB(255, 230, 242, 248),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Alamat Tujuan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 15,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 170, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Provinsi', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['Provinsi']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 150, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Kota', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['Kota']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 320, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Jalan', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['Alamat']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                    const SizedBox(height: 10,),
                    _loading
                    ? SkeletonLine(
                      style: SkeletonLineStyle(width: 130, height: 16),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          flex: 1,
                          child: Text('Kodepos', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(': ${_data['Kodepos']}', style: TextStyle(fontSize: 16),),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              color: Color.fromARGB(255, 230, 242, 248),
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Detail Pesanan', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Expanded(
                          flex: 5,
                          child: Text('Judul Buku', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('Jumlah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        ),
                        Expanded(
                          flex: 4,
                          child: Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    ..._loading 
                    ? ({SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                      ),
                    )}).toList()
                    : ({for(var detail in _data['Detail']) Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(detail['Buku']['Judul'], style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 3,
                          child: Text('${detail['Jumlah']}x', style: TextStyle(fontSize: 16),)
                        ),
                        Expanded(
                          flex: 4,
                          child: Text('Rp ${idr.format(detail['Subtotal'])}', style: TextStyle(fontSize: 16),)
                        )
                      ],
                    ),
                    const SizedBox(height: 20)}).toList(),
                    _loading 
                    ? SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                      ),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('Subtotal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        ),
                        const Spacer(flex: 3,),
                        Expanded(
                          flex: 4,
                          child: Text('Rp ${idr.format(_data['Subtotal'])}', style: TextStyle(fontSize: 16),)
                        )
                      ],
                    ),
                    _data['Potongan'] > 0 ? const SizedBox(height: 15) : SizedBox(),
                    _data['Potongan'] > 0 ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('Potongan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        ),
                        const Spacer(flex: 3,),
                        Expanded(
                          flex: 4,
                          child: Text('Rp -${idr.format(_data['Potongan'])}', style: TextStyle(fontSize: 16),)
                        )
                      ],
                    ) : SizedBox(),
                    const SizedBox(height: 20),
                    _loading 
                    ? SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                      ),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('Ongkir', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        ),
                        const Spacer(flex: 3,),
                        Expanded(
                          flex: 4,
                          child: Text('Rp ${idr.format(_data['Ongkir'])}', style: TextStyle(fontSize: 16),)
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    _loading 
                    ? SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                      ),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('PPN', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        ),
                        const Spacer(flex: 3,),
                        Expanded(
                          flex: 4,
                          child: Text('Rp ${idr.format(_data['PPN'])}', style: TextStyle(fontSize: 16),)
                        )
                      ],
                    ),
                    const SizedBox(height: 20),
                    _loading 
                    ? SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 16,
                      ),
                    )
                    : Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)
                        ),
                        const Spacer(flex: 3,),
                        Expanded(
                          flex: 4,
                          child: Text('Rp ${idr.format(_data['Total'])}', style: TextStyle(fontSize: 16),)
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}