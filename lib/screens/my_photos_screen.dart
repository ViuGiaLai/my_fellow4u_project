import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';
import '../services/api_service.dart';

class MyPhotosScreen extends StatefulWidget {
  const MyPhotosScreen({super.key});

  @override
  State<MyPhotosScreen> createState() => _MyPhotosScreenState();
}

class _MyPhotosScreenState extends State<MyPhotosScreen> {
  List<dynamic> _photos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPhotos();
  }

  Future<void> _loadPhotos() async {
    setState(() => _isLoading = true);
    try {
      final photos = await ApiService.getUserPhotos();
      setState(() {
        _photos = photos;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading photos: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addPhoto() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final bytes = file.bytes;
        final fileName = file.name;
        
        if (bytes != null) {
          final uploadResult = await ApiService.uploadPhoto(bytes, fileName, null);
          
          if (uploadResult != null) {
            _loadPhotos(); // Refresh photos
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Photo uploaded successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to upload photo'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error adding photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error uploading photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deletePhoto(String photoId) async {
    try {
      final success = await ApiService.deletePhoto(photoId);
      if (success) {
        _loadPhotos(); // Refresh photos
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Photo deleted successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to delete photo'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Error deleting photo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error deleting photo'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Photos',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF3EC8B0)),
            )
          : RefreshIndicator(
              onRefresh: _loadPhotos,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _photos.length + 1, // Add Photos button + photos
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // Add Photos button
                      return _buildAddPhotosButton();
                    } else {
                      // Photo items
                      return _buildPhotoItem(_photos[index - 1]);
                    }
                  },
                ),
              ),
            ),
    );
  }

  Widget _buildAddPhotosButton() {
    return GestureDetector(
      onTap: _addPhoto,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFF3EC8B0), width: 2),
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFFE8F5F3),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              size: 40,
              color: const Color(0xFF3EC8B0),
            ),
            const SizedBox(height: 8),
            const Text(
              'Add Photos',
              style: TextStyle(
                color: Color(0xFF3EC8B0),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoItem(dynamic photo) {
    final String photoUrl = photo['url'] ?? '';
    final String photoId = photo['id']?.toString() ?? '';
    final String description = photo['description'] ?? '';

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[200],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Load network image
            Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image,
                    size: 40,
                    color: Colors.grey[600],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF3EC8B0),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
            ),
            // Delete button overlay
            Positioned(
              top: 8,
              right: 8,
              child: GestureDetector(
                onTap: () => _showDeleteDialog(photoId),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(String photoId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Photo'),
        content: const Text('Are you sure you want to delete this photo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deletePhoto(photoId);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
