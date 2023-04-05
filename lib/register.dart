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

  TextEditingController namaLengkapController = TextEditingController();
  TextEditingController namaPanggilanController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController alamatController = TextEditingController();
  TextEditingController noTelpController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController otpController = TextEditingController();

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
                        child: Text('Register BukuBook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
                      ),
                      TextFormRoundBB(
                        controller: noTelpController,
                        placeholder: 'Nomor Telephone',
                        hidePassword: false,
                      ),
                      TextFormRoundBB(
                        controller: passwordController,
                        placeholder: 'Password',
                        sufIcon: IconButton(
                        onPressed: () {
                            setState(() {
                              _hidePassword = !_hidePassword;
                            });
                          },
                          icon: Icon(
                            _hidePassword
                            ? Icons.visibility
                            : Icons.visibility_off
                          ),
                        ),
                        hidePassword: _hidePassword,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      //   child: TextFormField(
                      //     controller: namaLengkapController,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(50.0)
                      //       ), 
                      //       labelText: 'Nama Lengkap'
                      //     ),
                      //     validator: (value) {
                      //       if(value == null || value.isEmpty) {
                      //         return 'Tolong isi nama lengkap anda';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      //   child: TextFormField(
                      //     controller: namaPanggilanController,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(50.0)
                      //       ), 
                      //       labelText: 'Nama Panggilan'
                      //     ),
                      //     validator: (value) {
                      //       if(value == null || value.isEmpty) {
                      //         return 'Tolong masukkan nama panggilan anda';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      //   child: TextFormField(
                      //     obscureText: true,
                      //     controller: passwordController,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(50.0)
                      //       ), 
                      //       labelText: 'Password'
                      //     ),
                      //     validator: (value) {
                      //       if(value == null || value.isEmpty) {
                      //         return 'Tolong masukkan password anda';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      //   child: TextFormField(
                      //     obscureText: true,
                      //     controller: confirmPasswordController,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(50.0)
                      //       ), 
                      //       labelText: 'Konfirmasi Password'
                      //     ),
                      //     validator: (value) {
                      //       if(value == null || value.isEmpty) {
                      //         return 'Tolong konfirmasi password anda';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      //   child: TextFormField(
                      //     controller: emailController,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(50.0)
                      //       ), 
                      //       labelText: 'Email'
                      //     ),
                      //     validator: (value) {
                      //       if(value == null || value.isEmpty) {
                      //         return 'Tolong masukkan alamat email anda';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      //   child: TextFormField(
                      //     controller: alamatController,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(50.0)
                      //       ), 
                      //       labelText: 'Alamat'
                      //     ),
                      //     validator: (value) {
                      //       if(value == null || value.isEmpty) {
                      //         return 'Tolong masukkan alamat rumah anda';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       if(_otpSent) {
                      //         setState(() {
                      //           _verified = false;
                      //           _otpSent = false;
                      //         });
                      //       }
                      //     },
                      //     controller: noTelpController,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(50.0)
                      //       ), 
                      //       labelText: 'Nomor Telephone'
                      //     ),
                      //     keyboardType: TextInputType.number,
                      //     validator: (value) {
                      //       if(value == null || value.isEmpty) {
                      //         return 'Tolong masukkan nomor telephone anda';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                      //   child: TextFormField(
                      //     controller: otpController,
                      //     decoration: InputDecoration(
                      //       border: OutlineInputBorder(
                      //         borderRadius: BorderRadius.circular(50.0)
                      //       ), 
                      //       labelText: 'Kode OTP',
                      //       suffixIcon: TextButton(
                      //         onPressed: () {
                      //           _otpSent ?
                      //             Dio().post('${Constants.baseUrl}/customer/verification', data: {'NoTelp': noTelpController.text, 'OTP': otpController.text})
                      //             .then((res) => {
                      //               if(res.data['status'] == 200) {
                      //                 setState(() {
                      //                   _verified = true;
                      //                 })
                      //               }
                      //             })
                      //           : Dio().post('${Constants.baseUrl}/customer/getotp', data: {'NoTelp': noTelpController.text})
                      //             .then((res) => {
                      //               if(res.data['status'] == 200) {
                      //                 setState(() {
                      //                   _otpSent = true;
                      //                 })
                      //               }
                      //             });
                      //         },
                      //         child: Text(_otpSent ? 'Verifikasi' : 'Kirim OTP'),
                      //       )
                      //     ),
                      //     keyboardType: TextInputType.number,
                      //     validator: (value) {
                      //       if(value == null || value.isEmpty) {
                      //         return 'Masukkan kode OTP';
                      //       }
                      //       return null;
                      //     },
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                        child: SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                                if(_formKey.currentState!.validate()) {
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