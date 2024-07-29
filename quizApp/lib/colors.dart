import 'package:flutter/material.dart';

const List<Color> colors = [
  Color(0xffe94046),
  Color(0xff2f91e7),
  Color(0xFFDDC400),
  Color(0xff6dd35e),
  Color(0xff8f5fe8),
  Colors.deepOrangeAccent,
];

const Color backgroundColor = Color(0x00000000);
const Color accentColor = Color(0xff181b23);

Color invertColor(Color color) => Color.fromARGB(color.alpha, 255 - color.red, 255 - color.green, 255 - color.blue);