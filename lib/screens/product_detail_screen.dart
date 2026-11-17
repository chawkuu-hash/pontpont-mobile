import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/shop_data.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final Function(CartItem) onAddToCart;

  const ProductDetailScreen({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late ProductColor _selectedColor;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.product.colors.isNotEmpty
        ? widget.product.colors.first
        : ProductColor(name: 'Default', hex: '#8B4513');
  }

  Color _parseHex(String hexString) {
    try {
      final buffer = StringBuffer();
      if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
      buffer.write(hexString.replaceFirst('#', ''));
      return Color(int.parse(buffer.toString(), radix: 16));
    } catch (_) {
      return Colors.brown;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final isWholesaleApplied = _quantity >= 5 && p.wholesalePrice != null;
    final currentUnitPrice = isWholesaleApplied ? p.wholesalePrice! : p.price;

    return Scaffold(
      appBar: AppBar(
        title: Text(p.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF1C1917),
        foregroundColor: const Color(0xFFFBBF24),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Hero Image
            Stack(
              children: [
                Container(
                  height: 320,
                  width: double.infinity,
                  color: const Color(0xFFF5F3EF),
                  child: Image.network(
                    p.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                      ),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return const Center(child: CircularProgressIndicator(color: Color(0xFFD97706)));
                    },
                  ),
                ),
                if (p.badge != null)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                      ),
                      child: Text(
                        p.badge!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Names
                  Text(
                    p.nameMm,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, height: 1.3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    p.nameEn,
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 12),

                  // Rating and Reviews
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '${p.rating} (${p.reviewsCount} reviews)',
                        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: p.stock > 0 ? Colors.green.shade50 : Colors.red.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: p.stock > 0 ? Colors.green.shade300 : Colors.red.shade300,
                          ),
                        ),
                        child: Text(
                          p.stock > 0 ? 'လက်ကျန် ${p.stock} ခု' : 'ပစ္စည်းကုန်သွားပါပြီ',
                          style: TextStyle(
                            color: p.stock > 0 ? Colors.green.shade800 : Colors.red.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),

                  // Price Section
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${currentUnitPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} Ks',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFB45309),
                        ),
                      ),
                      if (p.originalPrice != null && p.originalPrice! > p.price) ...[
                        const SizedBox(width: 10),
                        Text(
                          '${p.originalPrice} Ks',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (p.wholesalePrice != null && p.wholesalePrice! > 0) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.loyalty, size: 16, color: Color(0xFFD97706)),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'လက်ကားဈေး: ၅ ခုနှင့်အထက် ဝယ်ယူပါက ၁ ခုလျှင် ${p.wholesalePrice} Ks ဖြင့် ရပါမည်။',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF92400E),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),

                  // Color Selection
                  const Text('အရောင်ရွေးချယ်ရန်:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: p.colors.map((c) {
                      final isSelected = _selectedColor.name == c.name;
                      return ChoiceChip(
                        avatar: CircleAvatar(
                          backgroundColor: _parseHex(c.hex),
                          radius: 8,
                        ),
                        label: Text(c.name),
                        selected: isSelected,
                        selectedColor: const Color(0xFFFDE68A),
                        onSelected: (val) {
                          if (val) setState(() => _selectedColor = c);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Quantity Selector
                  Row(
                    children: [
                      const Text('အရေအတွက်:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 18),
                              onPressed: _quantity > 1 ? () => setState(() => _quantity--) : null,
                            ),
                            Text('$_quantity', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add, size: 18),
                              onPressed: _quantity < p.stock ? () => setState(() => _quantity++) : null,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 32),

                  // Description
                  const Text('အသေးစိတ် အချက်အလက်များ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(p.descriptionMm, style: const TextStyle(height: 1.5, fontSize: 14)),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.texture, color: Colors.brown),
                    title: const Text('အသုံးပြုထားသော ပစ္စည်း (Material)'),
                    subtitle: Text(p.material),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.straighten, color: Colors.brown),
                    title: const Text('အရွယ်အစား (Dimensions)'),
                    subtitle: Text(p.dimensions),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -4)),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: p.stock > 0
                ? () {
                    widget.onAddToCart(
                      CartItem(
                        product: p,
                        selectedColor: _selectedColor,
                        quantity: _quantity,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${p.nameMm} (${_selectedColor.name}) ကို ခြင်းတောင်းထဲ ထည့်ပြီးပါပြီ။'),
                        backgroundColor: const Color(0xFF1C1917),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                    Navigator.pop(context);
                  }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1C1917),
              foregroundColor: const Color(0xFFFBBF24),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.shopping_bag_outlined),
                const SizedBox(width: 8),
                Text(
                  p.stock > 0 ? 'ဝယ်ယူမည့် ခြင်းတောင်းထဲထည့်မည်' : 'ပစ္စည်းကုန်နေပါသည်',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
