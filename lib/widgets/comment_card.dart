import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class CommentCard extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String comment;
  final int? starCount;

  const CommentCard({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.comment,
    this.starCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.greyCard,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage: NetworkImage(avatarUrl),
              ),
              const SizedBox(width: 10),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment, style: const TextStyle(fontSize: 13)),
          if (starCount != null) ...[
            const SizedBox(height: 8),
            Row(
              children: List.generate(
                starCount!,
                    (index) => const Icon(Icons.star, size: 18, color: Colors.amber),
              ),
            ),
          ]
        ],
      ),
    );
  }
}
