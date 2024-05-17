import 'package:flutter/material.dart';

class RoundedTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final Color textColor;
  final Color borderColor;
  final double borderRadius;
  final double borderWidth;
  final double height;
  final double fontSize;
  final FontWeight? fontWeight;
  final EdgeInsetsGeometry padding;

  const RoundedTextButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = Colors.amber,
    this.textColor = Colors.brown,
    this.borderColor = Colors.transparent,
    this.borderRadius = 50.0,
    this.borderWidth = 1.0,
    this.fontSize = 16,
    this.height = 50,
    this.fontWeight = FontWeight.w700,
    this.padding = EdgeInsets.zero,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          padding: MaterialStateProperty.all(padding),
          backgroundColor: MaterialStateProperty.all<Color>(backgroundColor),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius),
              side: BorderSide(
                color: borderColor,
                width: borderWidth,
              ),
            ),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
