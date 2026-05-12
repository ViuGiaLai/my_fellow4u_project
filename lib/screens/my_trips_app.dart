// File: my_trips_app.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'create_trip_page.dart';
import '../services/api_service.dart';

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
  List<dynamic> _trips = [];
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
      final trips = await ApiService.getTrips();

      setState(() {
        _trips = trips;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "Không thể tải dữ liệu. Vui lòng thử lại sau.";
        _isLoading = false;
      });
      print("Lỗi load trips: $e");
    }
  }

  Future<void> _loadWishlist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wishlistJson = prefs.getString('wishlist_items') ?? '[]';
      final List<dynamic> wishlist = json.decode(wishlistJson);

      setState(() {
        _wishlistItems = wishlist;
        _wishlistIds = {for (var item in wishlist) item['_id'] ?? ''};
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

  Future<void> _refreshWishlist() async {
    await _loadWishlist();
  }

  Future<void> _toggleFavorite(String tripId, dynamic tripData) async {
    final prefs = await SharedPreferences.getInstance();

    // Lấy wishlist hiện tại
    final wishlistJson = prefs.getString('wishlist_items') ?? '[]';
    final List<dynamic> wishlist = json.decode(wishlistJson);

    setState(() {
      if (_wishlistIds.contains(tripId)) {
        _wishlistIds.remove(tripId);
        _wishlistItems.removeWhere((item) => item['_id'] == tripId);
        wishlist.removeWhere((item) => item['_id'] == tripId);
      } else {
        _wishlistIds.add(tripId);
        _wishlistItems.add(tripData);
        wishlist.add(tripData);
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
        _trips.where((trip) => trip['status'] == 'confirmed').toList();

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
        _trips.where((trip) => trip['status'] == 'waiting').toList();

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
              (trip) =>
                  trip['status'] == 'completed' ||
                  trip['status'] == 'cancelled',
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
    final String id = trip['_id'] ?? trip['id'] ?? '';
    final String title = trip['title'] ?? 'Untitled Trip';
    final String location = trip['destination'] ?? '';
    final String date = _formatDate(trip['startDate']);
    final String? time =
        (trip['startTime'] != null && trip['endTime'] != null)
            ? '${trip['startTime']} - ${trip['endTime']}'
            : null;
    final String host = trip['host']?['name'] ?? 'Waiting for guide';
    final String imageUrl = trip['thumbnail'] ?? trip['imageUrl'] ?? '';
    final String status = trip['status'] ?? '';
    final bool isFavorite = _wishlistIds.contains(id);

    String displayStatus = '';
    bool isCurrent = false;

    if (status == 'confirmed') {
      displayStatus = 'In Progress';
      isCurrent = true;
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
    try {
      final date = DateTime.parse(dateStr.toString());
      return '${date.month}/${date.day}/${date.year}';
    } catch (_) {
      return dateStr.toString();
    }
  }
}
