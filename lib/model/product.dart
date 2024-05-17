class Product {
  final int id;
  final String title;
  final Category category;
  final String? imageUrl;
  final String imageAssets;
  final double price;

  Product({
    required this.id,
    required this.title,
    required this.category,
    required this.imageAssets,
    required this.price,
    this.imageUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        id: json["id"] as int,
        title: json["title"] as String,
        category: Category.fromJson(json["category"] as Map<String, dynamic>),
        imageUrl: json["imageUrl"] as String,
        imageAssets: json["imageAssets"] as String,
        price: json["price"] as double,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "category": category.toJson(),
        "imageUrl": imageUrl,
        "imageAssets": imageAssets,
        "price": price,
      };
}

class Category {
  final int id;
  final String name;

  static Category burger = Category(id: 0, name: "Burger");

  Category({
    required this.id,
    required this.name,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"] as int,
        name: json["name"] as String,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}
