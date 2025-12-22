/// FILE: lib/providers/cart_provider.dart
/// Shopping cart state management using Provider pattern
/// Manages cart items before purchase

import 'package:flutter/material.dart';
import '../models/note_model.dart';

class CartProvider extends ChangeNotifier {
  final List<NoteModel> _cartItems = [];

  // Getters
  List<NoteModel> get cartItems => List.unmodifiable(_cartItems);
  int get itemCount => _cartItems.length;
  bool get isEmpty => _cartItems.isEmpty;
  
  double get subtotal => _cartItems.fold(0, (sum, note) => sum + note.price);
  double get deliveryFee => _cartItems.isNotEmpty ? 0.0 : 0.0; // Free delivery
  double get total => subtotal + deliveryFee;

  /// Check if a note is already in cart
  bool isInCart(String noteId) {
    return _cartItems.any((note) => note.id == noteId);
  }

  /// Add a note to cart
  void addToCart(NoteModel note) {
    if (!isInCart(note.id)) {
      _cartItems.add(note);
      notifyListeners();
    }
  }

  /// Remove a note from cart
  void removeFromCart(String noteId) {
    _cartItems.removeWhere((note) => note.id == noteId);
    notifyListeners();
  }

  /// Clear all items from cart
  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }

  /// Get all note IDs in cart (for batch purchase)
  List<String> get noteIds => _cartItems.map((note) => note.id).toList();
}
