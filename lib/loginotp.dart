import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/bottomnavbar.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/fill.dart';
import 'package:login_page/paint/mainpaint.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';

class LoginOtp extends StatefulWidget {
  const LoginOtp({super.key, required this.telp});
  final String telp;

  @override
  State<LoginOtp> createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> {
  final _formKey = GlobalKey<FormState>();
  int _counter = 30;
  late Timer _timer;
  final box = GetStorage();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _counter = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { 
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
                            if(response.data['data']) {
                              box.write('accesstoken', response.data['accesstoken']),
                              pushNewScreen(context, screen: const BottomNavbar())
                            } else {
                              pushNewScreen(context, screen: FillData(telp: widget.telp))
                            }
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