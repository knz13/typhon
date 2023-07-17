import 'package:flutter/material.dart';
import 'package:typhon/general_widgets.dart';

class GeneralTextField extends StatelessWidget {
  GeneralTextField(this.initialText,{
    super.key,
    this.onChanged,
    this.prefixIcon
  }) {
    _controller = TextEditingController(text: this.initialText);
  }

  String initialText;
  void Function(String)? onChanged;
  Widget? prefixIcon;

  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      child: TextField(
        controller: _controller,
        onChanged: onChanged,
        style: TextStyle(
          fontSize: 13,
          color: platinumGray
        ),
        decoration: InputDecoration(
          fillColor: jetBlack,
          filled: true,
          prefixIcon: prefixIcon,
          prefixIconConstraints: BoxConstraints(minWidth: 30),
          contentPadding: EdgeInsets.symmetric(horizontal: 5),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))
        ),
      ),
    );
  }
}
