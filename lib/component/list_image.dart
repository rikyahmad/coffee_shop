import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_custom_carousel/flutter_custom_carousel.dart';

class ListImage extends StatefulWidget {
  const ListImage({
    super.key,
    required this.items,
    required this.builder,
    this.controller,
    this.alignment = Alignment.center,
    this.itemCountAfter = 2,
    this.scrollSpeed = 0.7,
    this.onSelectedItemChanged,
  });

  final CustomCarouselScrollController? controller;
  final List<ImageModel> items;
  final ImageItemBuilder builder;
  final Alignment? alignment;
  final int? itemCountAfter;
  final double scrollSpeed;
  final SelectedItemCallback? onSelectedItemChanged;

  @override
  State<ListImage> createState() => _ListImageState();
}

class _ListImageState extends State<ListImage> {
  int _selectedIndex = 0;
  double _offset = 0;

  late CustomCarouselScrollController _controller;

  @override
  void initState() {
    _controller = widget.controller ?? CustomCarouselScrollController();
    _controller.addListener(() {
      _offset = _controller.offset;
      final endPixel =
          ((_controller.selectedItem + 1)) * (_controller.position.itemExtent);
      final range = _offset / endPixel;
      //final range = maxExtent - ((_controller.selectedItem + 1) * _offset);
      debugPrint("Offset : $endPixel | $_offset | $range");
    });
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomCarousel(
      controller: _controller,
      itemCountBefore: 0,
      itemCountAfter: widget.itemCountAfter,
      scrollDirection: Axis.vertical,
      loop: true,
      reverse: true,
      depthOrder: DepthOrder.reverse,
      scrollSpeed: widget.scrollSpeed,
      alignment: widget.alignment,
      effectsBuilder: CustomCarousel.effectsBuilderFromAnimate(
        effects: EffectList()
            //.listen(callback: callback)
            .addEffect(FadeEffect(
              delay: 100.ms,
              duration: 100.ms,
              begin: FadeEffect.neutralValue,
              end: 1,
            ))
            .scale(end: const Offset(0.2, 0.2))
            .slide(end: const Offset(0.4, -0.7))
            .slideX(delay: 0.ms, begin: -0.5)
            .scaleXY(
                begin: 0,
                end: 1,
                curve: Curves.easeIn,
                alignment: Alignment.bottomLeft),
      ),
      // This uses a combination of selected and settled item so that the
      // transaction list only appears after the user has settled on a card, but
      // the list doesn't get removed until they scroll fully off the card.
      onSelectedItemChanged: (i) {
        _selectedIndex = i;
        widget.onSelectedItemChanged
            ?.call(i, _controller.position.userScrollDirection);
      },
      children: List.generate(widget.items.length, (index) {
        final item = widget.items[index];
        return widget.builder(index, index == _selectedIndex, item);
      }),
    );
  }
}

typedef ImageItemBuilder = Widget Function(
    int index, bool selected, ImageModel item);
typedef SelectedItemCallback = void Function(
    int index, ScrollDirection scrollDirection);

class ImageModel {
  String? url;
  String? assets;
  String placeholderAssets;
  bool loading;

  ImageModel(
      {this.url,
      this.assets,
      this.loading = false,
      required this.placeholderAssets});
}
