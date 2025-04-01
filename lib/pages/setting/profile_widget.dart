import 'package:flutter/material.dart';

class ProfileSetting extends StatelessWidget {
  final BuildContext context;
  final String? imageUrl;
  final double size;
  final double iconSize;
  final double padding;

  const ProfileSetting({
    super.key,
    required this.context,
    this.imageUrl,
    this.size = 110,
    this.iconSize = 70,
    this.padding = 15,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: imageUrl != null
          ? Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(context);
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                );
              },
            )
          : _buildPlaceholder(context),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person,
        size: iconSize,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}
