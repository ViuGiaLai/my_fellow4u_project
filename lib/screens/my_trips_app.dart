import 'package:flutter/material.dart';
import 'create_trip_page.dart';

void main() {
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

class _MyTripsScreenState extends State<MyTripsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  double? temperature = 28; // Giả định nhiệt độ cho header

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Widget Header được cung cấp bởi người dùng
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
        // TabBar overlaying on header
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
              labelPadding: EdgeInsets.zero,
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
          const SizedBox(height: 30), // Khoảng trống cho TabBar lấn lên
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
        backgroundColor: const Color(0xFF00BFA5),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateNewTripPage(),
            ),
          );
        },
      ),
    );
  }

  // --- MÀN HÌNH CURRENT ---
  Widget _buildCurrentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripCard(
          title: 'Dragon Bridge Trip',
          location: 'Da Nang, Vietnam',
          date: 'Jan 30, 2020',
          time: '13:00 - 15:00',
          host: 'Tuan Tran',
          imageUrl: 'https://res.cloudinary.com/dqe5syxc0/image/upload/v1772716308/mytrip_drogan_qtwsyr.png',
          status: 'Mark Finished',
          isCurrent: true,
        ),
      ],
    );
  }

  // --- MÀN HÌNH NEXT ---
  Widget _buildNextTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripCard(
          title: 'Ho Guom Trip',
          location: 'Hanoi, Vietnam',
          date: 'Feb 2, 2020',
          host: 'Emmy',
          imageUrl: 'https://images.unsplash.com/photo-1555921015-5532091f6026?w=500',
        ),
        _buildTripCard(
          title: 'Ho Chi Minh Mausoleum',
          location: 'Hanoi, Vietnam',
          date: 'Feb 2, 2020',
          time: '8:00 - 10:00',
          host: 'Emmy',
          imageUrl: 'https://res.cloudinary.com/dqe5syxc0/image/upload/v1772716971/Mask_Group_jyste0.png',
          status: 'Waiting',
        ),
        _buildTripCard(
          title: 'Duc Ba Church',
          location: 'Ho Chi Minh, Vietnam',
          date: 'Feb 2, 2020',
          time: '8:00 - 10:00',
          host: 'Waiting for offers',
          imageUrl: 'https://images.unsplash.com/photo-1583417319070-4a69db38a482?w=500',
          status: 'Bidding',
        ),
      ],
    );
  }

  // --- MÀN HÌNH PAST ---
  Widget _buildPastTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildTripCard(
          title: 'Quoc Tu Giam Temple',
          location: 'Hanoi, Vietnam',
          date: 'Feb 2, 2020',
          host: 'Emmy',
          imageUrl: 'https://res.cloudinary.com/dqe5syxc0/image/upload/v1772717026/Mask_Group_1_slf7cu.png',
        ),
        _buildTripCard(
          title: 'Dinh Doc Lap',
          location: 'Ho Chi Minh, Vietnam',
          date: 'Feb 2, 2020',
          time: '8:00 - 10:00',
          host: 'Khai Ho',
          imageUrl: 'https://images.unsplash.com/photo-1563492065599-3520f775eeed?w=500',
        ),
      ],
    );
  }

  // --- MÀN HÌNH WISHLIST ---
  Widget _buildWishlistTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildWishlistCard(
          title: 'Melbourne - Sydney',
          location: 'Australia',
          price: '600.00',
          imageUrl: 'https://images.unsplash.com/photo-1506973035872-a4ec16b8e8d9?w=500',
        ),
        _buildWishlistCard(
          title: 'Hanoi - Ha Long Bay',
          location: 'Vietnam',
          price: '300.00',
          imageUrl: 'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=500',
        ),
      ],
    );
  }

  // --- WIDGET TRIP CARD ---
  Widget _buildTripCard({
    required String title,
    required String location,
    required String date,
    String? time,
    required String host,
    required String imageUrl,
    String? status,
    bool isCurrent = false,
  }) {
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
              ),
              if (status != null)
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isCurrent) const Icon(Icons.check, size: 14, color: Colors.black),
                        if (isCurrent) const SizedBox(width: 4),
                        Text(status, style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              Positioned(
                top: 10,
                right: 10,
                child: const Icon(Icons.more_horiz, color: Colors.white),
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
                    Expanded(child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    const CircleAvatar(radius: 30, backgroundImage: NetworkImage('https://res.cloudinary.com/dqe5syxc0/image/upload/v1772716233/avatar_cpp4hl.png')),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF00BFA5)),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(date, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                if (time != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 14, color: Colors.grey),
                      const SizedBox(width: 6),
                      Text(time, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.person, size: 14, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(host, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
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
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _actionButton(IconData icon, String label) {
    return Expanded(
      child: OutlinedButton.icon(
        onPressed: () {},
        icon: Icon(icon, size: 16, color: const Color(0xFF00BFA5)),
        label: Text(label, style: const TextStyle(color: Color(0xFF00BFA5), fontSize: 11)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFF00BFA5)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }

  // --- WIDGET WISHLIST CARD ---
  Widget _buildWishlistCard({
    required String title,
    required String location,
    required String price,
    required String imageUrl,
  }) {
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
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover),
              ),
              const Positioned(
                top: 10,
                right: 10,
                child: Icon(Icons.bookmark, color: Colors.white, size: 24),
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
                    Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Icon(Icons.favorite_border, color: Color(0xFF00BFA5)),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 14, color: Color(0xFF00BFA5)),
                    const SizedBox(width: 4),
                    Text(location, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Icon(Icons.star, color: Colors.orange, size: 16),
                        Icon(Icons.star_half, color: Colors.orange, size: 16),
                        SizedBox(width: 5),
                        Text('4.5 (120)', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                    Text(price, style: const TextStyle(color: Color(0xFF00BFA5), fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
