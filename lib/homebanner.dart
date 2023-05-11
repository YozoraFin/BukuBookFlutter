import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:login_page/constants.dart';

class HomeBanner extends StatefulWidget {
  const HomeBanner({super.key, required this.bannerData});
  final List bannerData;

  @override
  State<HomeBanner> createState() => _HomeBannerState();
}

class _HomeBannerState extends State<HomeBanner> {

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      options: CarouselOptions(
        viewportFraction: 1.0,
        autoPlay: true,
        autoPlayInterval: const Duration(seconds: 5)
      ),
      items: 
      widget.bannerData.map((item) => 
        Container(
          color: const Color.fromARGB(0, 241, 246, 247),
          child: Row(
            children: [
              Center(
                child: CachedNetworkImage(
                  imageUrl: item['SrcBanner'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                  progressIndicatorBuilder: (context, url, downloadProgress) => SizedBox(
                    width: 150,
                    height: 300,
                    child: Center(
                      child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                    ),
                  ),
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
                      child: Text('BukuBook', style: TextStyle(color: Colors.black54, fontSize: 15, fontFamily: 'OpenSans', letterSpacing: 0.7, height: 1.1, wordSpacing: 1.1)),
                    ),
                    Text('${item["Judul"]}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'SourceSans', letterSpacing: 1, height: 1.1, wordSpacing: 1.2)),
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