import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddNewAttractionsScreen extends StatefulWidget {
  @override
  _AddNewAttractionsScreenState createState() =>
      _AddNewAttractionsScreenState();
}

class _AddNewAttractionsScreenState extends State<AddNewAttractionsScreen> {
  final TextEditingController searchController = TextEditingController();
  List<dynamic> allPlaces = [];
  List<dynamic> filteredPlaces = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    final places = await ApiService.getPlaces();
    setState(() {
      allPlaces = places;
      filteredPlaces = places;
      isLoading = false;
    });
  }

  void _filterPlaces(String query) {
    setState(() {
      filteredPlaces =
          allPlaces
              .where(
                (place) =>
                    place['name'].toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("New Attractions"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, []),
            child: Text(
              "DONE",
              style: TextStyle(color: Colors.teal, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: searchController,
              onChanged: _filterPlaces,
              decoration: InputDecoration(
                hintText: "Type a Place",
                suffixIcon: Icon(Icons.add_circle, color: Colors.teal),
                border: UnderlineInputBorder(),
              ),
            ),
          ),
          if (isLoading)
            Center(child: CircularProgressIndicator())
          else
            Expanded(
              child: ListView.builder(
                itemCount: filteredPlaces.length,
                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];
                  return ListTile(
                    title: Text(place['name'] ?? ''),
                    onTap: () {
                      // Logic to select place
                    },
                  );
                },
              ),
            ),
          // Suggested section based on UI
          if (searchController.text.isNotEmpty && filteredPlaces.isNotEmpty)
            Container(
              padding: EdgeInsets.all(16),
              height: 150,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: filteredPlaces.length,
                itemBuilder: (context, index) {
                  final place = filteredPlaces[index];
                  return Container(
                    width: 120,
                    margin: EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image: DecorationImage(
                        image: NetworkImage(
                          place['image'] ?? 'https://via.placeholder.com/150',
                        ),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black26,
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        Positioned(
                          bottom: 8,
                          left: 8,
                          child: Text(
                            place['name'],
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Icon(
                            Icons.check_circle,
                            color: Colors.teal,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
