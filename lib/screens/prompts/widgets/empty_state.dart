import 'package:flutter/material.dart';

class EmptyStateView extends StatelessWidget {
  final bool isFavoritesView;

  const EmptyStateView({
    Key? key,
    required this.isFavoritesView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            isFavoritesView
                ? 'assets/images/empty_favorites.png'
                : 'assets/images/search_prompt.png',
            height: 150,
            width: 150,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) => Icon(
              isFavoritesView ? Icons.favorite_border : Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isFavoritesView
                ? 'Bạn chưa có prompt yêu thích nào'
                : 'Không tìm thấy prompt nào',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            isFavoritesView
                ? 'Hãy thêm prompt yêu thích để xem ở đây'
                : 'Thử tìm kiếm với từ khóa khác',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
