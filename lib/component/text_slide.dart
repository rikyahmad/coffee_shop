import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../util/convert.dart';

class TextSlide extends StatefulWidget {
  final StackItemBuilder builder;
  final AnimationTextController? controller;
  final List<ItemModel> items;
  final double? width;
  final double height;
  final double itemHeight;
  final double extraHorizontalPadding;
  final double minScale;
  final EdgeInsetsGeometry? padding;

  const TextSlide({
    super.key,
    required this.builder,
    required this.items,
    required this.itemHeight,
    required this.height,
    required this.width,
    this.padding,
    this.minScale = 0.3,
    this.extraHorizontalPadding = 10,
    this.controller,
  });

  @override
  State<TextSlide> createState() => _TextSlideState();
}

class _TextSlideState extends State<TextSlide>
    with SingleTickerProviderStateMixin {
  late AnimationTextController controller;

  @override
  void initState() {
    super.initState();
    controller = widget.controller ??
        AnimationTextController.init(
          duration: const Duration(milliseconds: 1000),
          vsync: this,
        );

    controller.addResetCallback((function) {
      setState(() {
        function.call();
      });
    });
    controller.addItemCallback(() {
      return widget.items;
    });
    _updateItemsSize();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
          children: List.generate(3, (index) {
        return AnimatedBuilder(
            animation: controller.animation,
            builder: (context, child) {
              final actualIndex = (index + (controller.selectedIndex - 1)) %
                  widget.items.length;
              final animValue = _getAnimValue(index);
              final item = widget.items[actualIndex];
              return Positioned(
                left: _getLeft(index) + controller.animationValue,
                child: Opacity(
                  opacity: animValue.opacity,
                  child: Transform.scale(
                    scale: animValue.scale,
                    alignment: Alignment.center,
                    child: widget.builder(actualIndex, item),
                  ),
                ),
              );
            });
      })),
    );
  }

  double _getLeft(int index) {
    //left
    if (index == 0) {
      final atIndex = (controller.selectedIndex - 1) % widget.items.length;
      return -(widget.items.elementAtOrNull(atIndex)?.size?.width ?? 0); //0
    }
    //right
    if (index == 2) {
      return widget.items
              .elementAtOrNull(controller.selectedIndex)
              ?.size
              ?.width ??
          0; //1
    }
    return 0;
  }

  AnimValue _getAnimValue(int index) {
    final controllerValue = controller.value; // 0.0 - 1.0
    if (controller.scroll == Scroll.right) {
      // center to right
      if (index == 2) {
        // in
        return AnimValue(
            scale: (controllerValue * (1 - widget.minScale)) + widget.minScale,
            opacity: controllerValue); // controllerValue * 0.7 + 0.3
      }
    }
    if (controller.scroll == Scroll.left) {
      // center to left
      if (index == 0) {
        return AnimValue(scale: 1, opacity: 1);
      }
      if (index == 1) {
        // out
        return AnimValue(
            scale: 1 - (controllerValue * (1 - widget.minScale)),
            opacity: 1 - controllerValue);
      }
    }
    return AnimValue(scale: index == 1 ? 1 : 0, opacity: index == 1 ? 1 : 0);
  }

  void _updateItemsSize() {
    final double paddingHorizontal = widget.padding?.horizontal ?? 0;
    final double extraSpace = widget.extraHorizontalPadding;
    for (var data in widget.items) {
      double titleWidth =
          calculateTextWidth(data.title, ItemModel.titleTextStyle);
      double descWidth = calculateTextWidth(data.desc, ItemModel.descTextStyle);
      if (titleWidth > 0 && descWidth > 0) {
        final maxSize = max(titleWidth, descWidth);
        data.size = Size(
            maxSize + (paddingHorizontal * 2) + extraSpace, widget.itemHeight);
        debugPrint("Text : ${data.desc} | ${data.size?.width}");
      }
    }
  }
}

typedef StackItemBuilder = Widget Function(int index, ItemModel item);
typedef PageChangedCallback = void Function(Size);

enum Scroll { left, center, right }

class ItemModel {
  String title;
  String desc;
  int index;
  Size? size;

  ItemModel(
      {required this.title,
      required this.desc,
      required this.index,
      this.size});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemModel &&
          runtimeType == other.runtimeType &&
          index == other.index;

  @override
  int get hashCode => index.hashCode;

  static TextStyle titleTextStyle = const TextStyle(
    fontSize: 25,
    fontWeight: FontWeight.bold,
  );

  static TextStyle descTextStyle = const TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
  );
}

class AnimValue {
  double scale;
  double opacity;

  AnimValue({
    required this.scale,
    required this.opacity,
  });
}

