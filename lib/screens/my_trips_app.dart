// File: my_trips_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'create_trip_page.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Quan trọng

  runApp(const MyTripsApp());
}

class MyTripsApp extends StatelessWidget {
  const MyTripsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF00BFA5),
        scaffoldBackgroundColor: const Color(0xFFF8F9FA),
        fontFamily: 'Roboto',
      ),
      home: const MyTripsScreen(),
    );
  }
}

class MyTripsScreen extends StatefulWidget {
  const MyTripsScreen({super.key});

  @override
  State<MyTripsScreen> createState() => _MyTripsScreenState();
}

class _MyTripsScreenState extends State<MyTripsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Trip> _trips = [];
  List<dynamic> _wishlistItems = [];
  Set<String> _wishlistIds = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadTrips();
    _loadWishlist();

    // Reload wishlist khi user tab sang Wish List (tab index 3)
    _tabController.addListener(() {
      if (_tabController.index == 3) {
        _loadWishlist();
      }
    });
  }

  Future<void> _loadTrips() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final tripRepo = TripRepository();
      final trips = await tripRepo.getTrips();

      if (mounted) {
        setState(() {
          _trips = trips;
          _isLoading = false;
        });
      }
    } on TripException catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.message;
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _loadTrips,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Không thể tải dữ liệu. Vui lòng thử lại sau.";
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã xảy ra lỗi. Vui lòng thử lại!'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _loadTrips,
            ),
          ),
        );
      }
    }
  }

  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('wishlist_items') ?? '[]';
      final List<dynamic> wishlist = json.decode(wishlistJson);

      setState(() {
        _wishlistItems = wishlist;
        _wishlistIds = {
          for (final item in wishlist) _wishlistItemId(item),
        }.where((id) => id.isNotEmpty).toSet();
      });

      print("✅ Loaded ${_wishlistItems.length} wishlist items");
      print("📋 Wishlist IDs: ${_wishlistIds.toString()}");
      if (_wishlistItems.isNotEmpty) {
        print("📌 First item: ${_wishlistItems[0]['title'] ?? 'N/A'}");
      }
    } catch (e) {
      print("❌ Error loading wishlist: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _effectiveTripStatus(Trip trip) => trip.status ?? 'waiting';

  String _wishlistItemId(dynamic item) {
    if (item is Trip) {
      return item.id ?? '';
    } else if (item is Map) {
      return item['_id']?.toString() ?? item['id']?.toString() ?? '';
    }
    return '';
  }

  Future<void> _refreshWishlist() async {
    await _loadWishlist();
  }

  Future<void> _toggleFavorite(String tripId, dynamic tripData) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy wishlist hiện tại
    final wishlistJson = prefs.getString('wishlist_items') ?? '[]';
    final List<dynamic> wishlist = json.decode(wishlistJson);

    final Map<String, dynamic> stored;
    if (tripData is Trip) {
      stored = tripData.toWishlistMap();
    } else if (tripData is Map) {
      stored = Map<String, dynamic>.from(tripData);
    } else {
      return;
    }

    setState(() {
      if (_wishlistIds.contains(tripId)) {
        _wishlistIds.remove(tripId);
        _wishlistItems.removeWhere((item) => _wishlistItemId(item) == tripId);
        wishlist.removeWhere((item) => _wishlistItemId(item) == tripId);
      } else {
        _wishlistIds.add(tripId);
        _wishlistItems.add(stored);
        wishlist.add(stored);
      }
    });

    // Lưu vào SharedPreferences để sync với home screen
    await prefs.setString('wishlist_items', json.encode(wishlist));
  }

  //  HEADER
  Widget _buildCombinedHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://res.cloudinary.com/dqe5syxc0/image/upload/v1769696289/Mask_Group_mejmh6.png',
              ),
              fit: BoxFit.cover,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Explore',
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 14,
                            ),
                            SizedBox(width: 2),
                            Text(
                              'Da Nang',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(
                              Icons.cloud_outlined,
                              color: Colors.white,
                              size: 30,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              '28°C',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: -30,
          left: 0,
          right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 0),
            height: 60,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFF00BFA5),
              unselectedLabelColor: Colors.grey,
              indicatorColor: const Color(0xFF00BFA5),
              indicatorSize: TabBarIndicatorSize.label,
              labelStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              tabs: const [
                Tab(text: 'Current Trips'),
                Tab(text: 'Next Trips'),
                Tab(text: 'Past Trips'),
                Tab(text: 'Wish List'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildCombinedHeader(),
          const SizedBox(height: 35),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCurrentTab(),
                _buildNextTab(),
                _buildPastTab(),
                _buildWishlistTab(),
              ],
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        heroTag: 'trip_create_fab',
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateNewTripPage()),
          );

          // Nếu tạo trip thành công (result == true), thì tải lại dữ liệu
          if (result == true) {
            _loadTrips(); // ← Refresh dữ liệu mới
          }
        },
      ),
    );
  }

  //  TABS
  Widget _buildCurrentTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return _buildErrorState();

    final currentTrips =
        _trips.where((trip) => _effectiveTripStatus(trip) == 'confirmed').toList();

    if (currentTrips.isEmpty) {
      return _buildEmptyState('No current trips');
    }

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: currentTrips.length,
        itemBuilder: (context, index) => _buildTripCard(currentTrips[index]),
      ),
    );
  }

  Widget _buildNextTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return _buildErrorState();

    final nextTrips =
        _trips.where((trip) => _effectiveTripStatus(trip) == 'waiting').toList();

    if (nextTrips.isEmpty) return _buildEmptyState('No upcoming trips');

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: nextTrips.length,
        itemBuilder: (context, index) => _buildTripCard(nextTrips[index]),
      ),
    );
  }

  Widget _buildPastTab() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage != null) return _buildErrorState();

    final pastTrips =
        _trips
            .where(
              (trip) {
                final s = _effectiveTripStatus(trip);
                return s == 'completed' || s == 'cancelled';
              },
            )
            .toList();

    if (pastTrips.isEmpty) return _buildEmptyState('No past trips');

    return RefreshIndicator(
      onRefresh: _loadTrips,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pastTrips.length,
        itemBuilder: (context, index) => _buildTripCard(pastTrips[index]),
      ),
    );
  }

  Widget _buildWishlistTab() {
    if (_wishlistItems.isEmpty) {
      return _buildEmptyState('No wishlist items');
    }

    return RefreshIndicator(
      onRefresh: _refreshWishlist,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _wishlistItems.length,
        itemBuilder: (context, index) => _buildTripCard(_wishlistItems[index]),
      ),
    );
  }

  //  HELPERS
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            _errorMessage!,
            style: const TextStyle(color: Colors.red, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: _loadTrips, child: const Text("Thử lại")),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.card_travel, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(onPressed: _loadTrips, child: const Text("Refresh")),
        ],
      ),
    );
  }

  //  TRIP CARD
  Widget _buildTripCard(dynamic trip) {
    final String id;
    final String title;
    final String location;
    final String date;
    final String? time;
    final String host;
    final String imageUrl;
    final String status;

    if (trip is Trip) {
      id = trip.id ?? '';
      title = trip.title;
      location = trip.destination;
      date = _formatDate(trip.startDate);
      time =
          (trip.startTime != null && trip.endTime != null)
              ? '${trip.startTime} - ${trip.endTime}'
              : null;
      host = trip.hostName ?? 'Waiting for guide';
      imageUrl = trip.imageUrl ?? '';
      status = trip.status ?? '';
    } else if (trip is Map) {
      final m = Map<String, dynamic>.from(trip);
      id = m['_id']?.toString() ?? m['id']?.toString() ?? '';
      title = m['title'] as String? ?? 'Untitled Trip';
      location = m['destination'] as String? ?? '';
      date = _formatDate(m['startDate']);
      time =
          (m['startTime'] != null && m['endTime'] != null)
              ? '${m['startTime']} - ${m['endTime']}'
              : null;
      final dynamic hostRaw = m['host'];
      host =
          hostRaw is Map && hostRaw['name'] != null
              ? hostRaw['name'] as String
              : 'Waiting for guide';
      imageUrl = m['thumbnail'] as String? ?? m['imageUrl'] as String? ?? '';
      status = m['status'] as String? ?? '';
    } else {
      return const SizedBox.shrink();
    }

    final bool isFavorite = _wishlistIds.contains(id);

    String displayStatus = '';

    if (status == 'confirmed') {
      displayStatus = 'In Progress';
    } else if (status == 'waiting') {
      displayStatus = 'Waiting';
    } else if (status == 'completed') {
      displayStatus = 'Completed';
    } else if (status == 'cancelled') {
      displayStatus = 'Cancelled';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child:
                    imageUrl.isNotEmpty
                        ? Image.network(
                          imageUrl,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => Container(
                                height: 160,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 50,
                                ),
                              ),
                        )
                        : Container(
                          height: 160,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 50,
                          ),
                        ),
              ),
              if (displayStatus.isNotEmpty)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      displayStatus,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 50,
                child: InkWell(
                  onTap: () => _toggleFavorite(id, trip),
                  child: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? const Color(0xFF00BFA5) : Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.more_horiz, color: Colors.white),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(15),
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
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: NetworkImage(
                        'https://res.cloudinary.com/dqe5syxc0/image/upload/v1772716233/avatar_cpp4hl.png',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 14,
                      color: Color(0xFF00BFA5),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      location,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      date,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                if (time != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        time,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  host,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                const SizedBox(height: 15),
                Row(
                  children: [
                    _actionButton(Icons.info_outline, 'Detail'),
                    const SizedBox(width: 10),
                    _actionButton(Icons.chat_bubble_outline, 'Chat'),
                    const SizedBox(width: 10),
                    _actionButton(Icons.payment, 'Pay'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16, color: const Color(0xFF00BFA5)),
        label: Text(
          label,
          style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 11),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00BFA5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  String _formatDate(dynamic dateStr) {
    if (dateStr == null) return '';
    if (dateStr is DateTime) {
      return '${dateStr.month}/${dateStr.day}/${dateStr.year}';
    }
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return dateStr.toString();
    }
  }
}
