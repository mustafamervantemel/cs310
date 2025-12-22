import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/app_colors.dart';
import '../providers/cart_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/firestore_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;

  Future<void> _completePurchase() async {
    final cartProvider = context.read<CartProvider>();
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first'), backgroundColor: AppColors.error),
      );
      return;
    }

    if (cartProvider.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      // Purchase each note in the cart
      for (final note in cartProvider.cartItems) {
        await FirestoreService().purchaseNote(noteId: note.id, userId: userId);
      }

      // Clear the cart after successful purchase
      cartProvider.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Purchase completed! Notes are now available.'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = context.watch<CartProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    
    final bgColor = isDark ? AppColors.darkBackground : AppColors.navy;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context), 
                    icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32),
                  ),
                  const Spacer(),
                  const Text('Shopping Cart', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Stack(
                    children: [
                      const Icon(Icons.shopping_cart, color: Colors.white),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(color: AppColors.coral, shape: BoxShape.circle),
                            child: Text(
                              '${cartProvider.itemCount}',
                              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Cart Items
            Expanded(
              child: cartProvider.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.white.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('Your cart is empty', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 18)),
                          const SizedBox(height: 8),
                          Text('Add notes to your cart to purchase', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14)),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false),
                            icon: const Icon(Icons.search),
                            label: const Text('Browse Notes'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: cartProvider.cartItems.length,
                      itemBuilder: (context, index) {
                        final note = cartProvider.cartItems[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 60, 
                                height: 60, 
                                decoration: BoxDecoration(
                                  color: AppColors.categoryBlue, 
                                  borderRadius: BorderRadius.circular(8), 
                                  border: Border.all(color: AppColors.star, width: 2),
                                ), 
                                child: const Icon(Icons.description, color: AppColors.navy),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${note.courseCode} - ${note.title}', 
                                      style: const TextStyle(fontWeight: FontWeight.w600),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'by ${note.createdByName ?? "Unknown"}',
                                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                '₺${note.price.toStringAsFixed(0)}', 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.coral),
                              ),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () => cartProvider.removeFromCart(note.id), 
                                child: Container(
                                  padding: const EdgeInsets.all(4), 
                                  decoration: BoxDecoration(
                                    color: AppColors.coral.withOpacity(0.2), 
                                    shape: BoxShape.circle,
                                  ), 
                                  child: const Icon(Icons.close, color: AppColors.coral, size: 18),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),

            // Payment Details
            if (cartProvider.cartItems.isNotEmpty)
              Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white, 
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Payment Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 16),
                    Row(children: [
                      const Text('Sub Total'), 
                      const Spacer(), 
                      Text('₺${cartProvider.subtotal.toStringAsFixed(0)}'),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Text('Items'), 
                      const Spacer(), 
                      Text('${cartProvider.itemCount} note(s)'),
                    ]),
                    const Divider(height: 24),
                    Row(children: [
                      const Text('Total', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), 
                      const Spacer(), 
                      Text(
                        '₺${cartProvider.total.toStringAsFixed(0)}', 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.coral),
                      ),
                    ]),
                  ],
                ),
              ),

            // Checkout Button
            if (cartProvider.cartItems.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _completePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.success, 
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24, 
                            height: 24, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'COMPLETE PURCHASE', 
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
