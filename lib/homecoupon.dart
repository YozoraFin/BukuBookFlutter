import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    getKupon();
  }

  getKupon() {
    Dio().get('${Constants.baseUrl}/kupon').then((value) {
      setState(() {
        _coupon = value.data['hData'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        image: DecorationImage(image: NetworkImage(_coupon['SrcGambar'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl)), fit: BoxFit.cover)
      ),
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_coupon['Judul'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20), textAlign: TextAlign.center,),
                const SizedBox(height: 10,),
                Text(_coupon['Kode'], style: const TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.bold, fontSize: 15), textAlign: TextAlign.center,),
                const SizedBox(height: 10,),
                Text(_coupon['Teaser'], style: const TextStyle(color: Color(0xFF777777)), textAlign: TextAlign.center,),
                const SizedBox(height: 10,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context, rootNavigator: true).push(MaterialPageRoute(
                      builder: (context) => CouponList()
                    ));
                  }, 
                  style: ButtonStyle(
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50.0),
                      )
                    )
                  ),
                  child: const Text('Detail')
                )
              ],
            ),
          ),
          Spacer(flex: 2,)
        ],
      ),
    );
  }
}