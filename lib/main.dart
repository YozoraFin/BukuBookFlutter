import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:login_page/constants.dart';
import 'package:login_page/fill.dart';
import 'package:login_page/homepage.dart';
import 'package:login_page/otp.dart';
import 'package:login_page/splash.dart';
import 'login.dart';

void main() async {
  await GetStorage.init();
  runApp(const MyApp());
}

class LoadPage extends StatefulWidget {
  const LoadPage({super.key});

  @override
  State<LoadPage> createState() => _LoadPageState();
}

class _LoadPageState extends State<LoadPage> {
  final box = GetStorage();

  Future<bool> check() async{
    Response response = await Dio().post('${Constants.baseUrl}/customer/get', data: {'AksesToken': box.read('accesstoken')});
    
    if(response.data['status'] == 200) {
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: check(),
      builder: (context, AsyncSnapshot<bool> snapshot) {
        if(snapshot.hasData) {
          if(snapshot.data ?? false) {
            return const HomePage(data: '');
          }
          box.erase();
          return const Login();
        }
        return const SplashScreenBukuBook();
      },
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          primarySwatch: Colors.blue,
      ),
      home: const FillData(telp: ''),
    );
  }
}

// Login Page 2
// class _LoginState extends State<Login> {
// 	String button = 'Submit';
//   bool _showPassword = false;
//   final TextEditingController _txtEmail = TextEditingController();
//   final TextEditingController _txtPassword = TextEditingController();

// 	final _formKey = GlobalKey<FormState>();

// 	void submit () {
// 		setState(() {

// 			button = 'Loading...';
// 		});
// 	}

// 	@override
// 	Widget build(BuildContext context) {
// 		return Scaffold(
// 			appBar: AppBar(
// 				title: Text(widget.title),
// 			),
// 			body: Container(
//         padding: const EdgeInsets.symmetric(
//           vertical: 30,
//           horizontal: 20
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children:  [
//             const Text('Username'),
//             TextField(
//               controller: _txtEmail,
//               decoration: const InputDecoration(
//                 hintText: 'Email'
//               ),
//             ),

//             Text('Password'),
//             TextField(
//               controller: _txtPassword,
//               decoration: InputDecoration(
//                 hintText: 'Password',
//                 suffixIcon: IconButton(
//                   onPressed: () {
//                     setState(() {
//                       _showPassword = !_showPassword;
//                     });
//                   }, 
//                   icon: Icon(
//                     ( 
//                       _showPassword
//                       ? Icons.visibility_off
//                       : Icons.visibility
//                     )
//                   )
//                 )
//               ),
//               obscureText: !_showPassword,
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Dio().get('https://helpdesk.crosstechno.com/member-api/login', 
//                   queryParameters: {
//                     "ClientID": "02118ba46bff13a3ebde1f957ff79ccf",
//                     "Email": _txtEmail.text,
//                     "Password": _txtPassword.text
//                   }
//                 ).then((response) {
//                   print(response);
//                 });
//                 // showDialog(
//                 //   context: context, 
//                 //   builder: (context) {
//                 //     return const AlertDialog(
//                 //       title: Text('Login'),
//                 //       content: Text('Login Sukses'),
//                 //     );
//                 //   }
//                 // );
//               }, 
//               child: const Text('Submit')
//             )
//           ],
//         ),
//       ),
// 		);
// 	}
// }
