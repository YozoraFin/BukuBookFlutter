import 'package:cached_network_image/cached_network_image.dart';
import 'package:clipboard/clipboard.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:login_page/constants.dart';

class CouponDetail extends StatefulWidget {
  const CouponDetail({super.key, required this.id});
  final num id;

  @override
  State<CouponDetail> createState() => _CouponDetailState();
}

class _CouponDetailState extends State<CouponDetail> {
  Map<String, dynamic> _couponDetail = {
    'Judul': '',
    'Deskripsi': '',
    'Kode': '',
    'Tipe': true,
    'Potongan': 0,
    'SrcGambar': '',
  };

  bool _loading = true;
  final NumberFormat idr = NumberFormat('#,##0', 'id');

  @override
  void initState() {
    super.initState();
    getKupon();
  }

  getKupon() {
    Dio().get('${Constants.baseUrl}/kupon/${widget.id}')
    .then((value) {
      setState(() {
        _couponDetail = value.data['data'];
        _loading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_couponDetail['Judul']),
      ),
      body: Column(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: _couponDetail['SrcGambar'] != '' ? _couponDetail['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl) : "${Constants.baseUrl}/foto/kupon/SrcGambar-1680162638483.png",
              progressIndicatorBuilder: (context, url, downloadProgress) => Container(
                child: Center(
                  child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                ),
              ),
              errorWidget: (context, url, error) => const Icon(Icons.error),
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(child: Text(_couponDetail['Judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30))),
                const SizedBox(height: 10),
                const Divider(color: Colors.black),
                const SizedBox(height: 10),
                const Text('Kode:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Row(
                    children: [
                      Text(_couponDetail['Kode'], style: const TextStyle(fontSize: 14)),
                      const Spacer(),
                      IconButton(
                        splashRadius: 20,
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          FlutterClipboard.copy(_couponDetail['Kode'])
                          .then((value) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Berhasil disalin'))
                            );
                          });
                        }, 
                        iconSize: 16,
                        icon: const Icon(Icons.copy)
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Potongan:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(_couponDetail['Tipe'] ? 'Diskon ${_couponDetail['Potongan']}%' : 'Rp ${idr.format(_couponDetail['Potongan'])}', style: const TextStyle(fontSize: 14),),
                ),
                const SizedBox(height: 20),
                const Text('Deskripsi:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(_couponDetail['Deskripsi'], style: const TextStyle(fontSize: 14)),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}