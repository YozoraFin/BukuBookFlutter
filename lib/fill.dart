
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/textform.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/login.dart';
import 'package:login_page/paint/scrollpaint.dart';

class FillData extends StatefulWidget {
  const FillData({super.key, required this.telp});

  final String telp;

  @override
  State<FillData> createState () => _FillDataState();
}

class _FillDataState extends State<FillData> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController namaLengkapController = TextEditingController();
  TextEditingController namaPanggilanController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              CustomPaint(
                painter: ScrollPaint(),
                child: const SizedBox(
                  height: 200,
                  width: double.infinity,
                ),
              ),
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8, bottom: 16),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: Text('Profil Pengguna', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
                      ),
                      TextFormRoundBB(controller: namaLengkapController, placeholder: 'Nama Lengkap', hidePassword: false),
                      TextFormRoundBB(controller: namaPanggilanController, placeholder: 'Nama Panggilan', hidePassword: false),
                      TextFormRoundBB(controller: emailController, placeholder: 'Email', hidePassword: false),
                      TextFormRoundBB(controller: alamatController, placeholder: 'Alamat', hidePassword: false),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                                if(_formKey.currentState!.validate()) {
                                    Dio().post('${Constants.baseUrl}/customer/fill', data: {'NoTelp': 'harusnotelp', 'NamaLengkap': namaLengkapController.text, 'NamaPanggilan': namaPanggilanController.text, 'Alamat': alamatController, 'Email': emailController})
                                    .then((response) => {
                                      if(response.data['status'] == 200) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Berhasil melengkapi profil'))
                                        ),
                                        Navigator.push(
                                          context, 
                                          MaterialPageRoute(
                                            builder: (context) => const Login()
                                          ),
                                        )
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(response.data['message']))
                                        )
                                      },
                                    });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Tolong lengkapi form'))
                                  );
                                }
                            },
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              backgroundColor: Colors.blue
                            ),
                            child: const Text('Kirim'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}