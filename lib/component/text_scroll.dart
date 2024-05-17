import 'package:flutter/material.dart';

class TextScroll extends StatefulWidget {
  const TextScroll({
    super.key,
    required this.pageController,
    required this.itemCount,
    required this.height,
    required this.builder,
    this.width,
  });

  final NullableIndexedWidgetBuilder builder;
  final PageController pageController;
  final int itemCount;
  final double? width;
  final double? height;

  @override
  State<TextScroll> createState() => _TextScrollState();
}

class _TextScrollState extends State<TextScroll> {
  late PageController _pageController;

  @override
  void initState() {
    _pageController = widget.pageController;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: widget.itemCount,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: widget.builder,
      ),
    );
  }
}
