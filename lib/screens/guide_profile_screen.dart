import 'package:flutter/material.dart';

class GuideProfileScreen extends StatefulWidget {
  final dynamic fellow;

  const GuideProfileScreen({super.key, required this.fellow});

  @override
  _GuideProfileScreenState createState() => _GuideProfileScreenState();
}

class _GuideProfileScreenState extends State<GuideProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = widget.fellow['user'] ?? {};
    final name = "${user['firstName'] ?? ''} ${user['lastName'] ?? 'Guide'}";
    final avatar = user['avatar'] ?? 'https://via.placeholder.com/150';
    final city = widget.fellow['city'] ?? 'Unknown City';
    final bio = widget.fellow['bio'] ?? 'No introduction provided.';
    final rating = widget.fellow['rating']?.toDouble() ?? 5.0;
    final reviews = widget.fellow['reviewCount'] ?? 0;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  height: 180,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                        'https://res.cloudinary.com/dqe5syxc0/image/upload/v1769696289/Mask_Group_mejmh6.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  left: 16,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.black),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -40,
                  left: 16,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 48,
                      backgroundImage: NetworkImage(avatar),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(130, 30, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                ...List.generate(5, (index) {
                                  return Icon(
                                    index < rating
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: Colors.amber,
                                    size: 16,
                                  );
                                }),
                                SizedBox(width: 8),
                                Text(
                                  "$reviews Reviews",
                                  style: TextStyle(color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF00CEA6),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "CHOOSE THIS\nGUIDE",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.location_on, color: Color(0xFF00CEA6), size: 16),
                      SizedBox(width: 4),
                      Text(
                        city,
                        style: TextStyle(color: Color(0xFF00CEA6), fontSize: 13),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Vietnamese    English    Korean",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
              child: Text(
                bio,
                style: TextStyle(fontSize: 14, color: Colors.black87),
              ),
            ),
            // Price sections
            _buildPriceItem("1 - 3 Travelers", "\$10/ hour"),
            _buildPriceItem("4 - 6 Travelers", "\$14/ hour"),
            _buildPriceItem("7 - 9 Travelers", "\$17/ hour"),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "My Experiences",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Experience list could be fetched from API
            _buildExperienceCard(
              "2 Hour Bicycle Tour exploring Hoian",
              "Hoian, Vietnam",
              "Jan 25, 2020",
              "1234 Likes",
              "https://images.unsplash.com/photo-1555448248-2571daf6344b?auto=format&fit=crop&w=400&q=80",
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceItem(String range, String price) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(range),
          Text(price, style: TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildExperienceCard(
    String title,
    String location,
    String date,
    String likes,
    String imageUrl,
  ) {
    return Card(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(
            imageUrl,
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.teal),
                    Text(
                      location,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    Text(
                      likes,
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
