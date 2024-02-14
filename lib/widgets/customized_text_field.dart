import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/size_config.dart';

Future<void> ensureVisibleOnTextArea({required GlobalKey textfieldKey}) async {
  final keyContext = textfieldKey.currentContext;
  if (keyContext != null) {
    await Future.delayed(const Duration(milliseconds: 500)).then(
      (value) => Scrollable.ensureVisible(
        keyContext,
        duration: const Duration(milliseconds: 200),
        curve: Curves.decelerate,
      ),
    );
  }
}

class CustomizedTextField extends StatefulWidget {
  const CustomizedTextField(
      {super.key,
      required this.onChanged,
      this.decoration = const InputDecoration(),
      this.initialValue,
      this.formatters,
      this.title,
      this.enabled = true,
      this.obscuringCharacter = "*",
      this.obscureText = false,
      this.validator,
      this.minLines,
      this.keyboardType,
      this.controller,
      this.maxLines,
      this.height});

  final String obscuringCharacter;
  final void Function(String) onChanged;
  final InputDecoration decoration;
  final String? initialValue;
  final String? title;
  final bool? enabled;
  final int? minLines;
  final TextEditingController? controller;
  final int? maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final double? height;
  final String? Function(String?)? validator;
  final List<TextInputFormatter>? formatters;

  @override
  State<CustomizedTextField> createState() => _CustomizedTextFieldState();
}

class _CustomizedTextFieldState extends State<CustomizedTextField> {
  final _key1 = GlobalKey<State<StatefulWidget>>();
  late TextEditingController controller;
  FocusNode node = FocusNode();

  @override
  void initState() {
    controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Visibility(
          visible: widget.title != null,
          child: Text(widget.title ?? ''),
        ),
        Visibility(
          visible: widget.title != null,
          child: SizedBox(
            height: getProportionateScreenHeight(5),
          ),
        ),
        SizedBox(
          height: widget.height,
          child: TextFormField(
            validator: widget.validator,
            focusNode: node,
            obscuringCharacter: widget.obscuringCharacter,
            onTapOutside: (controller) {
              node.unfocus();
            },
            maxLines: widget.maxLines,
            keyboardType: widget.keyboardType,
            obscureText: widget.obscureText,
            enabled: widget.enabled,
            inputFormatters: widget.formatters,
            key: _key1,
            minLines: widget.minLines,
            decoration: widget.decoration,
            onChanged: widget.onChanged,
            controller: controller,
            onTap: () {
              ensureVisibleOnTextArea(textfieldKey: _key1);
            },
          ),
        ),
      ],
    );
  }
}
