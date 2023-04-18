
import 'package:flutter/material.dart';

class TextFormRoundBB extends StatelessWidget {
  const TextFormRoundBB({super.key, required this.controller, required this.placeholder, this.sufIcon, this.hidePassword = false, this.pHorizontal = 8, this.pVertical = 16, this.cHorizontal = 30, this.cVertical = 20, this.lines = 1, this.keyboardType = TextInputType.text, this.action});
  final TextEditingController controller;
  final String placeholder;
  final Widget? sufIcon;
  final bool hidePassword;
  final double pHorizontal;
  final double pVertical;
  final double cHorizontal;
  final double cVertical;
  final int? lines;
  final TextInputType? keyboardType;
  final TextInputAction? action;

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: pHorizontal, vertical: pVertical),
      child: TextFormField(
        textInputAction: action,
        keyboardType: keyboardType,
        maxLines: lines,
        obscureText: hidePassword,
        controller: controller,
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(50.0)
          ), 
          labelText: placeholder,
          contentPadding: EdgeInsets.symmetric(horizontal: cHorizontal, vertical: cVertical),
          suffixIcon: sufIcon,
          alignLabelWithHint: true
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