import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:typhon/general_widgets/general_widgets.dart';

class GeneralTextField extends StatelessWidget {
  GeneralTextField(this.initialText,
      {super.key,
      this.onChanged,
      this.prefixIcon,
      this.formatters,
      this.onSubmitted,
      this.type = TextInputType.text}) {
    _controller = TextEditingController(text: this.initialText);
  }

  String initialText;
  void Function(String)? onChanged;
  void Function(String)? onSubmitted;
  Widget? prefixIcon;
  List<TextInputFormatter>? formatters;
  TextInputType type;
  TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 20,
      child: TextField(
        onSubmitted: (value) {},
        keyboardType: type,
        inputFormatters: formatters,
        controller: _controller,
        onChanged: onChanged,
        style: TextStyle(fontSize: 13, color: platinumGray),
        decoration: InputDecoration(
            fillColor: jetBlack,
            filled: true,
            prefixIcon: prefixIcon,
            prefixIconConstraints: BoxConstraints(minWidth: 30),
            contentPadding: EdgeInsets.symmetric(horizontal: 5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(5))),
      ),
    );
  }
}
