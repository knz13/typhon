import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:typhon/general_widgets/floating_point_formatter.dart';
import 'package:typhon/general_widgets/general_text_field.dart';
import 'package:typhon/general_widgets/general_widgets.dart';
import 'package:typhon/general_widgets/spacings.dart';

class Vec3FieldBuilder extends StatefulWidget {
  Vec3FieldBuilder(
      {super.key,
      required this.values,
      required this.onChange,
      this.spacingBetweenObjects = 4});

  List<double> values;
  void Function(double, double, double) onChange;
  double spacingBetweenObjects;

  @override
  State<Vec3FieldBuilder> createState() => _Vec3FieldBuilderState();
}

class _Vec3FieldBuilderState extends State<Vec3FieldBuilder> {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Row(
      children: [
        DraggableTextLeftRight("X"),
        HorizontalSpacing(widget.spacingBetweenObjects),
        Expanded(
          child: GeneralTextField(
            widget.values[0].toString(),
            onChanged: (val) {
              if (double.tryParse(val) == null) {
                return;
              }
              widget.onChange(
                  double.parse(val), widget.values[1], widget.values[2]);
            },
            type: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            formatters: [FloatingPointTextInputFormatter()],
          ),
        ),
        HorizontalSpacing(widget.spacingBetweenObjects),
        DraggableTextLeftRight("Y"),
        HorizontalSpacing(widget.spacingBetweenObjects),
        Expanded(
          child: GeneralTextField(
            widget.values[1].toString(),
            onChanged: (val) {
              if (double.tryParse(val) == null) {
                return;
              }
              widget.onChange(
                  widget.values[0], double.parse(val), widget.values[2]);
            },
            onSubmitted: (val) {},
            type: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            formatters: [FloatingPointTextInputFormatter()],
          ),
        ),
        HorizontalSpacing(widget.spacingBetweenObjects),
        DraggableTextLeftRight("Z"),
        HorizontalSpacing(widget.spacingBetweenObjects),
        Expanded(
          child: GeneralTextField(
            widget.values[2].toString(),
            onChanged: (val) {
              if (double.tryParse(val) == null) {
                return;
              }
              widget.onChange(
                  widget.values[0], widget.values[1], double.parse(val));
            },
            type: const TextInputType.numberWithOptions(
                decimal: true, signed: true),
            formatters: [FloatingPointTextInputFormatter()],
          ),
        ),
      ],
    );
  }
}

class DraggableTextUpDown extends StatelessWidget {
  DraggableTextUpDown(this.text, {super.key, this.onMoveUpDown});

  String text;
  void Function(double dx)? onMoveUpDown;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeUpDown,
      child: Draggable(
        dragAnchorStrategy:
            (Draggable<Object> d, BuildContext context, Offset point) {
          return Offset(d.feedbackOffset.dx + 500, d.feedbackOffset.dy + 500);
        },
        ignoringFeedbackPointer: false,
        feedback: MouseRegion(
          cursor: SystemMouseCursors.resizeUpDown,
          child: Container(
            width: 1000,
            height: 1000,
          ),
        ),
        onDragUpdate: (details) {
          onMoveUpDown?.call(details.delta.dy);
        },
        child: GeneralText(
          text,
          alignment: TextAlign.center,
        ),
      ),
    );
  }
}

class DraggableTextLeftRight extends StatelessWidget {
  DraggableTextLeftRight(this.text, {super.key, this.onMoveLeftRight});

  String text;
  void Function(double dx)? onMoveLeftRight;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.resizeLeftRight,
      child: Draggable(
        dragAnchorStrategy:
            (Draggable<Object> d, BuildContext context, Offset point) {
          return Offset(d.feedbackOffset.dx + 500, d.feedbackOffset.dy + 500);
        },
        ignoringFeedbackPointer: false,
        feedback: MouseRegion(
          cursor: SystemMouseCursors.resizeLeftRight,
          child: Container(
            width: 1000,
            height: 1000,
          ),
        ),
        onDragUpdate: (details) {
          onMoveLeftRight?.call(details.delta.dx);
        },
        child: GeneralText(
          text,
          alignment: TextAlign.center,
        ),
      ),
    );
  }
}
