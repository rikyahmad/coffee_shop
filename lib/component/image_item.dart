import 'package:coffee_shop/component/list_image.dart';
import 'package:flutter/material.dart';

typedef PositionCallback = void Function(Offset offset);
typedef ImageClickCallback = void Function(Offset? offset);

class ImageItem extends StatefulWidget {
  const ImageItem({
    super.key,
    required this.index,
    required this.selected,
    required this.item,
    required this.onClick,
    required this.parentKey,
    this.positionCallback,
  });

  final int index;
  final bool selected;
  final ImageModel item;
  final ImageClickCallback onClick;
  final PositionCallback? positionCallback;
  final GlobalKey parentKey;

  @override
  State<ImageItem> createState() => _ImageItemState();
}

class _ImageItemState extends State<ImageItem> {
  final GlobalKey _key = GlobalKey();
  Offset? widgetPosition;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(_getPosition);
    super.initState();
  }

  void _getPosition(_) {
    setState(() {
      try {
        final RenderBox renderBox = context.findRenderObject() as RenderBox;
        widgetPosition = renderBox.localToGlobal(Offset.zero,
            ancestor: widget.parentKey.currentContext?.findRenderObject()
                as RenderObject);
        if (widgetPosition != null) {
          widget.positionCallback?.call(widgetPosition!);
          debugPrint("Position : $widgetPosition");
        }
      } on Exception catch (e) {
        debugPrint("Error : $e");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      height: 400,
      color: Colors.transparent,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          widget.onClick.call(widgetPosition);
        },
        child: Image.asset(
          key: _key,
          widget.item.url ??
              widget.item.assets ??
              widget.item.placeholderAssets,
          width: 400,
          height: 400,
        ),
      ),
    );
  }
}
