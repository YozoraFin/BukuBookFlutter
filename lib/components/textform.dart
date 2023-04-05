
import 'package:flutter/material.dart';

class TextFormRoundBB extends StatelessWidget {
  const TextFormRoundBB({super.key, required this.controller, required this.placeholder, this.sufIcon, required this.hidePassword});
  final TextEditingController controller;
  final String placeholder;
  final Widget? sufIcon;
  final bool hidePassword;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      child: TextFormField(
        obscureText: hidePassword,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0)
          ), 
          labelText: placeholder,
          contentPadding: EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          suffixIcon: sufIcon
        ),
        validator: (value) {
          if(value == null || value.isEmpty) {
            return 'Tolong masukkan ${placeholder.toLowerCase()} anda';
          }
          return null;
        },
      ),
    );
  }
}