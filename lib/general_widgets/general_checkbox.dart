import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:typhon/general_widgets/general_widgets.dart';

class GeneralCheckbox extends StatefulWidget {
  GeneralCheckbox({
    super.key,
    required this.value,
    required this.onChanged

  });

  void Function(bool) onChanged;
  bool value;

  @override
  State<GeneralCheckbox> createState() => _GeneralCheckboxState();
}

class _GeneralCheckboxState extends State<GeneralCheckbox> {
  late bool _value;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    setState(() {
      _value = widget.value;
    });
  }
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        setState(() {
          _value = !_value;
        });
        widget.onChanged(_value);
      },
      child: Container(
        height: 20,
        width: 20,
        decoration: BoxDecoration(
          color: jetBlack,
          border: Border.all(),
          borderRadius: BorderRadius.circular(5)
        ),
        child: Opacity(
          opacity: _value == false? 0 : 1,
          child: Icon(Icons.check,size: 18,color: platinumGray,)
        ),
      ),
    );
  }
}