import 'package:flutter/material.dart';
import '../models/shop_data.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final VoidCallback onCartUpdated;
  final VoidCallback onClearCart;

  const CartScreen({
    super.key,
    required this.cartItems,
    required this.onCartUpdated,
    required this.onClearCart,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _trxController = TextEditingController();

  String _selectedCity = 'Mandalay (မန္တလေး - မြို့တွင်း)';
  int _deliveryFee = 2000;
  String _paymentMethod = 'COD';
  bool _isSubmitting = false;

  final List<Map<String, dynamic>> _cities = [
    {'name': 'Mandalay (မန္တလေး - မြို့တွင်း)', 'fee': 2000},
    {'name': 'Yangon (ရန်ကုန် - မြို့တွင်း)', 'fee': 3000},
    {'name': 'Naypyidaw (နေပြည်တော်)', 'fee': 3500},
    {'name': 'Other Cities (နယ်မြို့များ - ကားဂိတ်ပို့)', 'fee': 4000},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    _trxController.dispose();
    super.dispose();
  }

  int get _subtotal {
    return widget.cartItems.fold(0, (sum, item) => sum + item.totalPrice);
  }

  int get _effectiveDeliveryFee {
    // Free delivery if subtotal >= 100,000 Ks
    return _subtotal >= 100000 ? 0 : _deliveryFee;
  }

  int get _grandTotal => _subtotal + _effectiveDeliveryFee;

  void _submitOrder() async {
    if (widget.cartItems.isEmpty) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final res = await ApiService().submitOrder(
        customerName: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        city: _selectedCity,
        address: _addressController.text.trim(),
        paymentMethod: _paymentMethod,
        transactionRef: _trxController.text.trim().isNotEmpty ? _trxController.text.trim() : null,
        note: _noteController.text.trim().isNotEmpty ? _noteController.text.trim() : null,
        cartItems: widget.cartItems,
      );

      final orderId = res['order']?['id'] ?? 'PP-2026-SUCCESS';

      if (!mounted) return;
      widget.onClearCart();

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.check_circle, color: Colors.green, size: 50),
          title: const Text('အော်ဒါတင်ခြင်း အောင်မြင်ပါသည်'),
          content: Text(
            'ကျေးဇူးတင်ပါသည်ခင်ဗျာ။\n\n'
            'Order ID: $orderId\n'
            'ကျသင့်ငွေ: ${_grandTotal.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")} Ks\n\n'
            'ဆိုင်မှ မကြာမီ လူကြီးမင်းထံ ဖုန်းဖြင့် ဆက်သွယ် အတည်ပြုပေးပါမည်။',
            style: const TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context); // back to home
              },
              child: const Text('နားလည်ပါပြီ', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('အော်ဒါတင်ရန် မအောင်မြင်ပါ: ${e.toString()}'),
          backgroundColor: Colors.red.shade700,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ဝယ်ယူမည့် ခြင်းတောင်း (Cart)'),
        backgroundColor: const Color(0xFF1C1917),
        foregroundColor: const Color(0xFFFBBF24),
      ),
      body: widget.cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  const Text('ခြင်းတောင်းထဲတွင် မည်သည့်ပစ္စည်းမှ မရှိသေးပါ', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1C1917),
                      foregroundColor: const Color(0xFFFBBF24),
                    ),
                    child: const Text('စျေးဝယ်ထွက်ရန်'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cart Items List
                    const Text('ရွေးချယ်ထားသော ပစ္စည်းများ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.cartItems.length,
                      separatorBuilder: (_, __) => const Divider(height: 16),
                      itemBuilder: (context, index) {
                        final item = widget.cartItems[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: 60,
                                height: 60,
                                color: Colors.grey.shade200,
                                child: Image.network(
                                  item.product.image,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(Icons.image, color: Colors.grey),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.product.nameMm, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    'အရောင်: ${item.selectedColor.name} | ${item.unitPrice} Ks',
                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                                  ),
                                ],
                              ),
                            ),
                            // Quantity Controls
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () {
                                    setState(() {
                                      if (item.quantity > 1) {
                                        item.quantity--;
                                      } else {
                                        widget.cartItems.removeAt(index);
                                      }
                                      widget.onCartUpdated();
                                    });
                                  },
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () {
                                    if (item.quantity < item.product.stock) {
                                      setState(() {
                                        item.quantity++;
                                        widget.onCartUpdated();
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),

                    const Divider(height: 32),

                    // Customer Checkout Details
                    const Text('ပို့ဆောင်ရမည့် လိပ်စာနှင့် အချက်အလက်များ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'အမည် (Name)*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'အမည် ဖြည့်သွင်းပေးပါ' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'ဖုန်းနံပါတ် (Phone)*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'ဖုန်းနံပါတ် ဖြည့်သွင်းပေးပါ' : null,
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCity,
                      decoration: const InputDecoration(
                        labelText: 'ပို့ဆောင်မည့် မြို့နယ်*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_city),
                      ),
                      items: _cities.map((c) {
                        return DropdownMenuItem<String>(
                          value: c['name'] as String,
                          child: Text('${c['name']} (+${c['fee']} Ks)'),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _selectedCity = val;
                            final found = _cities.firstWhere((c) => c['name'] == val);
                            _deliveryFee = found['fee'] as int;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'အသေးစိတ် လိပ်စာ / အိမ်အမှတ် / လမ်းအမည်*',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.home_outlined),
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'လိပ်စာ ဖြည့်သွင်းပေးပါ' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _noteController,
                      decoration: const InputDecoration(
                        labelText: 'ဆိုင်သို့ မှာကြားလိုသည့် အချက် (Optional)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.note_alt_outlined),
                      ),
                    ),

                    const Divider(height: 32),

                    // Payment Method Selection
                    const Text('ငွေချေမှု စနစ် ရွေးချယ်ရန်', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    RadioListTile<String>(
                      value: 'COD',
                      groupValue: _paymentMethod,
                      title: const Text('Cash on Delivery (ပစ္စည်းရောက်မှ ငွေချေ)'),
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),
                    RadioListTile<String>(
                      value: 'KPay',
                      groupValue: _paymentMethod,
                      title: const Text('KBZPay (09-789456123 - PontPont)'),
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),
                    RadioListTile<String>(
                      value: 'WavePay',
                      groupValue: _paymentMethod,
                      title: const Text('WavePay (09-789456123 - PontPont)'),
                      onChanged: (v) => setState(() => _paymentMethod = v!),
                    ),

                    if (_paymentMethod != 'COD') ...[
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _trxController,
                        decoration: InputDecoration(
                          labelText: '$_paymentMethod Transaction နောက်ဆုံး ၆ လုံး (Optional)',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.receipt_long),
                        ),
                      ),
                    ],

                    const Divider(height: 32),

                    // Price Breakdown
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFAF7F2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE7E5E4)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ပစ္စည်းစုစုပေါင်း တန်ဖိုး:'),
                              Text('$_subtotal Ks', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ပို့ဆောင်ခ (Delivery Fee):'),
                              Text(
                                _effectiveDeliveryFee == 0 ? 'FREE (အခမဲ့)' : '$_effectiveDeliveryFee Ks',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: _effectiveDeliveryFee == 0 ? Colors.green : Colors.black87,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('ကျသင့်ငွေ စုစုပေါင်း:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(
                                '$_grandTotal Ks',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFFB45309),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Checkout Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _submitOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1C1917),
                          foregroundColor: const Color(0xFFFBBF24),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFFBBF24)),
                              )
                            : const Text('အော်ဒါ အတည်ပြု တင်မည် (Place Order)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }
}
