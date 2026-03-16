import 'package:flutter/material.dart';

/// [StatefulWidget] ⭐ - Quản lý trạng thái nhập liệu, chọn ngày và chọn địa điểm
class CreateNewTripPage extends StatefulWidget {
  const CreateNewTripPage({super.key});

  @override
  State<CreateNewTripPage> createState() => _CreateTripPageState();
}

class _CreateTripPageState extends State<CreateNewTripPage> {
  // Controller để quản lý và nhập số lượng khách
  final TextEditingController _travelersController = TextEditingController(
    text: "1",
  );
  // Controller để hiển thị ngày đã chọn
  final TextEditingController _dateController = TextEditingController();

  // Danh sách lưu trạng thái các địa điểm đã chọn (Index)
  final Set<int> _selectedAttractions = {}; 

  @override
  void dispose() {
    _travelersController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Hàm hiển thị bộ chọn ngày (Date Picker)
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.month}/${picked.day}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () {
            Navigator.of(context).maybePop();
          },
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
            /// 1. Where you want to explore (Có thể nhập được)
            _label("Where you want to explore"),
            _textField(Icons.location_on_outlined, "Vd: Danang, Vietnam"),

            const SizedBox(height: 20),

            /// 2. Date (Có thể nhập hoặc chọn từ lịch)
            _label("Date"),
            _textField(
              Icons.calendar_today_outlined,
              "mm/dd/yy",
              controller: _dateController,
              onTap: () => _selectDate(context),
            ),

            const SizedBox(height: 20),

            /// 3. Time (Có thể nhập được)
            _label("Time"),
            Row(
              children: [
                Expanded(child: _textField(Icons.access_time, "From")),
                const SizedBox(width: 20),
                Expanded(child: _textField(Icons.access_time, "To")),
              ],
            ),

            const SizedBox(height: 20),

            /// 4. Number of travelers (Có thể nhập số hoặc tăng giảm)
            _label("Number of travelers"),
            Row(
              children: [
                _counterBtn(Icons.arrow_drop_down, () {
                  int val = int.tryParse(_travelersController.text) ?? 1;
                  if (val > 1) {
                    _travelersController.text = (val - 1).toString();
                  }
                }),
                const SizedBox(width: 15),
                Container(
                  width: 80,
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5),
                    ),
                  ),
                  child: TextField(
                    controller: _travelersController,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
                const SizedBox(width: 15),
                _counterBtn(Icons.arrow_drop_up, () {
                  int val = int.tryParse(_travelersController.text) ?? 0;
                  _travelersController.text = (val + 1).toString();
                }),
              ],
            ),

            const SizedBox(height: 20),

            /// 5. Fee (Có thể nhập được)
            _label("Fee"),
            _textField(
              Icons.monetization_on_outlined,
              "Fee",
              suffix: "(\$/hour)",
            ),

            const SizedBox(height: 20),

            /// 6. Guide's Language (Có thể nhập được)
            _label("Guide's Language"),
            _textField(Icons.public, "Vd: Korean, English"),

            const SizedBox(height: 20),

            /// 7. Attractions (Có thể nhấn chọn/bỏ chọn) ⭐
            _label("Attractions"),
            const SizedBox(height: 10),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildAddButton(),
                _attractionCard(
                  1,
                  "Dragon Bridge",
                  "assets/images/DragonBridge.png",
                ),
                _attractionCard(
                  2,
                  "Cham Museum",
                  "assets/images/ChamMuseum.png",
                ),
                _attractionCard(
                  3,
                  "My Khe Beach",
                  "assets/images/MyKheBeach.png",
                ),
              ],
            ),

            const SizedBox(height: 30),

            /// Nút DONE
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C49F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  // Xử lý khi nhấn hoàn tất
                },
                child: const Text(
                  "DONE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
    ),
  );

  // Widget TextField cho phép nhập liệu tự do
  Widget _textField(
    IconData icon,
    String hint, {
    TextEditingController? controller,
    VoidCallback? onTap,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      onTap: onTap,
      readOnly:
          onTap !=
          null, // Nếu có hàm onTap (như chọn ngày) thì không cho nhập phím
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey, size: 20),
        suffixText: suffix,
        suffixStyle: const TextStyle(color: Colors.black54),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey, width: 0.5),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00C49F)),
        ),
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, color: const Color(0xFF00C49F), size: 28),
    ),
  );

  Widget _buildAddButton() => Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.add, color: Color(0xFF00C49F)),
        Text("Add New", style: TextStyle(color: Color(0xFF00C49F))),
      ],
    ),
  );

  // Widget Card địa điểm có tính năng nhấn để chọn/bỏ chọn
  Widget _attractionCard(int id, String name, String url) {
    bool isSelected = _selectedAttractions.contains(id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedAttractions.remove(id);
          } else {
            _selectedAttractions.add(id);
          }
        });
      },
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.transparent, Colors.black.withOpacity(0.6)],
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 8,
            child: Text(
              name,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          if (isSelected)
            const Positioned(
              top: 8,
              right: 8,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Color(0xFF00C49F),
                child: Icon(Icons.check, color: Colors.white, size: 12),
              ),
            ),
        ],
      ),
    );
  }
}
