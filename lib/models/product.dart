class ProductColor {
  final String name;
  final String hex;

  ProductColor({required this.name, required this.hex});

  factory ProductColor.fromJson(Map<String, dynamic> json) {
    return ProductColor(
      name: json['name'] as String? ?? '',
      hex: json['hex'] as String? ?? '#8B4513',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'hex': hex};
}

class Product {
  final String id;
  final String nameEn;
  final String nameMm;
  final String category;
  final String categoryMm;
  final int price;
  final int? originalPrice;
  final int? wholesalePrice;
  final String image;
  final List<ProductColor> colors;
  final String? badge;
  final double rating;
  final int reviewsCount;
  final int stock;
  final String material;
  final String dimensions;
  final String descriptionEn;
  final String descriptionMm;

  Product({
    required this.id,
    required this.nameEn,
    required this.nameMm,
    required this.category,
    required this.categoryMm,
    required this.price,
    this.originalPrice,
    this.wholesalePrice,
    required this.image,
    required this.colors,
    this.badge,
    required this.rating,
    required this.reviewsCount,
    required this.stock,
    required this.material,
    required this.dimensions,
    required this.descriptionEn,
    required this.descriptionMm,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawColors = json['colors'] as List? ?? [];
    final colorList = rawColors.map((c) {
      if (c is Map<String, dynamic>) {
        return ProductColor.fromJson(c);
      }
      return ProductColor(name: c.toString(), hex: '#78350F');
    }).toList();

    return Product(
      id: json['id']?.toString() ?? '',
      nameEn: json['nameEn']?.toString() ?? '',
      nameMm: json['nameMm']?.toString() ?? '',
      category: json['category']?.toString() ?? 'all',
      categoryMm: json['categoryMm']?.toString() ?? '',
      price: (json['price'] as num?)?.toInt() ?? 0,
      originalPrice: (json['originalPrice'] as num?)?.toInt(),
      wholesalePrice: (json['wholesalePrice'] as num?)?.toInt(),
      image: json['image']?.toString() ?? '',
      colors: colorList.isNotEmpty
          ? colorList
          : [ProductColor(name: 'Standard', hex: '#A16207')],
      badge: json['badge']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      reviewsCount: (json['reviewsCount'] as num?)?.toInt() ?? 0,
      stock: (json['stock'] as num?)?.toInt() ?? 0,
      material: json['material']?.toString() ?? 'High Quality Leather',
      dimensions: json['dimensions']?.toString() ?? 'Standard Size',
      descriptionEn: json['descriptionEn']?.toString() ?? '',
      descriptionMm: json['descriptionMm']?.toString() ?? '',
    );
  }
}
