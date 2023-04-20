import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:login_page/components/textform.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/login.dart';
import 'package:login_page/otp.dart';
import 'package:login_page/paint/scrollpaint.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();
  
  bool _verified = false;
  bool _otpSent = false;
  bool _hidePassword = true;

  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();

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
                        child: Text('Register BukuBook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
                      ),
                      TextFormRoundBB(
                        controller: noTelpController,
                        placeholder: 'Nomor Telephone',
                        hidePassword: false,
                      ),
                      TextFormRoundBB(
                        controller: confirmPasswordController,
                        placeholder: 'Password',
                        hidePassword: true,
                      ),
                      TextFormRoundBB(
                        controller: passwordController,
                        placeholder: 'Konfirmasi Password',
                        hidePassword: true,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                                if(_formKey.currentState!.validate()) {
                                  if(confirmPasswordController.text == passwordController.text) {
                                    Dio().post('${Constants.baseUrl}/customer/getotp', data: {'NoTelp': noTelpController.text})
                                    .then((response) => {
                                      if(response.data['status'] == 200) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Kode OTP terkirim'))
                                        ),
                                        Navigator.push(
                                          context, 
                                          MaterialPageRoute(
                                            builder: (context) => Otp(telp: noTelpController.text, password: passwordController.text,)
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
                                      SnackBar(content: Text('Konfirmasi password tidak sesuai'))
                                    );
                                  }
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
                            child: const Text('Register'),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(text: 'Sudah mempunyai akun? ', style: TextStyle(color: Colors.black)),
                              TextSpan(
                                text: 'Login',
                                style: const TextStyle(
                                  color: Colors.blue,
                                ),
                                recognizer: TapGestureRecognizer()..onTap = () {
                                  Navigator.push(
                                    context, 
                                    MaterialPageRoute(
                                      builder: (context) => const Login()
                                    ),
                                  );
                                },
                              ),
                              const TextSpan(text: '.'),
                            ],
                          ),
                        )
                      )
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