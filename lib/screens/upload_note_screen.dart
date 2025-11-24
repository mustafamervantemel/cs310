import 'package:flutter/material.dart';
import '../utils/app_colors2.dart';

class UploadNoteScreen extends StatefulWidget {
  const UploadNoteScreen({super.key});

  @override
  State<UploadNoteScreen> createState() => _UploadNoteScreenState();
}

class _UploadNoteScreenState extends State<UploadNoteScreen> {
  final TextEditingController courseController = TextEditingController();
  final TextEditingController definitionController = TextEditingController();
  final TextEditingController fileController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF171B34);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white, size: 26),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: Stack(
        children: [
          // LEFT BACKGROUND CIRCLE
          Positioned(
            left: -80,
            top: 120,
            child: Container(
              width: 240,
              height: 240,
              decoration: const BoxDecoration(
                color: Color(0xFFD4F2FA),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // RIGHT BACKGROUND CIRCLE
          Positioned(
            right: -80,
            bottom: -20,
            child: Container(
              width: 260,
              height: 260,
              decoration: const BoxDecoration(
                color: Color(0xFFD4F2FA),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 10),

                const Center(
                  child: Text(
                    "Upload Note",
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // WHITE CARD
                Container(
                  margin: const EdgeInsets.all(22),
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                  ),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _label("COURSE NAME"),
                      _textField(courseController, "Type your course name..."),

                      const SizedBox(height: 24),

                      _label("NOTE DEFINITION"),
                      _textArea(definitionController, "Type your definition..."),

                      const SizedBox(height: 24),

                      _label("NOTE"),
                      _textField(fileController, "Select the file you want to upload"),

                      const SizedBox(height: 30),

                      // UPLOAD BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors2.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Upload Note",
                                style: TextStyle(fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.cloud_upload_outlined, color: Colors.white),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        letterSpacing: 1.2,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _textField(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors2.greyText),
          filled: true,
          fillColor: AppColors2.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }

  Widget _textArea(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      child: TextField(
        controller: controller,
        maxLines: 5,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors2.greyText),
          filled: true,
          fillColor: AppColors2.lightGrey,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        ),
      ),
    );
  }
}
