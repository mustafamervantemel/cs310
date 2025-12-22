import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../models/note_model.dart';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/cart_provider.dart';

class NoteDetailScreen extends StatefulWidget {
  const NoteDetailScreen({super.key});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  bool _hasPurchased = false;
  bool _checkingPurchase = true;
  bool _isDownloading = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkPurchaseStatus();
  }

  Future<void> _checkPurchaseStatus() async {
    final note = ModalRoute.of(context)?.settings.arguments as NoteModel?;
    final authProvider = context.read<AuthProvider>();
    final userId = authProvider.userId;
    
    if (note != null && userId != null) {
      final hasPurchased = await FirestoreService().hasUserPurchased(note.id, userId);
      if (mounted) {
        setState(() {
          _hasPurchased = hasPurchased;
          _checkingPurchase = false;
        });
      }
    } else {
      setState(() {
        _checkingPurchase = false;
      });
    }
  }

  Future<void> _downloadFile(NoteModel note) async {
    if (note.imageUrl == null || note.imageUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No file available for download'), backgroundColor: AppColors.error),
      );
      return;
    }

    setState(() {
      _isDownloading = true;
    });

    try {
      final uri = Uri.parse(note.imageUrl!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Opening file...'), backgroundColor: AppColors.success),
          );
        }
      } else {
        throw Exception('Could not open file');
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
          _isDownloading = false;
        });
      }
    }
  }

  void _addToCart(NoteModel note) {
    final cartProvider = context.read<CartProvider>();
    cartProvider.addToCart(note);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${note.title} added to cart!'),
        backgroundColor: AppColors.success,
        action: SnackBarAction(label: 'VIEW CART', textColor: Colors.white, onPressed: () => Navigator.pushNamed(context, '/checkout')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final note = ModalRoute.of(context)?.settings.arguments as NoteModel?;
    final themeProvider = context.watch<ThemeProvider>();
    final cartProvider = context.watch<CartProvider>();
    final isDark = themeProvider.isDarkMode;
    
    if (note == null) {
      return Scaffold(body: Center(child: Text('Note not found')));
    }

    final isInCart = cartProvider.isInCart(note.id);
    final bgColor = isDark ? AppColors.darkBackground : AppColors.background;
    final cardColor = isDark ? Colors.grey[850] : Colors.white;
    final textColor = isDark ? Colors.white : AppColors.textPrimary;
    final subtextColor = isDark ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: bgColor,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 16),
            color: AppColors.navy,
            child: Row(
              children: [
                IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.chevron_left, color: Colors.white, size: 32)),
                Expanded(child: Text('${note.courseCode}/${note.title}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),

          Expanded(
            child: StreamBuilder<NoteModel?>(
              stream: FirestoreService().getNoteStream(note.id),
              initialData: note,
              builder: (context, snapshot) {
                final currentNote = snapshot.data ?? note;
                
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Seller Info
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(context, '/taProfile', arguments: {'userId': currentNote.createdBy, 'userName': currentNote.createdByName ?? 'Unknown'}),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(color: AppColors.navy, borderRadius: BorderRadius.circular(20)),
                              child: const Text('Check Profile', style: TextStyle(color: Colors.white, fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(currentNote.createdByName ?? currentNote.createdBy.substring(0, 8), style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          const Spacer(),
                          CircleAvatar(radius: 20, backgroundColor: isDark ? Colors.grey[700] : Colors.grey, child: const Icon(Icons.person, color: Colors.white)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Rating & Sales
                      Row(
                        children: [
                          Row(children: List.generate(5, (i) => Icon(Icons.star, color: i < 4 ? AppColors.star : Colors.grey[300], size: 20))),
                          const SizedBox(width: 8),
                          Text('4.1/5', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                          const SizedBox(width: 24),
                          Icon(Icons.download, size: 20, color: textColor),
                          const SizedBox(width: 4),
                          Text('${currentNote.totalSells} Total Sells', style: TextStyle(color: subtextColor)),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Description
                      Text(currentNote.description, style: TextStyle(color: subtextColor, height: 1.5)),

                      const SizedBox(height: 24),

                      // Download Section
                      GestureDetector(
                        onTap: _hasPurchased && !_isDownloading ? () => _downloadFile(currentNote) : null,
                        child: Container(
                          width: double.infinity,
                          height: 200,
                          decoration: BoxDecoration(
                            color: isDark ? Colors.grey[800] : AppColors.categoryBlue,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _hasPurchased ? Icons.download : Icons.lock_outline, 
                                  size: 48, 
                                  color: isDark ? Colors.white70 : AppColors.navy,
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: _hasPurchased 
                                        ? AppColors.success.withOpacity(0.9)
                                        : (isDark ? Colors.grey[700]!.withOpacity(0.8) : Colors.white.withOpacity(0.8)), 
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  child: _isDownloading
                                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                      : Text(
                                          _checkingPurchase 
                                              ? 'Checking...'
                                              : (_hasPurchased 
                                                  ? 'Tap to Download Note' 
                                                  : 'Purchase to Access'),
                                          style: TextStyle(
                                            color: _hasPurchased ? Colors.white : subtextColor,
                                            fontWeight: _hasPurchased ? FontWeight.bold : FontWeight.normal,
                                          ),
                                        ),
                                ),
                                if (currentNote.fileName != null && currentNote.fileName!.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(currentNote.fileName!, style: TextStyle(color: subtextColor, fontSize: 12)),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Status/Actions
                      if (_hasPurchased)
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.success),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle, color: AppColors.success, size: 20),
                                const SizedBox(width: 8),
                                Text('Purchased', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                      else if (isInCart)
                        Center(
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.accent.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.accent),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.shopping_cart, color: AppColors.accent, size: 20),
                                    const SizedBox(width: 8),
                                    Text('In Cart', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              TextButton.icon(onPressed: () => Navigator.pushNamed(context, '/checkout'), icon: const Icon(Icons.arrow_forward), label: const Text('Go to Checkout')),
                            ],
                          ),
                        )
                      else if (!_checkingPurchase)
                        Center(
                          child: ElevatedButton.icon(
                            onPressed: () => _addToCart(currentNote),
                            icon: const Icon(Icons.add_shopping_cart),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.coral, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                            label: Text('Add to Cart - ₺${currentNote.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Comments
                      Text('Comments:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      const SizedBox(height: 16),
                      _buildComment('Selin D.', 'Lots of examples, clean structure and advanced reasoning.', 5, isDark, cardColor!, textColor, subtextColor!),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComment(String name, String text, int rating, bool isDark, Color cardColor, Color textColor, Color subtextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [CircleAvatar(radius: 20, backgroundColor: isDark ? Colors.grey[700] : null, child: const Icon(Icons.person)), const SizedBox(width: 12), Text(name, style: TextStyle(fontWeight: FontWeight.bold, color: textColor))]),
          const SizedBox(height: 12),
          Text(text, style: TextStyle(color: subtextColor)),
          const SizedBox(height: 12),
          Row(children: List.generate(5, (i) => Icon(Icons.star, color: i < rating ? AppColors.star : Colors.grey[300], size: 24))),
        ],
      ),
    );
  }
}
