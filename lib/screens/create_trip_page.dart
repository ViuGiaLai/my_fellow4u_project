import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/api_service.dart';
import '../models/trip.dart';
import '../repositories/trip_repository.dart';
import '../widgets/widgets.dart';

class CreateNewTripPage extends StatefulWidget {
  const CreateNewTripPage({super.key});

  @override
  State<CreateNewTripPage> createState() => _CreateNewTripPageState();
}

class _CreateNewTripPageState extends State<CreateNewTripPage> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _travelersController = TextEditingController(
    text: "1",
  );
  final TextEditingController _feeController = TextEditingController();
  final TextEditingController _languagesController = TextEditingController();

  DateTime? _selectedDate;
  PlatformFile? _selectedFile;

  bool _isLoading = false;

  //  CHỌN FILE (Hỗ trợ Web & Mobile) 
  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true, // Bắt buộc để lấy bytes trên Web
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã chọn hình ảnh'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi khi chọn hình: $e')));
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _createTrip() async {
    setState(() => _isLoading = true);

    try {
      String? imageUrl;

      // Upload image if selected
      if (_selectedFile != null) {
        String fileName = 'trip_${DateTime.now().millisecondsSinceEpoch}';
        
        // Get file bytes
        Uint8List fileBytes;
        if (kIsWeb && _selectedFile!.bytes != null) {
          fileBytes = _selectedFile!.bytes!;
        } else if (!kIsWeb && _selectedFile!.path != null) {
          fileBytes = await File(_selectedFile!.path!).readAsBytes();
        } else {
          throw Exception('Cannot read file bytes');
        }

        imageUrl = await ApiService.uploadTripImage(fileBytes, fileName);
        if (imageUrl == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Lỗi upload hình ảnh'),
              backgroundColor: Colors.orange,
            ),
          );
          // Continue anyway with null imageUrl
        }
      }

      final tripRepo = TripRepository();
      final trip = Trip(
        title: "Trip to ${_destinationController.text}",
        destination: _destinationController.text,
        startDate: _selectedDate ?? DateTime.now(),
        endDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
        startTime: "09:00",
        endTime: "17:00",
        travelerCount: int.tryParse(_travelersController.text) ?? 1,
        maxBudget: double.tryParse(_feeController.text),
        requiredLanguages:
            _languagesController.text.split(',').map((e) => e.trim()).toList(),
        imageUrl: imageUrl,
      );
      final result = await tripRepo.createTrip(trip);

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tạo chuyến đi thành công!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Hiển thị ảnh đã chọn, hỗ trợ cả Web (bytes) và Mobile (path)
  Widget _buildSelectedImage() {
    if (_selectedFile == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            "Chọn hình ảnh cho chuyến đi",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    // Web: dùng bytes
    if (kIsWeb) {
      final Uint8List? bytes = _selectedFile!.bytes;
      if (bytes != null) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(bytes, fit: BoxFit.cover, width: double.infinity),
        );
      }
      return const Center(child: Text("Không thể hiển thị ảnh"));
    }

    // Mobile: dùng path
    final String? path = _selectedFile!.path;
    if (path != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          File(path),
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      );
    }

    return const Center(child: Text("Không thể hiển thị ảnh"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Create New Trip",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Where you want to explore",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _destinationController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.location_on_outlined),
                hintText: "e.g. Danang, Vietnam",
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
            GestureDetector(
              onTap: _selectDate,
              child: AbsorbPointer(
                child: TextField(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.calendar_today_outlined),
                    hintText:
                        _selectedDate != null
                            ? "${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}"
                            : "mm/dd/yy",
                    border: const UnderlineInputBorder(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(child: _timeField("From")),
                const SizedBox(width: 16),
                Expanded(child: _timeField("To")),
              ],
            ),

            const SizedBox(height: 24),

            const Text(
              "Number of travelers",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            _travelerCounter(),

            const SizedBox(height: 24),

            const Text("Fee", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: _feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.monetization_on_outlined),
                hintText: "Fee",
                suffixText: "(\$/hour)",
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Guide's Language",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            TextField(
              controller: _languagesController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.public),
                hintText: "e.g. Korean, English",
                border: UnderlineInputBorder(),
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Trip Image",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: _buildSelectedImage(),
              ),
            ),

            const SizedBox(height: 40),

            CustomButton(
              text: 'DONE',
              onPressed: _isLoading ? null : _createTrip,
              isLoading: _isLoading,
              height: 52,
            ),
          ],
        ),
      ),
    );
  }

  Widget _timeField(String hint) {
    return TextField(
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.access_time),
        hintText: hint,
        border: const UnderlineInputBorder(),
      ),
    );
  }

  Widget _travelerCounter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _counterBtn(Icons.remove, () {
          int val = int.tryParse(_travelersController.text) ?? 1;
          if (val > 1) {
            setState(() {
              _travelersController.text = (val - 1).toString();
            });
          }
        }),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            _travelersController.text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        _counterBtn(Icons.add, () {
          int val = int.tryParse(_travelersController.text) ?? 1;
          setState(() {
            _travelersController.text = (val + 1).toString();
          });
        }),
      ],
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: const Color(0xFF00C49F)),
    ),
  );
}
