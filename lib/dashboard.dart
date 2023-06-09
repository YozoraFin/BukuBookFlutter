import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/historyorder.dart';
import 'package:login_page/login.dart';
import 'package:login_page/profil.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard> {
  Map<String, dynamic> _data = {
    'NamaPanggilan': '',
    'NamaLengkap': '',
    'Email': '',
    'NoTelp': '',
    'Alamat': '',
    'Profil': ''
  };
  bool _loading = true;
  final RefreshController _refreshController = RefreshController();

  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    getData();
  }

  getData() {
    Dio().post('${Constants.baseUrl}/customer/get', data: {'AksesToken': box.read('accesstoken')})
    .then((value) {
      setState(() {
        _data = value.data['data'];
        _loading = false;
      });
    });
    _refreshController.refreshCompleted();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        shadowColor: Colors.transparent,
        backgroundColor: Colors.transparent,
      ),
      body: ConnectivityWidget(
        showOfflineBanner: false,
        builder: (context, isConnected) => SmartRefresher(
          controller: _refreshController,
          header: const WaterDropMaterialHeader(),
          onRefresh: () {
            setState(() {
              _loading = true;
            });
            getData();
          },
          child: ListView(
            shrinkWrap: true,
            children: [
              Container(
                color: Colors.blue,
                width: double.infinity,
                height: 150,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            isConnected 
                            ? pushNewScreen(context, screen: const Profil(), withNavBar: false).then((value) => getData())
                            : ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tidak terhubung dengan internet', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5))));
                          },
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _loading
                              ? const SkeletonAvatar(
                                style: SkeletonAvatarStyle(
                                  height: 75,
                                  width: 75,
                                  borderRadius: BorderRadius.all(Radius.circular(50))
                                ),
                              )
                              : ClipOval(
                                child: CachedNetworkImage(
                                  imageUrl: _data['Profil'] == '' ? Constants.emptProfile : _data['Profil'].replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                                  progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                    child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                                  ),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 10,),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isConnected ? '${_data['NamaPanggilan']}' : box.read('namapanggilan') ?? '', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'SourceSans', letterSpacing: 0.5, wordSpacing: 1.1),),
                                  const SizedBox(height: 5,),
                                  Text(isConnected ? '${_data['Email']}' : box.read('email') ?? '', style: const TextStyle(color: Colors.white, fontFamily: 'OpenSans', letterSpacing: 0.5),),
                                ],
                              ),
                              const Spacer(),
                              const FaIcon(FontAwesomeIcons.chevronRight, color: Colors.white,),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16,),
              InkWell(
                onTap: () {
                  pushNewScreen(context, screen: const HistoryOrder(), withNavBar: false);
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.clockRotateLeft, size: 20,),
                      SizedBox(width: 10,),
                      Text('Riwayat pembelian', style: TextStyle(fontSize: 20, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1),)
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  // pushNewScreen(context, screen: const Contact(), withNavBar: false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('WIP'))
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.headset, size: 20,),
                      SizedBox(width: 10,),
                      Text('Hubungi kami', style: TextStyle(fontSize: 20, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1),)
                    ],
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  showDialog(
                    context: context, 
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Apakah anda yakin?', style: TextStyle(fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1),),
                        content: const Text('Setelah ini anda akan diarahkan kembali menuju halaman login', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5)),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            }, 
                            child: const Text('Tidak', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5),)
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              box.erase();
                              Navigator.pushNamedAndRemoveUntil(context, '/', (Route<dynamic> route) => false);
                            }, 
                            child: const Text('Ya', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5))
                          )
                        ],
                      );
                    }
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: const [
                      FaIcon(FontAwesomeIcons.arrowRightFromBracket, size: 20,),
                      SizedBox(width: 10,),
                      Text('Keluar', style: TextStyle(fontSize: 20, fontFamily: 'SourceSans', letterSpacing: 0.7, wordSpacing: 1.1),)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}