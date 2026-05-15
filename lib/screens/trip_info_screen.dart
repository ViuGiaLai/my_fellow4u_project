import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';

class TripInfoScreen extends StatefulWidget {
  @override
  _TripInfoScreenState createState() => _TripInfoScreenState();
}

class _TripInfoScreenState extends State<TripInfoScreen> {
  DateTime? selectedDate;
  TimeOfDay? fromTime;
  TimeOfDay? toTime;
  int travelers = 1;
  final TextEditingController cityController = TextEditingController(text: "Danang");
  List<dynamic> selectedAttractions = [];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2025),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _createTrip() async {
    if (selectedDate == null) return;
    
    final tripRepo = TripRepository();
    final trip = Trip(
      title: "Trip to ${cityController.text}",
      destination: cityController.text,
      startDate: selectedDate!,
      endDate: selectedDate!,
      startTime: fromTime?.format(context),
      endTime: toTime?.format(context),
      travelerCount: travelers,
    );
    final success = await tripRepo.createTrip(trip);

    if (success != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Trip created successfully!")));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(context)),
        title: Text("Trip Information"),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              readOnly: true,
              onTap: () => _selectDate(context),
              decoration: InputDecoration(
                hintText: selectedDate == null ? "mm/dd/yy" : DateFormat('MM/dd/yyyy').format(selectedDate!),
                suffixIcon: Icon(Icons.calendar_today),
              ),
            ),
            SizedBox(height: 20),
            Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) setState(() => fromTime = time);
                    },
                    decoration: InputDecoration(hintText: fromTime?.format(context) ?? "From", prefixIcon: Icon(Icons.access_time)),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: TextField(
                    readOnly: true,
                    onTap: () async {
                      final time = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                      if (time != null) setState(() => toTime = time);
                    },
                    decoration: InputDecoration(hintText: toTime?.format(context) ?? "To", prefixIcon: Icon(Icons.access_time)),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("City", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(controller: cityController),
            SizedBox(height: 20),
            Text("Number of travelers", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                IconButton(icon: Icon(Icons.remove_circle_outline), onPressed: () => setState(() => travelers > 1 ? travelers-- : null)),
                Text("$travelers"),
                IconButton(icon: Icon(Icons.add_circle_outline), onPressed: () => setState(() => travelers++)),
              ],
            ),
            SizedBox(height: 20),
            Text("Attractions", style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                _buildAddButton(),
                ...selectedAttractions.map((attr) => _buildAttrCard(attr)).toList(),
              ],
            ),
            SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _createTrip,
                child: Text("DONE"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return InkWell(
      onTap: () {
        // Navigate to AddNewPlacesScreen
      },
      child: Container(
        width: 100,
        height: 80,
        decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [Icon(Icons.add, color: Colors.teal), Text("Add New", style: TextStyle(color: Colors.teal, fontSize: 12))],
        ),
      ),
    );
  }

  Widget _buildAttrCard(dynamic attr) {
    return Container(
      width: 100,
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        image: DecorationImage(image: NetworkImage(attr['image'] ?? ''), fit: BoxFit.cover),
      ),
      child: Align(
        alignment: Alignment.topRight,
        child: Icon(Icons.check_circle, color: Colors.teal, size: 20),
      ),
    );
  }
}
