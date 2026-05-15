import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/trip.dart';
import '../repositories/user_repository.dart';
import '../repositories/trip_repository.dart';
import 'settings_screen.dart';
import 'my_photos_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Trip> _trips = [];
  bool _isLoading = true;
  String? _userName;
  String? _userEmail;
  String? _avatarUrl;
  List<String> _photos = [];

  static const _teal = Color(0xFF3EC8B0);

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadTrips();
    _loadPhotos();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload photos when returning from My Photos screen
    _loadPhotos();
  }

  // Load photos from Supabase Storage
  Future<void> _loadPhotos() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client.storage
          .from('user_photos')
          .list(path: 'photos/${user.id}');

      if (response.isNotEmpty) {
        final urls = <String>[];
        for (final file in response) {
          final url = Supabase.instance.client.storage
              .from('user_photos')
              .getPublicUrl('photos/${user.id}/${file.name}');
          urls.add(url);
        }
        if (mounted) {
          setState(() => _photos = urls);
        }
      }
    } catch (e) {
      print('Error loading photos: $e');
    }
  }

  
  
  
  Future<void> _loadUserData() async {
    try {
      final userRepo = UserRepository();
      final userProfile = await userRepo.getUserProfile();
      if (userProfile != null) {
        setState(() {
          _userName = userProfile.name ?? userProfile.email?.split('@').first ?? 'User';
          _userEmail = userProfile.email ?? '';
          _avatarUrl = userProfile.avatarUrl;
        });
      }
    } on UserException catch (e) {
      // Hiển thị thông báo lỗi thân thiện
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadTrips() async {
    setState(() => _isLoading = true);
    try {
      final tripRepo = TripRepository();
      final trips = await tripRepo.getTrips();
      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } on TripException catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: _teal,
        onRefresh: _loadTrips,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader()),
            SliverToBoxAdapter(child: _buildSectionHeader('My Photos')),
            SliverToBoxAdapter(child: _buildPhotosGrid()),
            SliverToBoxAdapter(child: _buildSectionHeader('My Journeys')),
            if (_isLoading)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: CircularProgressIndicator(color: _teal),
                  ),
                ),
              )
            else if (_trips.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No journeys yet',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, i) => _buildJourneyCard(_trips[i]),
                  childCount: _trips.length,
                ),
              ),
            const SliverToBoxAdapter(child: SizedBox(height: 90)),
          ],
        ),
      ),
    );
  }

  // HEADER
  Widget _buildHeader() {
    return SizedBox(
      height: 230,
      child: Stack(
        children: [
          // Hero background image
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 170,
            child: Image.network(
              'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800',
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: const Color(0xFF2C3E50),
              ),
            ),
          ),

          // White bottom card
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: Container(color: Colors.white),
          ),
          Positioned(
            top: 52,
            right: 16,
            child: GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const SettingsScreen(),
                ).then((_) {
                  // Refresh Profile screen when Settings modal closes
                  _loadUserData();
                });
              },
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings,
                  color: Colors.black87,
                  size: 20,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 32,
            left: 20,
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: _avatarUrl != null
                        ? NetworkImage(_avatarUrl!)
                        : null,
                    child: _avatarUrl == null
                        ? Text(
                            (_userName?.isNotEmpty == true)
                                ? _userName![0].toUpperCase()
                                : 'U',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: _teal,
                            ),
                          )
                        : null,
                  ),
                ),
                // Camera edit button
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: _teal,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.camera_alt,
                        size: 13, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),

          // Name + Email
          Positioned(
            bottom: 28,
            left: 104,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _userName ?? '',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _userEmail ?? '',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 
  // SECTION HEADER
  // 
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          GestureDetector(
            onTap: () {
              if (title == 'My Photos') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MyPhotosScreen()),
                );
              }
            },
            child: Row(
              children: const [
                Text('See all',
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                SizedBox(width: 2),
                Icon(Icons.arrow_forward_ios, size: 11, color: Colors.grey),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 
  // PHOTOS GRID
  // 
  Widget _buildPhotosGrid() {
    if (_photos.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 1,
        ),
        itemCount: _photos.length,
        itemBuilder: (_, i) => ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.network(
            _photos[i],
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: Colors.grey[200]),
          ),
        ),
      ),
    );
  }

  // 
  // JOURNEY CARD
  // 
  Widget _buildJourneyCard(Trip trip) {
    final title = trip.title.isEmpty ? 'Untitled Journey' : trip.title;
    final destination = trip.destination;
    final imageUrl = trip.imageUrl;
    const likes = 234;
    final dt = trip.startDate;

    final formattedDate =
        '${_monthName(dt.month)} ${dt.day}, ${dt.year}';

    // Right-column fallback images
    const rightImg1 =
        'https://images.unsplash.com/photo-1528360983277-13d401cdc186?w=300';
    const rightImg2 =
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=300';
    final mainImg = imageUrl ??
        'https://images.unsplash.com/photo-1555400038-63f5ba517a47?w=500';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image mosaic
            SizedBox(
              height: 140,
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Image.network(
                      mainImg,
                      height: 140,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: Colors.grey[200]),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            rightImg1,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200]),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Expanded(
                          child: Image.network(
                            rightImg2,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                Container(color: Colors.grey[200]),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const Icon(Icons.more_horiz, color: Colors.grey),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 14, color: _teal),
                      const SizedBox(width: 3),
                      Text(
                        destination,
                        style: const TextStyle(
                          fontSize: 12,
                          color: _teal,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formattedDate,
                        style: const TextStyle(
                            fontSize: 12, color: Colors.grey),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.favorite_border,
                              size: 15, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '$likes Likes',
                            style: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[m];
  }
}