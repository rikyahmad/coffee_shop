import 'package:coffee_shop/component/image_item.dart';
import 'package:coffee_shop/component/list_image.dart';
import 'package:coffee_shop/component/product_details.dart';
import 'package:coffee_shop/component/text_scroll.dart';
import 'package:coffee_shop/component/text_slide.dart';
import 'package:coffee_shop/component/title_item.dart';
import 'package:coffee_shop/config.dart';
import 'package:coffee_shop/helper/dialog_helper.dart';
import 'package:coffee_shop/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel/flutter_custom_carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const CoffeeApp());
}

class CoffeeApp extends StatefulWidget {
  const CoffeeApp({super.key});

  @override
  State<CoffeeApp> createState() => _CoffeeAppState();
}

class _CoffeeAppState extends State<CoffeeApp> with TickerProviderStateMixin {
  final List<Product> products = [
    Product(
        id: 0,
        title: "Chicken",
        category: Category.burger,
        imageAssets: "assets/images/burger_1.png",
        price: 3.12),
    Product(
        id: 1,
        title: "Meaty",
        category: Category.burger,
        imageAssets: "assets/images/burger_2.png",
        price: 7.12),
    Product(
        id: 2,
        title: "Veggies",
        category: Category.burger,
        imageAssets: "assets/images/burger_3.png",
        price: 5.12),
    Product(
        id: 3,
        title: "Cheese",
        category: Category.burger,
        imageAssets: "assets/images/burger_4.png",
        price: 6.12),
    Product(
        id: 4,
        title: "Mixed Veggies",
        category: Category.burger,
        imageAssets: "assets/images/burger_5.png",
        price: 6.52),
  ];

  final GlobalKey _key = GlobalKey();

  final List<ItemModel> titles = [];

  final List<ImageModel> images = [];

  final double _itemOffsetX = -20;

  final List<double> prices = [];

  Product? _selectedProduct;

  Offset? widgetPosition;

  double _detailsAnimateValue = 0;

  bool showDetails = true;

  final CustomCarouselScrollController imageController =
      CustomCarouselScrollController();

  final PageController priceController = PageController();

  late AnimationTextController titleController = AnimationTextController.init(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );

  late AnimationController detailsController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void initState() {
    _updateItems();
    detailsController.addListener(() {
      setState(() {
        _detailsAnimateValue = detailsController.value;
      });
      debugPrint("Details controller value : ${detailsController.value}");
    });
    super.initState();
  }

  @override
  void dispose() {
    titleController.dispose();
    priceController.dispose();
    imageController.dispose();
    super.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Coffee Shop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          forceMaterialTransparency: true,
          toolbarHeight: toolbarHeight,
          leadingWidth: 65,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              DialogHelper.showToast("Back pressed");
            },
            iconSize: 25,
            color: Colors.black54,
            padding: const EdgeInsets.all(10),
            splashRadius: 32,
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: IconButton(
                color: Colors.black54,
                padding: const EdgeInsets.all(5),
                icon: SvgPicture.asset(
                  "assets/svg/cart.svg",
                  width: 22.0,
                  height: 22.0,
                  colorFilter:
                      const ColorFilter.mode(Colors.black54, BlendMode.srcIn),
                ),
                onPressed: () {
                  DialogHelper.showToast("Cart pressed");
                },
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(75.0),
            child: SizedBox(
              height: 75,
              child: Row(
                children: [
                  Expanded(
                    child: TextSlide(
                      controller: titleController,
                      items: titles,
                      width: double.infinity,
                      height: 75,
                      itemHeight: 75,
                      minScale: 0.3,
                      extraHorizontalPadding: 50,
                      builder: (index, item) {
                        return TitleItem(
                          item: item,
                        );
                      },
                    ),
                  ),
                  TextScroll(
                    pageController: priceController,
                    itemCount: prices.length,
                    width: 110,
                    height: 50,
                    builder: (BuildContext context, int index) {
                      final priceFormat = "\$${prices[index]}";
                      final pointIndex = priceFormat.indexOf(".");
                      final prefixPrice =
                          priceFormat.substring(0, pointIndex + 1);
                      final suffixPrice = priceFormat.substring(pointIndex + 1);
                      return Container(
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              prefixPrice,
                              style: const TextStyle(
                                  fontSize: 27, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 7),
                              child: Text(
                                suffixPrice,
                                style: const TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: IgnorePointer(
          ignoring: _detailsAnimateValue >= 0.99,
          child: Opacity(
            opacity: 1 - _detailsAnimateValue,
            child: FloatingActionButton(
              onPressed: () {
                DialogHelper.showToast("Fab pressed");
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(50.0),
              ),
              backgroundColor: Colors.white,
              child: const Icon(Icons.add),
            ),
          ),
        ),
        body: SafeArea(
          child: Container(
            color: Colors.white,
            height: double.infinity,
            child: Stack(
              key: _key,
              //alignment: Alignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 35),
                  child: Transform.translate(
                    offset: Offset(_itemOffsetX, 0),
                    child: ListImage(
                      controller: imageController,
                      items: images,
                      scrollSpeed: 0.5,
                      alignment: Alignment.bottomCenter,
                      onSelectedItemChanged: (index, direction) {
                        final product = products[index];
                        final priceIndex = prices.indexOf(product.price);
                        if (priceIndex >= 0) {
                          priceController.animateToPage(priceIndex,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.linear);
                        }
                        titleController.animateDirectionTo(
                            index: index, scrollDirection: direction);
                      },
                      builder: (int index, bool selected, ImageModel item) {
                        return Opacity(
                          opacity: _getDetailsOpacity(index, selected),
                          child: Transform.translate(
                            offset: _getDetailsOffset(index, selected),
                            child: ImageItem(
                              width: productWidth,
                              height: productHeight,
                              index: index,
                              selected: selected,
                              item: item,
                              parentKey: _key,
                              onClick: (Offset? offset) {
                                if (detailsController.isAnimating) return;
                                setState(() {
                                  _selectedProduct = products[index];
                                  detailsController.forward(from: 0);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Opacity(
                  opacity: _detailsAnimateValue >= 0.99 ? 1 : 0,
                  child: IgnorePointer(
                    ignoring: _detailsAnimateValue < 0.99,
                    child: ProductDetails(
                      controller: detailsController,
                      selectedProduct: _selectedProduct,
                      positionCallback: (offset) {
                        setState(() {
                          widgetPosition = Offset(-_itemOffsetX, -(offset.dy));
                          debugPrint("Details position : $offset");
                        });
                      },
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _updateItems() {
    products.asMap().forEach((index, data) {
      images.add(ImageModel(assets: data.imageAssets, placeholderAssets: ""));
      titles.add(
          ItemModel(title: data.title, desc: data.category.name, index: index));
      prices.add(data.price);
    });

    prices.sort();
  }

  double _getDetailsOpacity(int index, bool selected) {
    if (selected) {
      return 1;
    }
    return (1 - _detailsAnimateValue);
  }

  Offset _getDetailsOffset(int index, bool selected) {
    if (selected) {
      return (widgetPosition ?? const Offset(0, 0)) *
          _detailsAnimateValue; // 20, -229
    }
    return Offset(300 * _detailsAnimateValue, 0);
  }
}
