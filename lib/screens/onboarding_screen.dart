import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: 'FIND NOTES\nEASILY',
      icon: Icons.search,
      color: AppColors.coral,
    ),
    OnboardingData(
      title: 'UPLOAD AND EARN\nRECOGNITION',
      icon: Icons.cloud_upload_outlined,
      color: AppColors.coral,
    ),
    OnboardingData(
      title: 'TRUSTED BY\nSABANCI STUDENTS',
      icon: Icons.school_outlined,
      color: AppColors.coral,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            // Page Indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildDot(index),
                ),
              ),
            ),
            // Skip/ATLA Button
            Padding(
              padding: const EdgeInsets.only(bottom: 40, right: 24, left: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _nextPage,
                    child: Text(
                      _currentPage == _pages.length - 1 ? 'GET STARTED' : 'ATLA',
                      style: const TextStyle(
                        color: AppColors.coral,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 60),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: data.color, width: 3),
            ),
            child: Icon(
              data.icon,
              size: 80,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 6),
      width: _currentPage == index ? 24 : 12,
      height: 12,
      decoration: BoxDecoration(
        color: _currentPage == index ? AppColors.coral : Colors.white24,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final IconData icon;
  final Color color;

  OnboardingData({
    required this.title,
    required this.icon,
    required this.color,
  });
}
