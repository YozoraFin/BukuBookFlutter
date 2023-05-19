import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/couponlist.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class HomeCoupon extends StatefulWidget {
  const HomeCoupon({super.key, required this.coupon});
  final Map<String, dynamic> coupon;

  @override
  State<HomeCoupon> createState() => _HomeCouponState();
}

class _HomeCouponState extends State<HomeCoupon> {
  Map<String, dynamic> _coupon = {
    'Judul': 'Sedang memuat...',
    'Kode': '',
    'Teaser': '',
    'SrcGambar': ''
  };
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    getKupon();
  }

  getKupon() {
    Dio().post('${Constants.baseUrl}/kupon/get', data: {'AksesToken': box.read('accesstoken')}).then((value) {
      setState(() {
        _coupon = value.data['hData'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pushNewScreen(context, screen: const CouponList(), withNavBar: false);
      },
      child: Center(
        child: CachedNetworkImage(
          imageUrl: _coupon['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
          progressIndicatorBuilder: (context, url, downloadProgress) => Center(
            child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
          ),
          errorWidget: (context, url, error) => const Icon(Icons.error),
        )
      ),
    );
  }
}