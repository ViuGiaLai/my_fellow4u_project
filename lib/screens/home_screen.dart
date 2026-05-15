import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../services/api_service.dart' show NetworkException, TimeoutException, ApiException;
import 'guide_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // WEATHER
  double? temperature;
  static const String _apiKey = '5cd5d5d2d7a8b76cf116dd99d4cf4668';
  static const String _city = 'Da Nang';

  // Favorites
  Set<String> _favorites = {};

  // API Data
  List<dynamic> _tours = [];
  List<dynamic> _fellows = [];
  List<dynamic> _places = [];
  List<dynamic> _blogs = [];
  List<dynamic> _experiences = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _loadFavorites();
    _loadApiData();
  }

  Future<void> _loadApiData() async {
    setState(() => _isLoading = true);
    try {
      final results = await Future.wait([
        ApiService.getTours(),
        ApiService.getFellows(),
        ApiService.getPlaces(),
        ApiService.getBlogs(),
        ApiService.getExperiences(),
      ]);
      if (mounted) {
        setState(() {
          _tours = results[0];
          _fellows = results[1];
          _places = results[2];
          _blogs = results[3];
          _experiences = results[4];
          _isLoading = false;
        });
      }
    } on NetworkException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _loadApiData,
            ),
          ),
        );
      }
    } on TimeoutException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.orange,
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: _loadApiData,
            ),
          ),
        );
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xảy ra lỗi. Vui lòng thử lại!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }

  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Lấy wishlist hiện tại
    final wishlistJson = prefs.getString('wishlist_items') ?? '[]';
    final List<dynamic> wishlist = json.decode(wishlistJson);
    
    setState(() {
      if (_favorites.contains(id)) {
        // Xóa khỏi wishlist
        debugPrint("❤️ Removing $id from favorites");
        _favorites.remove(id);
        wishlist.removeWhere((item) => item['_id'] == id);
      } else {
        // Thêm vào wishlist
        debugPrint("❤️ Adding $id to favorites");
        _favorites.add(id);
        
        try {
          final tour = _tours.firstWhere((t) => t['_id'] == id);
          debugPrint("✅ Found tour: ${tour['title']}");
          wishlist.add(tour);
        } catch (e) {
          debugPrint("❌ Tour not found in _tours: $e");
          // Nếu không tìm thấy trong _tours, tạo object đơn giản
          wishlist.add({'_id': id});
        }
      }
    });
    
    debugPrint("📝 Wishlist now has ${wishlist.length} items");
    
    // Lưu cả favorites ID list và full trip data
    await prefs.setStringList('favorites', _favorites.toList());
    await prefs.setString('wishlist_items', json.encode(wishlist));
    
    debugPrint("💾 Saved to SharedPreferences");
  }

  Future<void> _fetchWeather() async {
    try {
      final url = 'https://api.openweathermap.org/data/2.5/weather?q=Da%20Nang&units=metric&appid=$_apiKey';
      final res = await http.get(Uri.parse(url));
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        setState(() {
          temperature = data['main']['temp'];
        });
      }
    } catch (e) {
      debugPrint('Lỗi kết nối thời tiết: $e');
    }
  }

  // MODAL DÙNG CHUNG CHO CÁC SECTION "SEE MORE"
  void _showMoreModal(BuildContext context, String title, List<dynamic> items, Widget Function(dynamic) itemBuilder) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: itemBuilder(items[index]),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _loadApiData,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: <Widget>[
                _buildCombinedHeader(),
                const SizedBox(height: 25),
                _buildSectionTitle('Top Journeys'),
                _buildTopJourneys(),
                _buildSectionTitle('Best Guides', showSeeMore: true, onSeeMore: () => _showMoreModal(context, 'All Guides', _fellows, (item) => _buildGuideListItem(item))),
                _buildBestGuides(),
                _buildSectionTitle('Top Experiences'),
                _buildTopExperiences(),
                _buildSectionTitle('Featured Tours', showSeeMore: true, onSeeMore: () => _showMoreModal(context, 'All Featured Tours', _tours, (item) => _buildTourCard(item))),
                _buildFeaturedTours(),
                _buildSectionTitle('Travel News', showSeeMore: true, onSeeMore: () => _showMoreModal(context, 'All Travel News', _blogs, (item) => _buildNewsCard(item))),
                _buildTravelNews(),
              ],
            ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeMore = false, VoidCallback? onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2D3142))),
          if (showSeeMore)
            GestureDetector(
              onTap: onSeeMore,
              child: const Text('SEE MORE', style: TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.bold, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  Widget _buildCombinedHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 180,
          width: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: NetworkImage('https://res.cloudinary.com/dqe5syxc0/image/upload/v1769696289/Mask_Group_mejmh6.png'),
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
                    const Text('Explore', style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.location_on, color: Colors.white, size: 14),
                            SizedBox(width: 2),
                            Text('Da Nang', style: TextStyle(color: Colors.white, fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.cloud_outlined, color: Colors.white, size: 30),
                            const SizedBox(width: 6),
                            Text(temperature != null ? '${temperature!.round()}°C' : '--°C',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w400, color: Colors.white)),
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
          bottom: -25,
          left: 16,
          right: 16,
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Hi, where do you want to explore?',
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
  //  Tạo ListView chứa nhiều cards   
  Widget _buildTopJourneys() {
    if (_tours.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No journeys found')));
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _tours.length,
        itemBuilder: (context, index) {
          final tour = _tours[index];
          return _buildJourneyCard(tour);
        },
      ),
    );
  }
  // Tạo 1 card cụ thể (image + title + date...) 
  Widget _buildJourneyCard(dynamic tour) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(tour['thumbnail'] ?? 'https://via.placeholder.com/200x120', height: 120, width: double.infinity, fit: BoxFit.cover),
                const Positioned(top: 8, right: 8, child: Icon(Icons.bookmark_border, color: Colors.white)),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tour['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 4),
                  Row(children: [const Icon(Icons.calendar_today, size: 12, color: Colors.grey), const SizedBox(width: 4), Text(tour['duration'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey))]),
                  const SizedBox(height: 4),
                  Text('\$${tour['priceAdult'] ?? 0}', style: const TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Tạo ListView chứa nhiều cards
  Widget _buildBestGuides() {
    if (_fellows.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No guides found')));
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16, childAspectRatio: 0.8),
      itemCount: _fellows.length > 4 ? 4 : _fellows.length,
      itemBuilder: (context, index) {
        return _buildGuideCard(_fellows[index]);
      },
    );
  }

  // Tạo 1 card cụ thể (image + title + date...) 
  Widget _buildGuideCard(dynamic fellow) {
    final user = fellow['user'];
    final name = user != null ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}' : 'Unknown';
    final avatar = user != null ? user['avatar'] : 'https://via.placeholder.com/150';
    final rating = fellow['rating']?.toDouble() ?? 0.0;
    final reviewCount = fellow['reviewCount'] ?? 0;
    
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuideProfileScreen(fellow: fellow),
          ),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: Image.network(avatar, width: double.infinity, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              const Icon(Icons.location_on, size: 12, color: Color(0xFF00CEA6)),
              const SizedBox(width: 4),
              Text(fellow['city'] ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  if (index < rating.floor()) {
                    return const Icon(Icons.star, size: 12, color: Colors.amber);
                  } else if (index < rating && index >= rating.floor()) {
                    return const Icon(Icons.star_half, size: 12, color: Colors.amber);
                  } else {
                    return const Icon(Icons.star_border, size: 12, color: Colors.amber);
                  }
                }),
              ),
              const SizedBox(width: 4),
              Text('($reviewCount)', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
  // Tạo ListView chứa nhiều cards
  Widget _buildTopExperiences() {
    if (_experiences.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No experiences found')));
    return SizedBox(
      height: 200, // Tăng nhẹ chiều cao để chứa thêm ngày tháng
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _experiences.length,
        itemBuilder: (context, index) {
          final exp = _experiences[index];
          // Lấy 10 ký tự đầu của createdAt (YYYY-MM-DD)
          final dateStr = exp['createdAt']?.toString().substring(0, 10) ?? '';
          final guide = exp['guide'];
          
          return _buildExperienceCard(
            exp['title'] ?? '', 
            exp['thumbnail'] ?? 'https://via.placeholder.com/250x180',
            dateStr,
            guide
          );
        },
      ),
    );
  }

  // Tạo 1 card cụ thể (image + title + date...)
  Widget _buildExperienceCard(String title, String imageUrl, String date, dynamic guide) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover),
            // Lớp phủ Gradient để chữ rõ hơn
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black87, Colors.transparent], 
                  begin: Alignment.bottomCenter, 
                  end: Alignment.topCenter
                )
              )
            ),
            // Avatar và tên guide ở góc trên bên trái
            if (guide != null)
              Positioned(
                top: 8,
                left: 8,
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: ClipOval(
                        child: Image.network(
                          guide['avatar'] ?? 'https://via.placeholder.com/32',
                          width: 32,
                          height: 32,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => 
                            Container(
                              width: 32,
                              height: 32,
                              color: Colors.grey[300],
                              child: const Icon(Icons.person, size: 16, color: Colors.white),
                            ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${guide['firstName'] ?? ''} ${guide['lastName'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title, 
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Colors.white70, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        date, 
                        style: const TextStyle(color: Colors.white70, fontSize: 12)
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

  // Tạo ListView chứa nhiều cards    
  Widget _buildFeaturedTours() {
    if (_tours.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No tours found')));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: _tours.take(3).map((tour) => _buildTourCard(tour)).toList(),
      ),
    );
  }

  //  Tạo 1 card cụ thể (image + title + date...) │
  Widget _buildTourCard(dynamic tour) {
    final id = tour['_id'] ?? '';
    final isFav = _favorites.contains(id);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(tour['thumbnail'] ?? 'https://via.placeholder.com/400x170', height: 170, width: double.infinity, fit: BoxFit.cover),
              Positioned(
                left: 12,
                bottom: 12,
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const SizedBox(width: 6),
                    Text('${tour['rating'] ?? 4.5} likes', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  ],
                ),
              ),
              const Positioned(top: 12, right: 12, child: Icon(Icons.bookmark_border, color: Colors.white, size: 26)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(tour['title'] ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    InkWell(
                      onTap: () => _toggleFavorite(id),
                      child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? const Color(0xFF00CEA6) : Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(children: [const Icon(Icons.calendar_today, size: 14, color: Colors.grey), const SizedBox(width: 6), Text(tour['createdAt']?.toString().substring(0, 10) ?? '', style: const TextStyle(fontSize: 13, color: Colors.grey))]),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(tour['duration'] ?? '', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                    const Spacer(),
                    Text('\$${tour['priceAdult'] ?? 0}', style: const TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.bold, fontSize: 16)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  // Tạo ListView chứa nhiều cards  
  Widget _buildTravelNews() {
    if (_blogs.isEmpty) return const SizedBox(height: 100, child: Center(child: Text('No news found')));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: _blogs.take(3).map((blog) => _buildNewsCard(blog)).toList(),
      ),
    );
  }

  // Tạo 1 card cụ thể (image + title + date...)
  Widget _buildNewsCard(dynamic blog) {
    final author = blog['author'];
    final authorName = author != null ? '${author['firstName'] ?? ''} ${author['lastName'] ?? ''}' : 'Unknown';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(blog['thumbnail'] ?? 'https://via.placeholder.com/400x150', height: 150, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(blog['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.person, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        authorName,
                        style: TextStyle(color: Colors.grey[600]!, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(blog['createdAt']?.toString().substring(0, 10) ?? '', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.favorite_border, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('${blog['likesCount'] ?? 0} likes', style: TextStyle(color: Colors.grey[600]!, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideListItem(dynamic fellow) {
    final user = fellow['user'];
    final name = user != null ? '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}' : 'Unknown';
    final avatar = user != null ? user['avatar'] : 'https://via.placeholder.com/150';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => GuideProfileScreen(fellow: fellow),
          ),
        );
      },
      child: Card(
        child: ListTile(
          leading: CircleAvatar(backgroundImage: NetworkImage(avatar)),
          title: Text(name),
          subtitle: Text(fellow['city'] ?? ''),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        ),
      ),
    );
  }
}
