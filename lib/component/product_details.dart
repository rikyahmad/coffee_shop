import 'package:coffee_shop/component/image_item.dart';
import 'package:coffee_shop/component/rounded_text_button.dart';
import 'package:coffee_shop/model/product.dart';
import 'package:flutter/material.dart';

import 'circle_button.dart';

class ProductDetails extends StatefulWidget {
  const ProductDetails({
    super.key,
    required this.selectedProduct,
    required this.controller,
    this.positionCallback,
  });

  final Product? selectedProduct;
  final AnimationController controller;
  final PositionCallback? positionCallback;

  @override
  State<ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
  final GlobalKey _key = GlobalKey();
  Offset? widgetPosition;
  double _showValue = 0;
  double _scaleValue = 1;
  SizeModel? _selectedSize;

  late final AnimationController _showController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 200),
  );

  final List<SizeModel> sizeList = [
    SizeModel(
      name: "Small",
      svgAssets: "assets/svg/burger.svg",
      scale: 0.6,
      iconScale: 0.8,
      productSize: ProductSize.small,
    ),
    SizeModel(
      name: "Medium",
      svgAssets: "assets/svg/burger.svg",
      scale: 0.8,
      iconScale: 0.9,
      productSize: ProductSize.medium,
    ),
    SizeModel(
      name: "Large",
      svgAssets: "assets/svg/burger.svg",
      scale: 1,
      iconScale: 1,
      productSize: ProductSize.large,
    ),
    SizeModel(
      name: "More",
      svgAssets: "assets/svg/next.svg",
      scale: 1,
      iconScale: 1.2,
      productSize: ProductSize.none,
    ),
  ];

  @override
  void initState() {
    _showController.addListener(() {
      setState(() {
        _showValue = _showController.value;
      });
    });
    _showController.addStatusListener((status) {
      if (status == AnimationStatus.dismissed) {
        _scaleValue = 1;
        _selectedSize = null;
        //hide
        widget.controller.reverse();
      }
    });
    widget.controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //visible
        _showController.forward(from: 0);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback(_getPosition);
    super.initState();
  }

  void _getPosition(_) {
    try {
      final RenderBox renderBox =
          _key.currentContext?.findRenderObject() as RenderBox;
      widgetPosition = renderBox.localToGlobal(Offset.zero);
      if (widgetPosition != null) {
        widget.positionCallback?.call(widgetPosition!);
        debugPrint("Position : $widgetPosition");
      }
    } on Exception catch (e) {
      debugPrint("Error : $e");
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  if (!widget.controller.isAnimating) {
                    setState(() {
                      _reverse(delay: 500);
                    });
                  }
                },
                child: AnimatedBuilder(
                    animation: widget.controller,
                    builder: (context, child) {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            key: _key,
                            color: Colors.transparent,
                            child: AnimatedScale(
                              scale: _scaleValue,
                              duration: const Duration(milliseconds: 500),
                              child: Image.asset(
                                widget.selectedProduct?.imageAssets ??
                                    "assets/images/burger_1.png",
                                width: 400,
                                height: 400,
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
              ),
            ),
          ),
          Transform.translate(
            offset: Offset(0, 400 - (400 * _showValue)),
            child: Container(
              color: Colors.white,
              width: double.infinity,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 25, 25, 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(sizeList.length, (index) {
                        final item = sizeList[index];
                        final selected = item == _selectedSize;
                        return Column(
                          children: [
                            CircularIconButton(
                              iconColor:
                                  selected ? Colors.brown : Colors.black26,
                              circleColor:
                                  selected ? Colors.amber : Colors.white,
                              circleBorderColor:
                                  selected ? Colors.amber : Colors.black26,
                              svgAsset: item.svgAssets,
                              iconSize: 21 * item.iconScale,
                              onPressed: () {
                                setState(() {
                                  if (index != 3) {
                                    _scaleValue = item.scale;
                                    _selectedSize = item;
                                  }
                                });
                                debugPrint('Button Pressed');
                              },
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.name,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black54),
                            )
                          ],
                        );
                      }),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(25, 20, 25, 30),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: RoundedTextButton(
                            text: 'Customize',
                            onPressed: () {
                              // Action when button is pressed
                              debugPrint('Button Pressed');
                            },
                            height: 55,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: FloatingActionButton(
                            onPressed: () {},
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50.0),
                            ),
                            backgroundColor: Colors.white,
                            child: const Icon(Icons.add),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _reverse({required int delay}) async {
    if (_scaleValue != 1) {
      _scaleValue = 1;
      await Future.delayed(Duration(milliseconds: delay));
    }
    _showController.reverse();
  }
}

class SizeModel {
  String name;
  String svgAssets;
  double scale;
  double iconScale;
  ProductSize productSize;

  SizeModel({
    required this.name,
    required this.svgAssets,
    required this.scale,
    required this.iconScale,
    required this.productSize,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SizeModel &&
          runtimeType == other.runtimeType &&
          productSize == other.productSize;

  @override
  int get hashCode => productSize.hashCode;
}

enum ProductSize { small, medium, large, none }