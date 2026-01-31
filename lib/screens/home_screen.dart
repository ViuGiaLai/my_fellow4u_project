import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.title});

  final String title;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
  
}

class _HomeScreenState extends State<HomeScreen> {

  //  WEATHER
  double? temperature;
  final String _apiKey = '5cd5d5d2d7a8b76cf116dd99d4cf4668'; // <-- đổi key ở đây
  final String _city = 'Da Nang';

  // tym
  Set<String> _favorites = {};

  @override
  void initState() {
    super.initState();
    _fetchWeather();
    _loadFavorites();
  }
  // Load local
  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _favorites = prefs.getStringList('favorites')?.toSet() ?? {};
    });
  }
  // Toggle tim
  Future<void> _toggleFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();

    if (_favorites.contains(id)) {
      _favorites.remove(id);
    } else {
      _favorites.add(id);
    }

    await prefs.setStringList('favorites', _favorites.toList());
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
      } else {
        // In ra lỗi để debug (ví dụ: 401 là do key chưa kích hoạt)
        print('Lỗi API: ${res.statusCode} - ${res.body}');
      }
    } catch (e) {
      print('Lỗi kết nối: $e');
    }
  }

  // --- DỮ LIỆU MẪU MỚI - ĐẢM BẢO HIỂN THỊ ---

  // Dữ liệu cho modal "Xem thêm Hướng dẫn viên"
  final List<Map<String, String>> _moreGuides = [
    {'name': 'Tuan Tran', 'location': 'Danang, Vietnam', 'imageUrl': 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300'},
    {'name': 'Emmy', 'location': 'Hanoi, Vietnam', 'imageUrl': 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300'},
    {'name': 'Linh Hana', 'location': 'Danang, Vietnam', 'imageUrl': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=300'},
    {'name': 'Khai Ho', 'location': 'Ho Chi Minh, Vietnam', 'imageUrl': 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300'},
    {'name': 'David Chen', 'location': 'Nha Trang, Vietnam', 'imageUrl': 'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300'},
    {'name': 'Sophia Nguyen', 'location': 'Sapa, Vietnam', 'imageUrl': 'https://images.unsplash.com/photo-1529626455594-4ff0802cfb7e?auto=format&fit=crop&w=300'},
  ];
  // Dữ liệu mới cho modal "Xem thêm Tour nổi bật"
  final List<Map<String, String>> _moreTours = [
    {
      'title': 'Hue Ancient Capital Tour',
      'price': '\$280.00',
      'imageUrl': 'https://images.unsplash.com/photo-1600596542815-ffad4c1539a9?auto=format&fit=crop&w=400'
    },
    {
      'title': 'Bangkok - Pattaya 5 Days',
      'price': '\$520.00',
      'imageUrl': 'https://images.unsplash.com/photo-1508009603885-50cf7c579365?auto=format&fit=crop&w=400'
    },
    {
      'title': 'Nha Trang Beach Relax Tour',
      'price': '\$290.00',
      'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400'
    },
    {
      'title': 'Tokyo – Mount Fuji Experience',
      'price': '\$720.00',
      'imageUrl': 'https://images.unsplash.com/photo-1549692520-acc6669e2f0c?auto=format&fit=crop&w=400'
    },

  ];


  // Dữ liệu cho modal "Xem thêm Tin tức du lịch"
  final List<Map<String, String>> _moreNews = [
    {'title': 'Sunrise at Fansipan Peak', 'imageUrl': 'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=400'},
    {'title': 'Hoi An Lantern Festival Night', 'imageUrl': 'https://images.unsplash.com/photo-1541417904950-b855846fe074?auto=format&fit=crop&w=400'},

    {'title': 'Explore Phu Quoc Paradise Island', 'imageUrl': 'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=400'},
    {'title': 'Sa Pa Rice Terraces Season', 'imageUrl': 'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=400'},
  ];


  // --- HÀM HIỂN THỊ MODAL ---
  void _showMoreModal(BuildContext context, String title, List<Map<String, String>> items, Widget Function(Map<String, String> ) itemBuilder) {
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

  // --- BUILD METHOD CHÍNH ---
  @override
  Widget build(BuildContext context) {
    // Widget này không còn chứa Scaffold nữa.
    // Nó chỉ trả về nội dung sẽ được hiển thị bên trong MainAppScaffold.
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: <Widget>[
          _buildCombinedHeader(),
          const SizedBox(height: 25),
          _buildSectionTitle('Top Journeys'),
          _buildTopJourneys(),
          _buildSectionTitle('Best Guides', showSeeMore: true, onSeeMore: () => _showMoreModal(context, 'All Guides', _moreGuides, (item) => _buildGuideListItem(item))),
          _buildBestGuides(),
          _buildSectionTitle('Top Experiences'),
          _buildTopExperiences(),
          _buildSectionTitle('Featured Tours', showSeeMore: true, onSeeMore: () => _showMoreModal(context, 'All Featured Tours', _moreTours, (item) => _buildTourCard(item['id'] ?? 'tour-${item['title']?.toLowerCase().replaceAll(' ', '-')}', item['title']!, item['price']!, item['imageUrl']!))),
          _buildFeaturedTours(),
          _buildSectionTitle('Travel News', showSeeMore: true, onSeeMore: () => _showMoreModal(context, 'All Travel News', _moreNews, (item) => _buildNewsCard(item['title']!, item['imageUrl']!))),
          _buildTravelNews(),
        ],
      ),
    );
  }

  // --- CÁC WIDGET CON ---

  Widget _buildCombinedHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Phần ảnh nền và thông tin Explore
        Container(
          height: 180, // Tăng chiều cao một chút để cân đối
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
                colors: [
                  Colors.black.withOpacity(0.5),
                  Colors.transparent,
                ],
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
                            Icon(Icons.location_on, color: Colors.white, size: 14),
                            SizedBox(width: 2),
                            Text(
                              'Da Nang',
                              style: TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.cloud_outlined,
                                color: Colors.white, size: 30),
                            const SizedBox(width: 6),
                            Text(
                              temperature != null
                                  ? '${temperature!.round()}°C'
                                  : '--°C',
                              style: const TextStyle(
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
        
        // Thanh Search Bar nằm đè lên
        Positioned(
          bottom: -25,
          left: 20,
          right: 20,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Hi, where do you want to explore?',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeMore = false, VoidCallback? onSeeMore}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          if (showSeeMore)
            InkWell(
              onTap: onSeeMore,
              child: Text('SEE MORE', style: TextStyle(color: const Color(0xFF00CEA6), fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildTopJourneys() {
    return SizedBox(
      height: 260,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          _buildJourneyCard('Da Nang - Ba Na - Hoi An', '\$400.00', 'https://images.unsplash.com/photo-1528702748617-c64d49f918af?auto=format&fit=crop&w=400' ),
          _buildJourneyCard('Thailand Temples', '\$600.00', 'https://images.unsplash.com/photo-1528181304800-259b08848526?auto=format&fit=crop&w=400' ),
          _buildJourneyCard('Singapore Gardens', '\$550.00', 'https://images.unsplash.com/photo-1525874684015-58379d421a52?auto=format&fit=crop&w=400' ),
        ],
      ),
    );
  }

  Widget _buildJourneyCard(String title, String price, String imageUrl) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          Stack(children: [
            Image.network(imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),

            Positioned(
              left: 8, bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(8)),
                child: Row(children: const [
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  Icon(Icons.star, size: 14, color: Colors.amber),
                  SizedBox(width: 6),
                  Text('1247 likes', style: TextStyle(color: Colors.white, fontSize: 11))
                ]),
              ),
            ),

            Positioned(
              top: 8, right: 8,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.9), shape: BoxShape.circle),
                child: const Icon(Icons.bookmark_border, size: 18),
              ),
            ),
          ]),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 4),
            child: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: const [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              SizedBox(width: 6),
              Text('Jan 30, 2020', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            child: Row(children: const [
              Icon(Icons.access_time, size: 14, color: Colors.grey),
              SizedBox(width: 6),
              Text('3 days', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ]),
          ),

          const Spacer(),

          Padding(
            padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            child: Text(price, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF00CEA6))),
          ),

        ]),
      ),
    );
  }

  Widget _buildBestGuides() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 0.8,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: [
          _buildGuideCard('Tuan Tran', 'Danang, Vietnam', 'https://images.unsplash.com/photo-1506794778202-cad84cf45f1d?auto=format&fit=crop&w=300' ),
          _buildGuideCard('Emmy', 'Hanoi, Vietnam', 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?auto=format&fit=crop&w=300' ),
          _buildGuideCard('Linh Hana', 'Danang, Vietnam', 'https://images.unsplash.com/photo-1580489944761-15a19d654956?auto=format&fit=crop&w=300' ),
          _buildGuideCard('Khai Ho', 'Ho Chi Minh, Vietnam', 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=300' ),
        ],
      ),
    );
  }

  Widget _buildGuideCard(String name, String location, String imageUrl) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        Expanded(
          flex: 3,
          child: Stack(children: [
            Image.network(imageUrl, width: double.infinity, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => const Center(child: Icon(Icons.error))),

            // ⭐ Rating + reviews (TRÊN ẢNH)
            Positioned(
              left: 8, bottom: 8,
              child: Row(children: const [
                Icon(Icons.star, size: 14, color: Colors.amber),
                Icon(Icons.star, size: 14, color: Colors.amber),
                Icon(Icons.star, size: 14, color: Colors.amber),
                Icon(Icons.star, size: 14, color: Colors.amber),
                Icon(Icons.star, size: 14, color: Colors.amber),
                SizedBox(width: 6),
                Text('127 reviews',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
              ]),
            ),
          ]),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [

              Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),

              Row(children: [
                const Icon(Icons.location_on, size: 14, color: Color(0xFF00CEA6)),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(location,
                    style: const TextStyle(fontSize: 12, color: Color(0xFF00CEA6)),
                    overflow: TextOverflow.ellipsis),
                ),
              ]),

            ]),
          ),
        ),

      ]),
    );
  }

  Widget _buildTopExperiences() {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 16),
        children: [
          _buildExperienceCard(
            'Sunset Kayaking on Han River',
            'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=500',
          ),
          _buildExperienceCard(
            'Fansipan Cable Car Experience',
            'https://images.unsplash.com/photo-1524492412937-b28074a5d7da?auto=format&fit=crop&w=500',
          ),
          _buildExperienceCard(
            'Da Lat Coffee Farm Discovery',
            'https://images.unsplash.com/photo-1509042239860-f550ce710b93?auto=format&fit=crop&w=500',
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(String title, String imageUrl) {
    return Container(
      width: 250,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            Image.network(imageUrl, width: double.infinity, height: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error))),
            Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [Colors.black54, Colors.transparent], begin: Alignment.bottomCenter, end: Alignment.center))),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedTours() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          _buildTourCard(
            'danang-tour',
            'Da Nang - Ba Na - Hoi An',
            '\$400.00',
            'https://images.unsplash.com/photo-1528702748617-c64d49f918af?auto=format&fit=crop&w=400',
          ),

          _buildTourCard(
            'melbourne-tour',
            'Melbourne - Sydney',
            '\$600.00',
            'https://images.unsplash.com/photo-1514395462725-fb4566210144?auto=format&fit=crop&w=400',
          ),
        ],
      ),
    );
  }

  Widget _buildTourCard(String id, String title, String price, String imageUrl) {
    return StatefulBuilder(
      builder: (context, setState) {
        final bool isFav = _favorites.contains(id);

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //IMAGE + OVERLAY
              Stack(
                children: [
                  Image.network(imageUrl, height: 170, width: double.infinity, fit: BoxFit.cover),

                  // ⭐ rating + likes
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star, color: Colors.amber, size: 16),
                        Icon(Icons.star_half, color: Colors.amber, size: 16),
                        SizedBox(width: 6),
                        Text('1247 likes', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    ),
                  ),

                  // 🔖 bookmark
                  const Positioned(top: 12, right: 12,
                    child: Icon(Icons.bookmark_border, color: Colors.white, size: 26),
                  ),
                ],
              ),

              //CONTENT
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // title + heart
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            _toggleFavorite(id);
                            setState(() {});
                          },
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav
                                ? const Color(0xFF00CEA6)
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // date
                    Row(
                      children: const [
                        Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        SizedBox(width: 6),
                        Text('Jan 30, 2020', style: TextStyle(fontSize: 13, color: Colors.grey)),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // duration + price
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 6),
                        const Text('3 days', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        const Spacer(),
                        Text(price, style: const TextStyle(color: Color(0xFF00CEA6), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _buildTravelNews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
        _buildNewsCard(
          'Discover Ninh Binh Nature',
          'https://images.unsplash.com/photo-1528181304800-259b08848526?auto=format&fit=crop&w=400',
        ),
        _buildNewsCard(
          'Beautiful Sunrise in Sapa',
          'https://images.unsplash.com/photo-1501785888041-af3ef285b470?auto=format&fit=crop&w=400',
        ),
      ],
      ),
    );
  }

  Widget _buildNewsCard(String title, String imageUrl) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.error))),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  // Widget dùng để hiển thị trong modal "All Guides"
  Widget _buildGuideListItem(Map<String, String> item) {
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(item['imageUrl']!),
          onBackgroundImageError: (exception, stackTrace) {},
        ),
        title: Text(item['name']!),
        subtitle: Text(item['location']!),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () { /* Thêm hành động khi nhấn vào một guide trong modal */ },
      ),
    );
  }
}
