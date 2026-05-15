import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../repositories/user_repository.dart';
import 'profile_screen.dart';
import 'edit_profile_screen.dart';
import '../main.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _userName;
  String? _avatarUrl;
  String? _userRole;
  bool _isLoading = true;

  static const _green = Color(0xFF3EC8B0);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final userRepo = UserRepository();
      final userProfile = await userRepo.getUserProfile();
      if (userProfile != null && mounted) {
        setState(() {
          _userName = userProfile.name ?? userProfile.email?.split('@').first ?? 'User';
          _avatarUrl = userProfile.avatarUrl;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể tải dữ liệu. Vui lòng thử lại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: _green),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          _ProfileHeader(
            userName: _userName ?? 'User',
            avatarUrl: _avatarUrl,
          ),
          Expanded(
            child: ListView(
              children: [
                _buildTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notifications',
                  hasToggle: true,
                ),
                _buildTile(
                  icon: Icons.public,
                  title: 'Languages',
                ),
                _buildTile(
                  icon: Icons.payment,
                  title: 'Payment',
                ),
                _buildTile(
                  icon: Icons.privacy_tip_outlined,
                  title: 'Privacy & Policies',
                ),
                _buildTile(
                  icon: Icons.mail_outline,
                  title: 'Feedback',
                ),
                _buildTile(
                  icon: Icons.menu_book_outlined,
                  title: 'Usage',
                ),
                const SizedBox(height: 20),
                _buildSignOutButton(),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    bool hasToggle = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.black54, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      trailing: hasToggle
          ? Switch(
              value: true,
              onChanged: (value) {},
              activeColor: _green,
            )
          : const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _buildSignOutButton() {
    return Center(
      child: TextButton(
        onPressed: () async {
          await logout(context);
        },
        child: const Text(
          'Sign out',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String userName;
  final String? avatarUrl;

  const _ProfileHeader({
    required this.userName,
    this.avatarUrl,
  });

  static const _green = Color(0xFF3EC8B0);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _green,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
              child: avatarUrl == null
                  ? Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: _green,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          // Name and role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'User',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Edit Profile button
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const EditProfileScreen()),
              ).then((_) {
                // Just close the modal, parent will handle refresh
                Navigator.of(context).pop();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: _green,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              'EDIT PROFILE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
