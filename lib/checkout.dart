import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:login_page/components/textform.dart';
import 'package:login_page/constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:skeletons/skeletons.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});

  @override
  CheckoutState createState() => CheckoutState();
}

class CheckoutState extends State<CheckOut> {
  List _listItem = [];
  bool _loading = true;
  List _listProvinsi = [];
  bool _loadingProvinsi = true;
  Map<String, dynamic> _selectedProvinsi = {
    'provinsi': '',
    'id': ''
  };
  List _listKota = [];
  bool _loadingKota = false;
  Map<String, dynamic> _selectedKota = {
    'kota': '',
    'id': ''
  };
  List _listKurir = [];
  String _selectedKurir = '';
  int _subtotal = 0;
  int _jumlah = 0;
  int _potongan = 0;
  int _ongkir = 0;
  int _ppn = 0;
  int _total = 0;
  bool _continue = false;

  RefreshController _refreshController = RefreshController();
  TextEditingController couponController = TextEditingController();
  TextEditingController namaLengkapController = TextEditingController();
  TextEditingController nomorHpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController kodePosController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  final NumberFormat idr = NumberFormat('#,##0', 'id');
  final box = GetStorage();
  final List<DropdownMenuItem> kurirOption = [
    const DropdownMenuItem(child: Text('JNE'), value: 'jne'),
    const DropdownMenuItem(child: Text('POS Indonesia'), value: 'pos'),
    const DropdownMenuItem(child: Text('TIKI'), value: 'tiki')
  ];

  @override
  void initState() {
    super.initState();
    getItem();
    getProvinsi();
  }

  getProvinsi() {
    Dio().get('${Constants.baseUrl}/rajaongkir/provinsi')
    .then((value) {
      setState(() {
        _listProvinsi = value.data['data'];
        _loadingProvinsi = false;
        
      });
    });
  }

  getItem() {
    Dio().post('${Constants.baseUrl}/cart', data: {'AksesToken': box.read('accesstoken')})
    .then((value) {
      setState(() {
        _listItem = value.data['data'];
        _loading = false;
        _subtotal = value.data['subtotal'];
        _jumlah = value.data['jumlah'];
        _ppn = value.data['subtotal']*11~/100.toInt();
        _total = value.data['subtotal'];
      });
      _refreshController.refreshCompleted();
    });
  }
  
  setOngkir(int harga) {
    setState(() {
      _ongkir = harga;
      _ppn = harga*11~/100.toInt()+_ppn;
      _total = harga+_total;
    });
  }

