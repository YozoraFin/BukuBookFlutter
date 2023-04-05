
import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/login.dart';
import 'package:login_page/paint/mainpaint.dart';
import 'package:otp_text_field/otp_field.dart';

class Otp extends StatefulWidget {
  const Otp({super.key, required this.telp, required this.password});
  final String? telp;
  final String? password;

  @override
  State<Otp> createState() => _OtpState();
}

class _OtpState extends State<Otp> {
  final _formKey = GlobalKey<FormState>();
  int _counter = 30;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _counter = 30;
    _timer = Timer.periodic(Duration(seconds: 1), (timer) { 
      if(_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        _timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: CustomPaint(
            painter: MainPaint(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    child: Text('Verifikasi OTP', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    child: Text('Kode OTP telah kami kirim kan ke nomor ${widget.telp}'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    child: OTPTextField(
                      length: 4,
                      width: MediaQuery.of(context).size.width,
                      fieldWidth: 40,
                      onCompleted: (pin) {
                        Dio().post('${Constants.baseUrl}/customer/verification', data: {'NoTelp': widget.telp, 'OTP': pin})
                        .then((response) => {
                          if(response.data['status'] == 200) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Terverifikasi'))
                            ),
                            // Ini buat register
                            Dio().post('${Constants.baseUrl}/customer/register', data: {'NoTelp': widget.telp, 'Password': widget.password, 'Email': '', 'NamaPanggilan': '', 'NamaLengkap': '', 'Alamat': ''})
                            .then((response) => {
                              if(response.data['status'] == 200) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Register berhasil'))
                                ),
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => Login()
                                  ),
                                )
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(response.data['message']))
                                )
                              },
                            })
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response.data['message']))
                            )
                          },
                        });
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: RichText(
                        text: TextSpan(
                          children: [
                            const TextSpan(
                              text: 'Belum menerima kode OTP? ',
                              style: TextStyle(fontSize: 15, color: Colors.black)
                            ),
                            TextSpan(
                              text: 'Kirim ulang',
                              style: TextStyle(
                                color: _counter > 0 ? Colors.grey : Colors.blue,
                                fontSize: 15
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {
                                _counter > 0
                                ? ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Tolong tunggu $_counter detik lagi'))
                                  )
                                : Dio().post('${Constants.baseUrl}/customer/getotp', data: {'NoTelp': widget.telp})
                                  .then((response) => {
                                    if(response.data['status'] == 200) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Kode OTP terkirim'))
                                      ),
                                      // Navigator.push(
                                      //   context, 
                                      //   MaterialPageRoute(
                                      //     builder: (context) => Otp(telp: widget.telp, password: passwordController.text,)
                                      //   ),
                                      // )
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text(response.data['message']))
                                      )
                                    },
                                  }); 
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Terkirim'))
                                  );
                                  setState(() {
                                    _counter = 30;
                                  });
                                  _startTimer();
                              },
                            ),
                            TextSpan(text: _counter > 0 ? ' ($_counter)' : '', style: const TextStyle(color: Colors.grey, fontSize: 15)),
                          ],
                        ),
                      ),
                    ),
                  )
                ]
              ),
            ),
          ),
        ),
      ),
    );
  }
}