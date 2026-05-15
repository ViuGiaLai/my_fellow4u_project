// SỬ DỤNG TẠI: 
//   - Tất cả các screen có AppBar đều nên dùng CustomAppBar
//   - profile_screen.dart (CustomProfileAppBar)
//   - home_screen.dart (CustomBottomNavBar)
//   - ChatHomePage.dart (CustomBottomNavBar)
import 'package:flutter/material.dart';

/// Custom AppBar với style统一
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBackButton;
  final Color? backgroundColor;
  final Color? titleColor;
  final double elevation;
  final VoidCallback? onBackPressed;
  final bool centerTitle;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.actions,
    this.leading,
    this.showBackButton = true,
    this.backgroundColor,
    this.titleColor,
    this.elevation = 0,
    this.onBackPressed,
    this.centerTitle = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Colors.white;
    final fgColor = titleColor ?? Colors.black87;

    return AppBar(
      backgroundColor: bgColor,
      elevation: elevation,
      leading: _buildLeading(context),
      title: titleWidget ?? (title != null
          ? Text(
              title!,
              style: TextStyle(
                color: fgColor,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            )
          : null),
      centerTitle: centerTitle,
      actions: actions,
      iconTheme: IconThemeData(color: fgColor),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) return leading;

    if (showBackButton && Navigator.canPop(context)) {
      return IconButton(
        icon: Icon(Icons.arrow_back, color: titleColor ?? Colors.black87),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      );
    }

    return null;
  }
}

/// Custom AppBar với avatar (cho profile screens)
class CustomProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final List<Widget>? actions;
  final bool showBackButton;

  const CustomProfileAppBar({
    super.key,
    required this.title,
    this.avatarUrl,
    this.onAvatarTap,
    this.actions,
    this.showBackButton = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      title: title,
      showBackButton: showBackButton,
      actions: actions,
      leading: avatarUrl != null
          ? GestureDetector(
              onTap: onAvatarTap,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CircleAvatar(
                  backgroundImage: NetworkImage(avatarUrl!),
                  radius: 18,
                ),
              ),
            )
          : null,
    );
  }
}

/// Custom Bottom Navigation Bar
class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF3EC8B0),
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
      items: items,
    );
  }
}