  checkForm() {
    setState(() {
      _continue = !(namaLengkapController.text == '' || nomorHpController.text == '' || emailController.text == '' || _ongkir == 0 || alamatController.text == '' || kodePosController.text == '');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Checkout'),
        ),
        body: SmartRefresher(
          controller: _refreshController,
          header: const WaterDropMaterialHeader(),
          onRefresh: () {
            setState(() {
              _loading = true;
              _loadingProvinsi = true;
              _listKota = [];
              _selectedProvinsi = {
                'provinsi': '',
                'id': ''
              };
              _selectedKota = {
                'kota': '',
                'id': ''
              };
              _selectedKurir = '';
              _ongkir = 0;
              _ppn = 0;
              _subtotal = 0;
              _jumlah = 0;
              _total = 0;
              _potongan = 0;
            });
            getItem();
            getProvinsi();
          },
          child: ListView(
            shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Kode Kupon', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                    ),
                    const SizedBox(height: 10),
                    TextFormRoundBB(controller: couponController, placeholder: 'Kode kupon', pHorizontal: 0, pVertical: 8, cVertical: 10,),
                    Align(
                      alignment: Alignment.topRight,
                      child: ElevatedButton(
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            )
                          )
                        ),
                        onPressed: () {
                          Dio().post('${Constants.baseUrl}/kupon/check', data: {'Kode': couponController.text})
                          .then((value) {
                            setState(() {
                              if(value.data['status'] == 200) {
                                if(value.data['data']['Tipe']) {
                                  _potongan = _subtotal*value.data['data']['Potongan']~/100.toInt();
                                  _ppn = _ppn - _subtotal*value.data['data']['Potongan']~/100.toInt()*11~/100.toInt();
                                  _total = _total - _subtotal*value.data['data']['Potongan']~/100.toInt(); 
                                } else {
                                  _potongan = value.data['data']['Potongan'];
                                  _ppn = _ppn - 1*value.data['data']['Potongan']*11~/100.toInt();
                                  _total = _total - (1*value.data['data']['Potongan']).toInt();
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Kupon berhasil digunakan')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Kode kupon tidak ditemukan')),
                                );
                              }
                            });
                          });
                        }, 
                        child: Text('Gunakan!')
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('Detail Pembayaran', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
                    ),
                    const SizedBox(height: 10),
                    Form(
                      onChanged: checkForm,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormRoundBB(controller: namaLengkapController, placeholder: 'Nama Lengkap', pHorizontal: 0, pVertical: 8, cVertical: 10,),
                          TextFormRoundBB(controller: nomorHpController, placeholder: 'Nomor HP', pHorizontal: 0, pVertical: 8, cVertical: 10, keyboardType: TextInputType.number,),
                          TextFormRoundBB(controller: emailController, placeholder: 'Email', pHorizontal: 0, pVertical: 8, cVertical: 10, keyboardType: TextInputType.emailAddress,),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: DropdownSearch(
                              selectedItem: _selectedProvinsi['id'] == '' ? null : _selectedProvinsi,
                              enabled: !_loadingProvinsi,
                              dropdownSearchDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0)
                                ),
                                hintText: _loadingProvinsi ? 'Sedang memuat...' : 'Provinsi',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                              ),
                              items: _listProvinsi,
                              itemAsString: (prov) => prov['provinsi'],
                              showSearchBox: true,
                              onChanged: (val) {
                                setState(() {
                                  _selectedProvinsi = val;
                                  _selectedKota = {
                                    'id': '',
                                    'kota': ''
                                  };
                                  _selectedKurir = '';
                                  _loadingKota = true;
                                });
                                Dio().post('${Constants.baseUrl}/rajaongkir/kota', data: {'ProvinceID': val['id']})
                                .then((value) {
                                  setState(() {
                                    _listKota = value.data['data'];
                                    _loadingKota = false;
                                    _ppn = _ppn - _ongkir*11~/100.toInt();
                                    _total = _total - _ongkir;
                                    _ongkir = 0;
                                  });
                                });
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: DropdownSearch(
                              enabled: !_loadingKota && !_listKota.isEmpty,
                              selectedItem: _selectedKota['id'] == '' ? null : _selectedKota,
                              dropdownSearchDecoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(50.0)
                                ),
                                hintText: _loadingKota ? 'Sedang memuat' : 'Kota',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                              ),
                              items: _listKota,
                              itemAsString: (kota) => kota['kota'],
                              showSearchBox: true,
                              onChanged: (val) {
                                setState(() {
                                  _selectedKota = val;
                                  _selectedKurir = '';
                                  _ppn = _ppn - _ongkir*11~/100.toInt();
                                  _total = _total - _ongkir;
                                  _ongkir = 0;
                                });
                                print(val['id']);
                              },
                            ),
                          ),
                          TextFormRoundBB(controller: alamatController, placeholder: 'Alamat', pHorizontal: 0, pVertical: 8, cVertical: 10, lines: null,),
                          TextFormRoundBB(controller: kodePosController, placeholder: 'Kode Pos', pHorizontal: 0, pVertical: 8, cVertical: 10, keyboardType: TextInputType.number,),
                          IgnorePointer(
                            ignoring: _selectedKota['id'] == '',
                            child: Opacity(
                              opacity: _selectedKota['id'] == '' ? 0.6 : 1.0,
                              child: DropdownButtonFormField(
                                value: _selectedKurir == '' ? null : _selectedKurir,
                                decoration: InputDecoration(
                                  hintText: 'Kurir',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(50.0)
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                                  suffixIcon: const Icon(Icons.arrow_drop_down),
                                ),
                                iconDisabledColor: Colors.transparent,
                                iconEnabledColor: Colors.transparent,
                                items: kurirOption, 
                                onChanged: (val) {
                                  setState(() {
                                    _selectedKurir = val;
                                  });
                                  var object = {
                                    'Asal': 444,
                                    'Tujuan': _selectedKota['id'],
                                    'Kurir': val,
                                    'Berat': _jumlah*500,
                                  };
                                  var response = Dio().post('${Constants.baseUrl}/rajaongkir/ongkir', data: object);
                    
                                  showModalBottomSheet(
                                    context: context, 
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.vertical( 
                                        top: Radius.circular(25.0),
                                      ),
                                    ),
                                    builder: (BuildContext context) {
                                      return StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
                                        return Padding(
                                          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Align(
                                                alignment: Alignment.topRight,
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      Navigator.pop(context);
                                                    },
                                                    child: const Icon(Icons.clear, color: Color(0xFF384AEB),),
                                                  ),
                                                )
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                                child: Text('Daftar layanan:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                                              ),
                                              const Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                                                child: SizedBox(width: 150, child: Divider(color: Colors.black,),),
                                              ),
                                              FutureBuilder(
                                                future: response,
                                                builder: (context, snapshot) {
                                                  if(snapshot.connectionState == ConnectionState.waiting) {
                                                    return const Center(
                                                      child: CircularProgressIndicator(),
                                                    );
                                                  }
                                                  return Column(
                                                    children: [
                                                      for(var layanan in snapshot.data!.data['data']) ListTile(
                                                        onTap: () {
                                                          setOngkir(layanan['harga']);
                                                          Navigator.pop(context);
                                                        },
                                                        title: Text('Rp ${idr.format(layanan['harga'])} ${layanan['deskripsi']} ${layanan['estimasi']}', style: TextStyle(color: Color(0xFF777777)),),
                                                      ),
                                                    ],
                                                  );
                                                }
                                              ),
                                              const SizedBox(height: 30,)
                                            ],
                                          ),
                                        );
                                      });
                                    }
                                  );
                                } 
                              ),
                            ),
                          ),
                          TextFormRoundBB(controller: catatanController, placeholder: 'Catatan', pHorizontal: 0, pVertical: 8, cVertical: 10, lines: null, action: TextInputAction.newline, keyboardType: TextInputType.multiline,),
                          const SizedBox(height: 30,),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text('Pesanan anda', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Row(
                              children: const [
                                Text('Buku', style: TextStyle(fontSize: 16),),
                                Spacer(),
                                Text('Total', style: TextStyle(fontSize: 16),)
                              ],
                            ),
                          ),
                          const SizedBox(height: 10,),
                          ..._loading
                          ? ({for(var i = 0; i < 3; i++) Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                SizedBox(width: 150, child: SkeletonLine(),),
                                Spacer(),
                                SizedBox(width: 30, child: SkeletonLine(),),
                                Spacer(),
                                SizedBox(width: 100, child: SkeletonLine(),),
                              ],
                            ),
                          )})
                          : ({for(var item in _listItem) Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(width: 150, child: Text(item['Buku']['Judul'], style: TextStyle(color: Color(0xFF777777)),)),
                                const Spacer(),
                                SizedBox(width: 30, child: Align(alignment: Alignment.center, child: Text('x ${item['Jumlah']}', style: TextStyle(color: Color(0xFF777777))))),
                                const Spacer(),
                                SizedBox(width: 100, child: Align(alignment: Alignment.topRight, child: Text('Rp ${idr.format(item['Buku']['Harga']*item['Jumlah'])}', style: TextStyle(color: Color(0xFF777777)))))
                              ],
                            ),
                          )}),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 150, child: Text('SUBTOTAL', style: TextStyle(fontWeight: FontWeight.bold),),),
                                const Spacer(),
                                const SizedBox(width: 30,),
                                const Spacer(),
                                SizedBox(width: 100, child: Align(alignment: Alignment.topRight, child: Text('Rp ${idr.format(_subtotal)}', style: TextStyle(fontWeight: FontWeight.bold)),),)
                              ],
                            ),
                          ),
                          if(_potongan != 0) Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 150, child: Text('POTONGAN', style: TextStyle(fontWeight: FontWeight.bold),),),
                                const Spacer(),
                                const SizedBox(width: 30,),
                                const Spacer(),
                                SizedBox(width: 100, child: Align(alignment: Alignment.topRight, child: Text('Rp ${idr.format(_potongan)}', style: TextStyle(fontWeight: FontWeight.bold)),),)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 150, child: Text('ONGKIR', style: TextStyle(fontWeight: FontWeight.bold),),),
                                const Spacer(),
                                const SizedBox(width: 30,),
                                const Spacer(),
                                SizedBox(width: 100, child: Align(alignment: Alignment.topRight, child: Text('Rp ${idr.format(_ongkir)}', style: TextStyle(fontWeight: FontWeight.bold)),),)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 150, child: Text('PPN', style: TextStyle(fontWeight: FontWeight.bold),),),
                                const Spacer(),
                                const SizedBox(width: 30,),
                                const Spacer(),
                                SizedBox(width: 100, child: Align(alignment: Alignment.topRight, child: Text('Rp ${idr.format(_ppn)}', style: TextStyle(fontWeight: FontWeight.bold)),),)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(width: 150, child: Text('HARGA AKHIR', style: TextStyle(fontWeight: FontWeight.bold),),),
                                const Spacer(),
                                const SizedBox(width: 30,),
                                const Spacer(),
                                SizedBox(width: 100, child: Align(alignment: Alignment.topRight, child: Text('Rp ${idr.format(_total+_ppn)}', style: TextStyle(fontWeight: FontWeight.bold)),),)
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            child: Align(
                              alignment: Alignment.bottomRight,
                              child: SizedBox(
                                width: 120,
                                height: 40,
                                child: ElevatedButton(
                                  style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all<Color>(_continue ? Colors.blue : Colors.grey),
                                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50.0),
                                      )
                                    )
                                  ),
                                  onPressed: () {
                                    if(_continue) {
                                      showDialog(
                                        context: context, 
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: const Text('Perhatian!'),
                                            content: Text('Setelah menyetujui anda harus membayar sebesar Rp ${idr.format(_ppn + _total)} kepada kurir. Pastikan barang yang anda beli sudah sesuai agar tidak mengalami kerugian yang tidak diinginkan.'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Tidak'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  List data = [];
                                                  for (var item in _listItem) {
                                                    data.add({
                                                      'id': item['Buku']['id'],
                                                      'qty': item['Jumlah'],
                                                      'subtotal': item['Jumlah']*item['Buku']['Harga']
                                                    });
                                                  }
                                                  Map object = {
                                                    'AksesToken': box.read('accesstoken'),
                                                    'Kurir': _selectedKurir,
                                                    'Provinsi': _selectedProvinsi['provinsi'],
                                                    'Kota': _selectedKota['kota'],
                                                    'Total': _total,
                                                    'Data': data,
                                                    'Ongkir': _ongkir,
                                                    'Alamat': alamatController.text,
                                                    'NoTelp': nomorHpController.text,
                                                    'Email': emailController.text,
                                                    'Catatan': catatanController.text,
                                                    'Kodepos': kodePosController.text,
                                                    'Nama': namaLengkapController.text,
                                                    'Potongan': _potongan,
                                                    'PPN': _ppn
                                                  };
                                                  Dio().post('${Constants.baseUrl}/checkout', data: object  )
                                                  .then((value) {
                                                    if(value.data['status'] == 200) {
                                                      showDialog(
                                                        context: context, 
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text('Berhasil melakukan checkout'),
                                                            content: Text('Kamu bisa melihat pesananmu pada halaman riwayat belanja dalam bagian profil'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                }, 
                                                                child: Text('Oke')
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      );
                                                    } else {
                                                      showDialog(
                                                        context: context, 
                                                        builder: (BuildContext context) {
                                                          return AlertDialog(
                                                            title: Text('Gagal melanjutkan'),
                                                            content: Text('${value.data['message']}'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(context);
                                                                }, 
                                                                child: Text('Oke')
                                                              ),
                                                            ],
                                                          );
                                                        }
                                                      );
                                                    }
                                                  });
                                                  Navigator.pop(context);
                                                }, 
                                                child: const Text('Ya')
                                              ),
                                            ],
                                          );
                                        }
                                      );
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Tolong lengkapi data terlebih dahulu!')),
                                      );
                                    }
                                  },
                                  child: Text('Bayar!'),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}