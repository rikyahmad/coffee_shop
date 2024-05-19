import 'package:coffee_shop/component/image_item.dart';
import 'package:coffee_shop/component/rounded_text_button.dart';
import 'package:coffee_shop/helper/dialog_helper.dart';
import 'package:coffee_shop/model/product.dart';
import 'package:coffee_shop/controller/multiple_animation_controller.dart';
import 'package:flutter/material.dart';

import '../config.dart';
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
  final double _fabSize = 55;
  final double _buttonHeight = 55;
  final double _cartIconSize = 35;
  final double _paddingHorizontal = 25;
  final double _actionButtonWidth = 160; // rough estimate

  Offset? widgetPosition;
  double _dragAmount = 0;
  int _totalItems = 0;
  double _showValue = 0;
  double _scaleValue = 1;
  SizeModel? _selectedSize;

  late final MultipleAnimationController _cartAnimation =
      MultipleAnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    reverseDuration: const Duration(milliseconds: 500),
  );

  late final AnimationController _showController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
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
        _resetValue();
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
      setState(() {
        widgetPosition = renderBox.localToGlobal(Offset.zero);
        widget.positionCallback?.call(widgetPosition!);
        debugPrint("Position Details : $widgetPosition");
      });
    } on Exception catch (e) {
      debugPrint("Error : $e");
    }
  }

  @override
  void dispose() {
    widget.controller.dispose();
    _cartAnimation.dispose();
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
                onHorizontalDragStart: (details) {
                  _dragAmount = 0.0;
                },
                onHorizontalDragUpdate: (details) {
                  _dragAmount += details.primaryDelta ?? 0.0;
                },
                onHorizontalDragEnd: (details) {
                  if (_dragAmount > 90) {
                    _goBack();
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
                              duration: const Duration(milliseconds: 300),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    widget.selectedProduct?.imageAssets ??
                                        "assets/images/burger_1.png",
                                    width: productWidth,
                                    height: productHeight,
                                  ),
                                  ..._cartAnimation.animations.map((animation) {
                                    return AnimatedBuilder(
                                      animation: animation,
                                      builder: (context, child) {
                                        return _ItemCopy(
                                          toSize: _cartIconSize,
                                          value: (1 - animation.value)
                                              .clamp(0, 1), //addToCartValue
                                          paddingHorizontal: _paddingHorizontal,
                                          scale: _selectedSize?.scale,
                                          sourcePosition: widgetPosition,
                                          assets: widget
                                              .selectedProduct?.imageAssets,
                                        );
                                      },
                                    );
                                  })
                                ],
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
                    padding: EdgeInsets.fromLTRB(
                        _paddingHorizontal, 25, _paddingHorizontal, 20),
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
                                  } else {
                                    DialogHelper.showToast("More pressed");
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
                  Container(
                    padding: EdgeInsets.fromLTRB(
                        _paddingHorizontal, 20, _paddingHorizontal, 30),
                    child: Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: MediaQuery.of(context).size.width -
                              (_paddingHorizontal * 2) -
                              (_totalItems > 0
                                  ? _actionButtonWidth
                                  : _fabSize + _paddingHorizontal),
                          child: RoundedTextButton(
                            text: 'Customize',
                            onPressed: () {
                              DialogHelper.showToast("Customize pressed");
                            },
                            height: _buttonHeight,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 5),
                          ),
                        ),
                        Stack(
                          alignment: Alignment.centerRight,
                          children: [
                            AnimatedOpacity(
                              opacity: _totalItems > 0 ? 0 : 1,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedContainer(
                                alignment: Alignment.centerRight,
                                transform: Matrix4.translationValues(
                                    0, _totalItems > 0 ? _buttonHeight : 0, 0),
                                duration: const Duration(milliseconds: 200),
                                child: SizedBox(
                                  height: _fabSize,
                                  width: _fabSize,
                                  child: FloatingActionButton(
                                    onPressed: () {
                                      setState(() {
                                        _addToCart(totalItem: _totalItems + 1);
                                      });
                                    },
                                    elevation: 3,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(50.0),
                                    ),
                                    backgroundColor: Colors.white,
                                    child: const Icon(Icons.add),
                                  ),
                                ),
                              ),
                            ),
                            AnimatedOpacity(
                              opacity: _totalItems > 0 ? 1 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: AnimatedContainer(
                                transform: Matrix4.translationValues(
                                    0, _totalItems > 0 ? 0 : _buttonHeight, 0),
                                duration: const Duration(milliseconds: 200),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove),
                                      onPressed: () {
                                        setState(() {
                                          _addToCart(
                                              totalItem: _totalItems - 1);
                                        });
                                      },
                                      iconSize: 25,
                                      color: Colors.black54,
                                    ),
                                    Container(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 5),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      height: 50,
                                      alignment: Alignment.center,
                                      child: Text(
                                        _totalItems.toString(),
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.black54,
                                        ),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add),
                                      onPressed: () {
                                        setState(() {
                                          _addToCart(
                                              totalItem: _totalItems + 1);
                                        });
                                      },
                                      iconSize: 25,
                                      color: Colors.black54,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
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

  void _resetValue() {
    _scaleValue = 1;
    _showValue = 0;
    _totalItems = 0;
    _dragAmount = 0;
    _selectedSize = null;
  }

  void _addToCart({required int totalItem}) {
    if (totalItem > _totalItems) {
      _cartAnimation.animate(callback: ({Function? start, Function? end}) {
        if (start != null) {
          setState(() {
            start.call();
          });
        }
        if (end != null) {
          setState(() {
            end.call();
          });
        }
      });
    }
    _totalItems = totalItem;
  }

  void _goBack() {
    if (!widget.controller.isAnimating) {
      setState(() {
        _reverse(delay: 500);
      });
    }
  }
}

class _ItemCopy extends StatelessWidget {
  const _ItemCopy({
    required this.toSize,
    required this.value,
    required this.paddingHorizontal,
    this.scale,
    this.sourcePosition,
    this.assets,
  });

  final double toSize;
  final double value;
  final double paddingHorizontal;
  final double? scale;
  final Offset? sourcePosition;
  final String? assets;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Opacity(
      opacity: value,
      child: Transform.translate(
        offset: Offset(
                (1 - value) *
                    ((screenWidth / 2) -
                        (toSize / 2) -
                        (paddingHorizontal / 2)),
                ((1 - value) *
                    (-((sourcePosition?.dy ?? 0) +
                        ((productHeight - toSize) / 2) -
                        toolbarHeight)))) /
            (scale ?? 1.0),
        child: Transform.scale(
          scale: (toSize + ((productWidth - toSize) * value)) / productWidth,
          child: Image.asset(
            assets ?? "assets/images/burger_1.png",
            width: productWidth,
            height: productHeight,
          ),
        ),
      ),
    );
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
