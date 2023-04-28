import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/components/textform.dart';
import 'package:login_page/loginotp.dart';
import 'package:login_page/paint/mainpaint.dart';
import 'package:login_page/register.dart';
import 'constants.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _button = 'Login';
  final _formKey = GlobalKey<FormState>();
  final box = GetStorage();

  TextEditingController telpController = TextEditingController();

  void submit () {
    setState(() {
      _button = 'Loading...';
    });
  }

  void submitted () {
    setState(() {
      _button = 'Login';
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
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: Text('Login BukuBook', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 50)),
                  ),
                  TextFormRoundBB(
                    controller: telpController,
                    placeholder: 'Nomor Telephone',
                    hidePassword: false,
                    keyboardType: TextInputType.number,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if(_formKey.currentState!.validate()) {
                            submit();
                            Dio().post('${Constants.baseUrl}/customer/loginotp', data: {'NoTelp': telpController.text})
                            .then((response) => {
                              if(response.data['status'] == 200) {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => LoginOtp(telp: telpController.text,)
                                  ),
                                )
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Login gagal'))
                                )
                              },
                              submitted(),
                            });
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Please fill input'))
                            );
                          }
                        },
                        style: ButtonStyle(
                          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            )
                          )
                        ),
                        child: Text(_button),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(text: 'Belum mempunyai akun? ', style: TextStyle(color: Colors.black)),
                          TextSpan(
                            text: 'Register',
                            style: const TextStyle(
                              color: Colors.blue,
                            ),
                            recognizer: TapGestureRecognizer()..onTap = () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(
                                    builder: (context) => const Register()
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
        ),
      ),
    );
  }
}