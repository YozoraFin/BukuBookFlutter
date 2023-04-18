import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/components/textform.dart';
import 'package:login_page/constants.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CheckOut extends StatefulWidget {
  const CheckOut({super.key});

  @override
  _CheckoutState createState() => _CheckoutState();
}

class _CheckoutState extends State<CheckOut> {
  List _listItem = [];
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
  bool _loading = true;

  RefreshController _refreshController = RefreshController();

  TextEditingController couponController = TextEditingController();
  TextEditingController namaLengkapController = TextEditingController();
  TextEditingController nomorHpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController kodePosController = TextEditingController();
  TextEditingController catatanController = TextEditingController();

  final box = GetStorage();
  final List<Map<String, String>> kurirOption = [
    {
      'label': 'JNE',
      'value': 'jne'
    },
    {
      'label': 'POS Indonesia',
      'value': 'pos'
    },
    {
      'label': 'TIKI',
      'value': 'tiki'
    }
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
      });
      _refreshController.refreshCompleted();
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
                            _loadingKota = true;
                          });
                          Dio().post('${Constants.baseUrl}/rajaongkir/kota', data: {'ProvinceID': val['id']})
                          .then((value) {
                            setState(() {
                              _listKota = value.data['data'];
                              _loadingKota = false;
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
                          hintText: _loadingKota ? 'Sedang memuat' :_listKota.isEmpty ? 'Pilih provinsi terlebih dahulu!' : 'Kota',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        ),
                        items: _listKota,
                        itemAsString: (kota) => kota['kota'],
                        showSearchBox: true,
                        onChanged: (val) {
                          setState(() {
                            _selectedKota = val;
                          });
                          print(val['id']);
                        },
                      ),
                    ),
                    TextFormRoundBB(controller: alamatController, placeholder: 'Alamat', pHorizontal: 0, pVertical: 8, cVertical: 10, lines: null,),
                    TextFormRoundBB(controller: kodePosController, placeholder: 'Kode Pos', pHorizontal: 0, pVertical: 8, cVertical: 10,),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DropdownSearch(
                        dropdownSearchDecoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(50.0)
                          ),
                          hintText: 'Kurir',
                          contentPadding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                        ),
                        items: kurirOption,
                        itemAsString: (kurir) => kurir?['label'] ?? '',
                        showSearchBox: true,
                        onChanged: (val) {

                        },
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
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(width: 150, child: Text('Kisah Sukses di Usia Muda', style: TextStyle(color: Color(0xFF777777)),)),
                          Spacer(),
                          SizedBox(width: 30, child: Align(alignment: Alignment.center, child: Text('x 20', style: TextStyle(color: Color(0xFF777777))))),
                          Spacer(),
                          SizedBox(width: 100, child: Align(alignment: Alignment.centerRight, child: Text('Rp 200.000', style: TextStyle(color: Color(0xFF777777)))))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(width: 150, child: Text('Kisah Sukses di Usia Muda: Sequel', style: TextStyle(color: Color(0xFF777777)),)),
                          Spacer(),
                          SizedBox(width: 30, child: Text('x 40', style: TextStyle(color: Color(0xFF777777)))),
                          Spacer(),
                          SizedBox(width: 100, child: Align(alignment: Alignment.centerRight, child: Text('Rp 440.000', style: TextStyle(color: Color(0xFF777777)))))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(width: 150, child: Text('Kisah Sukses di Usia Muda: Finale', style: TextStyle(color: Color(0xFF777777)),)),
                          Spacer(),
                          SizedBox(width: 30, child: Text('x 80', style: TextStyle(color: Color(0xFF777777)))),
                          Spacer(),
                          SizedBox(width: 100, child: Align(alignment: Alignment.centerRight, child: Text('Rp 1.000.000', style: TextStyle(color: Color(0xFF777777)))))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SizedBox(width: 150, child: Text('Aroma Karsa', style: TextStyle(color: Color(0xFF777777)),)),
                          Spacer(),
                          SizedBox(width: 30, child: Text('x 1', style: TextStyle(color: Color(0xFF777777)))),
                          Spacer(),
                          SizedBox(width: 100, child: Align(alignment: Alignment.centerRight, child: Text('Rp 100.000', style: TextStyle(color: Color(0xFF777777)))))
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