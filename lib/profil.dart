import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:connectivity_widget/connectivity_widget.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/components/textform.dart';
import 'package:login_page/constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:image_picker/image_picker.dart';

class Profil extends StatefulWidget {
  const Profil({super.key});

  @override
  State<Profil> createState() => _ProfilState();
}

class _ProfilState extends State<Profil> {
  final RefreshController _refreshController = RefreshController();
  final TextEditingController _namaPanggilanController = TextEditingController();
  final TextEditingController _namaLengkapController = TextEditingController();
  final TextEditingController _alamatController = TextEditingController();
  
  XFile? _profile;
  String _profileUrl = '';
  final ImagePicker picker = ImagePicker();
  bool _deleteProfil = false;

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
        _namaPanggilanController.text = value.data['data']['NamaPanggilan'];
        _namaLengkapController.text = value.data['data']['NamaLengkap'];
        _alamatController.text = value.data['data']['Alamat'];
        _profileUrl = value.data['data']['Profil'];
      });
    });
    _refreshController.refreshCompleted();
  }

  imageChange(ImageSource src) async {
    var img = await picker.pickImage(source: src);

    if(img != null) {
      setState(() {
        _profile = img;
      });
    }
  }

  deleteImage() {
    setState(() {
      _profile = null;
      _profileUrl = '';
      _deleteProfil = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        floatingActionButton: ElevatedButton(
          onPressed: () async {
            var data = {
              'NamaPanggilan': _namaPanggilanController.text, 
              'NamaLengkap': _namaLengkapController.text, 
              'Alamat': _alamatController.text, 
              'AksesToken': box.read('accesstoken'),
              'DeleteProfile': _deleteProfil
            };
            if(_profile != null) {
              data['Profil'] = await MultipartFile.fromFile(_profile!.path, filename: _profile!.name);
            }
            final formData = FormData.fromMap(data);
            Dio().post('${Constants.baseUrl}/customer/edit', data: formData)
            .then((value) {
              Navigator.pop(context);
            });
          }, 
          child: const Text('Simpan', style: TextStyle(fontFamily: 'OpenSans', letterSpacing: 0.5),)
        ),
        appBar: AppBar(
          title: const Text('Profil', style: TextStyle(fontFamily: 'SourceSans', letterSpacing: 0.5),),
        ),
        body: ConnectivityWidget(
          builder: (context, isOnline) => SmartRefresher(
            controller: _refreshController,
            onRefresh:() {
              getData();
              setState(() {
                _profile = null;
                _deleteProfil = false;
              });
            },
            child: Column(
              children: [
                const SizedBox(height: 16,),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context, 
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical( 
                                top: Radius.circular(25.0),
                              ),
                            ),
                            builder: (BuildContext context) {
                              return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                return SizedBox(
                                  height: 170,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Text('Foto Profil', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'SourceSans', letterSpacing: 0.5),),
                                            const Spacer(),
                                            IconButton(
                                              alignment: Alignment.centerRight,
                                              padding: EdgeInsets.zero,
                                              onPressed: () {
                                                Navigator.pop(context);
                                              }, 
                                              icon: const Icon(Icons.clear)
                                            )
                                          ],
                                        ),
                                        const SizedBox(height: 10,),
                                        Row(
                                          children: [
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    imageChange(ImageSource.gallery);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.black.withOpacity(0.5),
                                                        width: 1
                                                      ),
                                                      color: Colors.blue,
                                                    ),
                                                    width: 55,
                                                    height: 55,
                                                    child: const Center(child: FaIcon(FontAwesomeIcons.image, color: Colors.white,))
                                                  ),
                                                ),
                                                const SizedBox(height: 10,),
                                                const Text('Galeri', style: TextStyle(fontSize: 16, fontFamily: 'SourceSans', letterSpacing: 0.5),)
                                              ],
                                            ),
                                            const SizedBox(width: 20,),
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Navigator.pop(context);
                                                    imageChange(ImageSource.camera);
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.black.withOpacity(0.5),
                                                        width: 1
                                                      ),
                                                      color: Colors.blue,
                                                    ),
                                                    width: 55,
                                                    height: 55,
                                                    child: const Center(child: FaIcon(FontAwesomeIcons.camera, color: Colors.white,))
                                                  ),
                                                ),
                                                const SizedBox(height: 10,),
                                                const Text('Kamera', style: TextStyle(fontSize: 16, fontFamily: 'SourceSans', letterSpacing: 0.5),)
                                              ],
                                            ),
                                            const SizedBox(width: 20,),
                                            Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    deleteImage();
                                                    Navigator.pop(context); 
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.black.withOpacity(0.5),
                                                        width: 1
                                                      ),
                                                      color: Colors.blue,
                                                    ),
                                                    width: 55,
                                                    height: 55,
                                                    child: const Center(child: FaIcon(FontAwesomeIcons.trash, color: Colors.white,))
                                                  ),
                                                ),
                                                const SizedBox(height: 10,),
                                                const Text('Hapus', style: TextStyle(fontSize: 16, fontFamily: 'SourceSans', letterSpacing: 0.5),)
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              });
                            }
                          );
                        },
                        child: ClipOval(
                          child: Stack(
                            children: [
                              _profile != null
                              ? Image.file(File(_profile!.path), fit: BoxFit.cover, width: 125, height: 125,)
                              : CachedNetworkImage(
                                imageUrl: _profileUrl == '' ? Constants.emptProfile : _profileUrl.replaceAll('http://127.0.0.1:5000', Constants.baseUrl),
                                progressIndicatorBuilder: (context, url, downloadProgress) => Center(
                                  child: SizedBox(height: 25, width: 25, child: CircularProgressIndicator(value: downloadProgress.progress),)
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                                width: 125,
                                height: 125,
                                fit: BoxFit.cover,
                              ),
                              Positioned(
                                bottom: 0,
                                child: Container(
                                  color: Colors.black.withOpacity(0.6),
                                  height: 30,
                                  width: 125,
                                  child: const Center(child: FaIcon(FontAwesomeIcons.camera, size: 18, color: Colors.white,)),
                                ),
                              )
                            ]
                          ),
                        ),
                      ),
                    ],
                  )
                ),
                TextFormRoundBB(controller: _namaPanggilanController, placeholder: 'Nama Panggilan',),
                TextFormRoundBB(controller: _namaLengkapController, placeholder: 'Nama Lengkap'),
                TextFormRoundBB(controller: _alamatController, placeholder: 'Alamat', lines: null,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}