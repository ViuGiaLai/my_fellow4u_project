// SỬ DỤNG TẠI: 
//   - home_screen.dart (CustomTripCard, CustomLoadingCard, CustomEmptyCard)
//   - my_trips_app.dart (CustomTripCard, CustomLoadingCard, CustomEmptyCard)
//   - trip_info_screen.dart (CustomTripCard)
//   - my_photos_screen.dart (CustomEmptyCard)
import 'package:flutter/material.dart';

/// Custom card cho Trip/Tour display
class CustomTripCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final String? price;
  final String? rating;
  final String? duration;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;
  final bool isFavorite;
  final double height;
  final double borderRadius;

  const CustomTripCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.price,
    this.rating,
    this.duration,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
    this.height = 200,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(borderRadius)),
              child: Stack(
                children: [
                  _buildImage(),
                  // Favorite button
                  if (onFavorite != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onFavorite,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  // Rating badge
                  if (rating != null)
                    Positioned(
                      bottom: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              rating!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Content section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // Subtitle + Duration
                    if (subtitle != null || duration != null)
                      Row(
                        children: [
                          if (subtitle != null)
                            Expanded(
                              child: Text(
                                subtitle!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          if (duration != null) ...[
                            const SizedBox(width: 8),
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              duration!,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    // Price
                    if (price != null)
                      Text(
                        price!,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00CEA6),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      return Container(
        height: height * 0.6,
        color: Colors.grey.shade200,
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey.shade400,
        ),
      );
    }

    return Image.network(
      imageUrl!,
      height: height * 0.6,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: height * 0.6,
        color: Colors.grey.shade200,
        child: Icon(
          Icons.broken_image,
          size: 40,
          color: Colors.grey.shade400,
        ),
      ),
    );
  }
}

/// Simple loading card placeholder
class CustomLoadingCard extends StatelessWidget {
  final double height;
  final double borderRadius;

  const CustomLoadingCard({
    super.key,
    this.height = 200,
    this.borderRadius = 15,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: Colors.grey.shade200,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF3EC8B0),
        ),
      ),
    );
  }
}

/// Empty state card
class CustomEmptyCard extends StatelessWidget {
  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionText;

  const CustomEmptyCard({
    super.key,
    required this.message,
    this.icon = Icons.inbox,
    this.onAction,
    this.actionText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAction != null && actionText != null) ...[
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3EC8B0),
              ),
              child: Text(actionText!),
            ),
          ],
        ],
      ),
    );
  }
}