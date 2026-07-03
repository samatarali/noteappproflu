import 'package:flutter/material.dart';

class CalendarMediaScreen extends StatefulWidget {
  const CalendarMediaScreen({super.key});

  @override
  State<CalendarMediaScreen> createState() => _CalendarMediaScreenState();
}

class _CalendarMediaScreenState extends State<CalendarMediaScreen> {
  // Halkan waxaad ku dari doontaa variables-ka calendar-ka iyo sawirada marka aad logic-ga dhisayso.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5FA),
      appBar: AppBar(
        title: const Text(
          "Calendar & Media Notes",
          style: TextStyle(
            color: Color(0xFF1A1A2E),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF1A1A2E), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========== CALENDAR SECTION ==========
            const Text(
              "Select Date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                  )
                ],
              ),
              child: const Center(
                child: Text(
                  "📅 Calendar Widget Goes Here\n(e.g., table_calendar package)",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF9E9EAE), fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ========== IMAGES SECTION ==========
            const Text(
              "Add Images",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    // Logic-ga sawirka lagu soo qaadayo (e.g., image_picker)
                  },
                  child: Container(
                    height: 80,
                    width: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEE9FF),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF6342E8).withOpacity(0.3), width: 1.5),
                    ),
                    child: const Icon(Icons.add_photo_alternate_rounded, color: Color(0xFF6342E8), size: 32),
                  ),
                ),
                // Halkan waxaa kasoo muuqan doona sawirada la doortay
              ],
            ),
            const SizedBox(height: 24),

            // ========== NOTE SECTION ==========
            const Text(
              "Description / Note",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            TextField(
              maxLines: 6,
              decoration: InputDecoration(
                hintText: "Write your note here...",
                hintStyle: const TextStyle(color: Color(0xFF9E9EAE)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 32),

            // ========== SAVE BUTTON ==========
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () {
                  // Logic-ga xogta lagu keydinayo
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6342E8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Save Note",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}