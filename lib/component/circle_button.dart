import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CircularIconButton extends StatelessWidget {
  final String svgAsset;
  final double iconSize;
  final Color iconColor;
  final Color circleColor;
  final double circleSize;
  final double circleBorderWidth;
  final Color circleBorderColor;
  final VoidCallback onPressed;

  const CircularIconButton({
    super.key,
    required this.svgAsset,
    this.iconSize = 21.0,
    this.iconColor = Colors.black26,
    this.circleColor = Colors.white,
    this.circleBorderColor = Colors.black26,
    this.circleSize = 50.0,
    this.circleBorderWidth = 1.5,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: circleSize,
      height: circleSize,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          shape: MaterialStateProperty.all<CircleBorder>(
            CircleBorder(
              side: BorderSide(
                color: circleBorderColor,
                width: circleBorderWidth,
              ),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(circleColor),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            EdgeInsets.zero,
          ),
        ),
        child: Center(
          child: SvgPicture.asset(
            svgAsset,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
