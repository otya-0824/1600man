import 'dart:async';
import 'package:flutter/material.dart';
import 'home.dart';
import 'first_time_profile.dart';
import 'meal_storage_service.dart';

class RoudoScreen extends StatefulWidget {
  const RoudoScreen({super.key});

  @override
  State<RoudoScreen> createState() => _RoudoScreenState();
}

class _RoudoScreenState extends State<RoudoScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _controller.forward();

    // 3秒のスプラッシュ後に、プロフィール登録状態で遷移先を振り分ける。
    // 未登録なら初回プロフィール設定、登録済みならホームへ。
    Timer(const Duration(seconds: 3), _goNext);
  }

  Future<void> _goNext() async {
    final isSaved = await MealStorageService.isProfileSaved();
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            isSaved ? HomePage() : const FirstTimeProfilePage(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF388E3C);
    const Color juiceGreen = Color(0xFF66BB6A);

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double progress = _controller.value;

          double poolHeight = screenHeight * progress;

          double streamHeight = screenHeight * (1 - progress);
          double streamOpacity = progress < 1 ? 1.0 : 0.0;

          return Stack(
            children: [
              if (streamOpacity > 0)
                Positioned(
                  top: 0,
                  left: screenWidth / 2 - 8,
                  width: 16,
                  height: streamHeight,
                  child: Opacity(
                    opacity: streamOpacity,
                    child: Container(
                      color: juiceGreen,
                    ),
                  ),
                ),

              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: poolHeight,
                  decoration: BoxDecoration(
                    color: juiceGreen.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25),
                      topRight: Radius.circular(25),
                    ),
                  ),
                ),
              ),

              SafeArea(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(
                        Icons.eco,
                        size: 80,
                        color: primaryGreen,
                      ),
                      SizedBox(height: 20),
                      Text(
                        'もぐバランス',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: primaryGreen,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'データを読み込んでいます...',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 30),
                      CircularProgressIndicator(
                        color: primaryGreen,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}