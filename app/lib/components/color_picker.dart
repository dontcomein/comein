import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ColorPicker extends StatefulWidget {
  const ColorPicker({
    super.key,
    required this.onColorChanged,
    this.initial,
  });
  final Function(Color) onColorChanged;
  final Color? initial;
  @override
  State<ColorPicker> createState() => _ColorPickerState();
}

class _ColorPickerState extends State<ColorPicker> {
  int r = 0;
  int g = 0;
  int b = 0;
  int a = 255;
  @override
  void initState() {
    r = widget.initial?.red ?? 0;
    g = widget.initial?.green ?? 0;
    b = widget.initial?.blue ?? 0;
    a = widget.initial?.alpha ?? 255;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color.fromARGB(a, r, g, b),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PlatformSlider(
              thumbColor: Color.fromARGB(255, 255, 255 - r, 255 - r),
              value: r / 255,
              onChanged: (x) {
                widget.onColorChanged(Color.fromARGB(a, r, g, b));
                setState(() => r = (x * 255).toInt());
              }),
          PlatformSlider(
              thumbColor: Color.fromARGB(255, 255 - g, 255, 255 - g),
              value: g / 255,
              onChanged: (x) {
                widget.onColorChanged(Color.fromARGB(a, r, g, b));
                setState(() => g = (x * 255).toInt());
              }),
          PlatformSlider(
            thumbColor: Color.fromARGB(255, 255 - b, 255 - b, 255),
            value: b / 255,
            onChanged: (x) {
              widget.onColorChanged(Color.fromARGB(a, r, g, b));
              setState(() => b = (x * 255).toInt());
            },
          ),
        ],
      ),
    );
  }
}
