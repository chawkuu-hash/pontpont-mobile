import 'product.dart';

class CategoryItem {
  final String id;
  final String labelEn;
  final String labelMm;
  final String icon;

  CategoryItem({
    required this.id,
    required this.labelEn,
    required this.labelMm,
    required this.icon,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id']?.toString() ?? '',
      labelEn: json['labelEn']?.toString() ?? '',
      labelMm: json['labelMm']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '👜',
    );
  }
}

class ShopData {
  final List<Product> products;
  final List<CategoryItem> categories;
  final List<String> announcements;
  final String theme;

  ShopData({
    required this.products,
    required this.categories,
    required this.announcements,
    required this.theme,
  });

  factory ShopData.fromJson(Map<String, dynamic> json) {
    final rawProducts = (json['products'] as List? ?? []);
    final rawCategories = (json['categories'] as List? ?? []);
    final rawAnnouncements = (json['announcements'] as List? ?? []);

    return ShopData(
      products: rawProducts
          .map((p) => Product.fromJson(p as Map<String, dynamic>))
          .toList(),
      categories: rawCategories
          .map((c) => CategoryItem.fromJson(c as Map<String, dynamic>))
          .toList(),
      announcements: rawAnnouncements.map((a) {
        if (a is Map) {
          return a['textMm']?.toString() ?? a['textEn']?.toString() ?? '';
        }
        return a.toString();
      }).where((s) => s.isNotEmpty).toList(),
      theme: json['theme']?.toString() ?? 'luxury-gold',
    );
  }
}

class CartItem {
  final Product product;
  final ProductColor selectedColor;
  int quantity;

  CartItem({
    required this.product,
    required this.selectedColor,
    this.quantity = 1,
  });

  int get unitPrice {
    if (quantity >= 5 && product.wholesalePrice != null && product.wholesalePrice! > 0) {
      return product.wholesalePrice!;
    }
    return product.price;
  }

  int get totalPrice => unitPrice * quantity;
}