typedef AnimationResetCallback = void Function(Function);
typedef AnimationItemCallback<T> = List<T> Function();

class AnimationTextController {
  late AnimationController _controller;
  late Animation<double> animation;
  AnimationItemCallback? _itemCallback;
  AnimationResetCallback? _resetCallback;
  Scroll scroll = Scroll.center;
  int selectedIndex = 0;
  int _nextIndexTemp = -1;
  ScrollDirection _nextScrollDirection = ScrollDirection.idle;

  AnimationTextController.init(
      {required Duration duration, required TickerProvider vsync}) {
    _controller = AnimationController(
      duration: duration,
      vsync: vsync,
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          debugPrint("Completed");
          reset();
          _doNextAnimation();
        }
      });

    animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  AnimationStatus get status => _controller.status;

  bool get isDismissed => _controller.isDismissed;

  bool get isCompleted => _controller.isCompleted;

  bool get isAnimating => _controller.isAnimating;

  double get value => _controller.value;

  double get animationValue => animation.value;

  int get itemsLength => _itemCallback?.call().length ?? 0;

  void addItemCallback(AnimationItemCallback itemCallback) {
    _itemCallback = itemCallback;
  }

  void addResetCallback(AnimationResetCallback resetCallback) {
    _resetCallback = resetCallback;
  }

  void dispose() {
    _controller.dispose();
  }

  void reset() {
    _resetCallback?.call(() {
      final items = _itemCallback?.call();
      final itemsLength = items?.length ?? 0;
      // set selected index
      if (scroll == Scroll.right) {
        selectedIndex = (selectedIndex + 1) % itemsLength;
      } else if (scroll == Scroll.left) {
        selectedIndex = (selectedIndex - 1) % itemsLength;
      }
      animation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
      );
      _controller.value = 0;
      _controller.reset();
      scroll = Scroll.center;
    });
  }

  void animateTo(double begin, double end) {
    debugPrint("begin : $begin, end : $end");
    //final from = _controller.isAnimating ? _controller.value : begin;
    _controller.reset();
    animation = Tween<double>(begin: begin, end: end).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    scroll = end == 0
        ? Scroll.center
        : end > 0
            ? Scroll.left
            : Scroll.right;
    _controller.forward();
  }

  void animateNext() {
    final items = _itemCallback?.call();
    final itemsLength = items?.length ?? 0;
    final toIndex = (selectedIndex + 1) % itemsLength;
    animateScrollTo(index: toIndex);
  }

  void animatePrev() {
    final items = _itemCallback?.call();
    final itemsLength = items?.length ?? 0;
    final toIndex = (selectedIndex - 1) % itemsLength;
    animateScrollTo(index: toIndex);
  }

  void animateScrollTo({required int index}) {
    animateDirectionTo(
        index: index,
        scrollDirection: _toRight(selectedIndex, index)
            ? ScrollDirection.reverse
            : ScrollDirection.forward);
  }

  void animateDirectionTo({
    required int index,
    required ScrollDirection scrollDirection,
  }) {
    if (_controller.isAnimating) {
      _nextIndexTemp = index;
      _nextScrollDirection = scrollDirection;
      return;
    }
    //if (selectedIndex == index) return;
    final items = _itemCallback?.call();
    final itemsLength = items?.length ?? 0;
    // to right or reverse
    if (scrollDirection == ScrollDirection.reverse) {
      selectedIndex = (index - 1) % itemsLength;
      animateTo(animation.value,
          -(items?.elementAtOrNull(selectedIndex)?.size?.width ?? 0)); // 1
      debugPrint("Animated right : $_controller.selectedIndex");
    } else {
      selectedIndex = (index + 1) % itemsLength;
      final atIndex = (selectedIndex - 1) % itemsLength;
      animateTo(animation.value,
          (items?.elementAtOrNull(atIndex)?.size?.width ?? 0)); // 0
      debugPrint("Animated left : $atIndex | $_controller.selectedIndex");
    }
  }

  void _doNextAnimation() {
    if (_nextIndexTemp >= 0 && _nextScrollDirection != ScrollDirection.idle) {
      animateDirectionTo(
          index: _nextIndexTemp, scrollDirection: _nextScrollDirection);
      _nextIndexTemp = -1;
      _nextScrollDirection = ScrollDirection.idle;
    }
  }

  bool _toRight(int currentIndex, int toIndex) {
    if (selectedIndex == 0 && toIndex == itemsLength - 1) {
      return false;
    }
    if (toIndex == 0 && currentIndex == itemsLength - 1) {
      return true;
    }
    if (toIndex > currentIndex) {
      return true;
    }
    return false;
  }
}
