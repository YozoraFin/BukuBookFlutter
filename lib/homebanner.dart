import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/constants.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key});

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {
  List<int> list = [1, 2, 3, 4, 5];
  List _bannerData = [];

  @override
  void initState() {
    super.initState();
    getBanner();
  }

  getBanner() async{
    Response response = await Dio().get('${Constants.baseUrl}/banner');
    setState(() {
      _bannerData = response.data['data'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 1.0,
        autoPlay: true
      ),
      items: _bannerData.map((item) => 
        Container(
          color: const Color.fromARGB(0, 241, 246, 247),
          child: Row(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: item['SrcBanner'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                  progressIndicatorBuilder: (context, url, downloadProgress) => CircularProgressIndicator(value: downloadProgress.progress),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: MediaQuery.of(context).size.width/3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                      child: Text('BukuBook', style: TextStyle(color: Colors.black54, fontSize: 15)),
                    ),
                    Text('${item["Judul"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
              ),
              const Spacer()
            ],
          ),
        )
      )
      .toList(),
    );
  }
}