import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/shop_data.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final List<CartItem> _cartItems = [];

  ShopData? _shopData;
  bool _isLoading = true;
  String? _errorMessage;

  String _selectedCategory = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await _apiService.fetchShopData();
      setState(() {
        _shopData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _showSettingsDialog() {
    final controller = TextEditingController(text: _apiService.baseUrl);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Backend Server Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Backend API URL ကို ပြောင်းလဲရန်:\n'
              '• Public Server: https://your-domain.com\n'
              '• Local Test (Emulator): http://10.0.2.2:3000',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Base URL',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              _apiService.setBaseUrl(controller.text.trim());
              Navigator.pop(ctx);
              _loadData();
            },
            child: const Text('Save & Reconnect'),
          ),
        ],
      ),
    );
  }

  List<Product> get _filteredProducts {
    if (_shopData == null) return [];
    return _shopData!.products.where((p) {
      final matchCat = _selectedCategory == 'all' || p.category.toLowerCase() == _selectedCategory.toLowerCase();
      final matchSearch = _searchQuery.isEmpty ||
          p.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          p.nameMm.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchCat && matchSearch;
    }).toList();
  }

  int get _cartCount => _cartItems.fold(0, (sum, i) => sum + i.quantity);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F2),
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'PontPont Handbag',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 0.5),
            ),
            Text(
              'မန္တလေးမြို့ အထည်ကြီး လက်ကိုင်အိတ် boutique',
              style: TextStyle(fontSize: 11, color: Color(0xFFFDE68A)),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF1C1917),
        foregroundColor: const Color(0xFFFBBF24),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Server Settings',
            onPressed: _showSettingsDialog,
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_bag_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CartScreen(
                        cartItems: _cartItems,
                        onCartUpdated: () => setState(() {}),
                        onClearCart: () => setState(() => _cartItems.clear()),
                      ),
                    ),
                  ).then((_) => setState(() {}));
                },
              ),
              if (_cartCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                    child: Text(
                      '$_cartCount',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFFB45309)),
                  SizedBox(height: 16),
                  Text('ပစ္စည်းစာရင်းများ ရယူနေပါသည်...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 64, color: Colors.brown),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(height: 1.4),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _loadData,
                          icon: const Icon(Icons.refresh),
                          label: const Text('ထပ်မံကြိုးစားမည် (Retry)'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1C1917),
                            foregroundColor: const Color(0xFFFBBF24),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _showSettingsDialog,
                          child: const Text('Change Server IP / URL'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  color: const Color(0xFFB45309),
                  child: CustomScrollView(
                    slivers: [
                      // Search Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                          child: TextField(
                            onChanged: (val) => setState(() => _searchQuery = val),
                            decoration: InputDecoration(
                              hintText: 'အိတ်အမည် သို့မဟုတ် စတိုင် ရှာရန်...',
                              prefixIcon: const Icon(Icons.search, color: Colors.brown),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Announcements
                      if (_shopData != null && _shopData!.announcements.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFDE68A)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.campaign, color: Color(0xFFB45309), size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _shopData!.announcements.first,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Color(0xFF78350F),
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Category Pills
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 50,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4),
                                child: ChoiceChip(
                                  label: const Text('အားလုံး (All)'),
                                  selected: _selectedCategory == 'all',
                                  selectedColor: const Color(0xFF1C1917),
                                  labelStyle: TextStyle(
                                    color: _selectedCategory == 'all' ? const Color(0xFFFBBF24) : Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  onSelected: (_) => setState(() => _selectedCategory = 'all'),
                                ),
                              ),
                              ...?_shopData?.categories.map((cat) {
                                final isSelected = _selectedCategory.toLowerCase() == cat.id.toLowerCase();
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: ChoiceChip(
                                    avatar: Text(cat.icon),
                                    label: Text(cat.labelMm.isNotEmpty ? cat.labelMm : cat.labelEn),
                                    selected: isSelected,
                                    selectedColor: const Color(0xFF1C1917),
                                    labelStyle: TextStyle(
                                      color: isSelected ? const Color(0xFFFBBF24) : Colors.black87,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    onSelected: (_) => setState(() => _selectedCategory = cat.id),
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                      ),

                      // Product Grid
                      SliverPadding(
                        padding: const EdgeInsets.all(16),
                        sliver: _filteredProducts.isEmpty
                            ? const SliverToBoxAdapter(
                                child: Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(32.0),
                                    child: Text('ရှာဖွေမှုနှင့် ကိုက်ညီသော အိတ်မရှိပါ'),
                                  ),
                                ),
                              )
                            : SliverGrid(
                                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  childAspectRatio: 0.68,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final p = _filteredProducts[index];
                                    return GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => ProductDetailScreen(
                                              product: p,
                                              onAddToCart: (item) {
                                                setState(() {
                                                  final existingIdx = _cartItems.indexWhere(
                                                    (ci) =>
                                                        ci.product.id == item.product.id &&
                                                        ci.selectedColor.name == item.selectedColor.name,
                                                  );
                                                  if (existingIdx >= 0) {
                                                    _cartItems[existingIdx].quantity += item.quantity;
                                                  } else {
                                                    _cartItems.add(item);
                                                  }
                                                });
                                              },
                                            ),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(12),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.04),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            // Image + Badge
                                            Expanded(
                                              child: Stack(
                                                children: [
                                                  ClipRRect(
                                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                                                    child: Container(
                                                      width: double.infinity,
                                                      height: double.infinity,
                                                      color: Colors.grey.shade100,
                                                      child: Image.network(
                                                        p.image,
                                                        fit: BoxFit.cover,
                                                        errorBuilder: (_, __, ___) => const Icon(
                                                          Icons.shopping_bag_outlined,
                                                          color: Colors.grey,
                                                          size: 40,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  if (p.badge != null)
                                                    Positioned(
                                                      top: 8,
                                                      left: 8,
                                                      child: Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                                        decoration: BoxDecoration(
                                                          color: const Color(0xFFD97706),
                                                          borderRadius: BorderRadius.circular(4),
                                                        ),
                                                        child: Text(
                                                          p.badge!,
                                                          style: const TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 9,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),

                                            // Product Details
                                            Padding(
                                              padding: const EdgeInsets.all(10.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    p.nameMm,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    p.nameEn,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Row(
                                                    children: [
                                                      Text(
                                                        '${p.price} Ks',
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.bold,
                                                          color: Color(0xFFB45309),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                      const Spacer(),
                                                      const Icon(Icons.star, size: 14, color: Colors.amber),
                                                      Text(
                                                        '${p.rating}',
                                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                  childCount: _filteredProducts.length,
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
