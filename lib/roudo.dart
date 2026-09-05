import 'package:flutter/material.dart';

class RoudoScreen extends StatefulWidget {
  const RoudoScreen({super.key});

  @override
  State<RoudoScreen> createState() => _RoudoScreenState();
}

class _RoudoScreenState extends State<RoudoScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  
  // アニメーションの進行度（0.0 〜 1.0）
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000), // 全体3秒
    );
    _controller.value = 0.0;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startLoading() {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    _controller.forward(from: 0.0).then((_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('栄養ジュースが溜まりました！ロード完了！')),
        );
      }
    });
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
          double progress = _controller.value; // 0.0 〜 1.0

          // ① 下から溜まっていく液体の高さ（最高位）を先に計算
          double poolHeight = 0.0;
          if (progress > 0.1) {
            double poolProgress = (progress - 0.1) / 0.9; // 0.1〜1.0の間で溜まる
            poolHeight = screenHeight * poolProgress;
          }

          // ② 細い線の処理
          double streamHeight = 0.0;
          double streamOpacity = 0.0;

          if (progress > 0.0 && progress <= 0.3) {
            double p = progress / 0.3;
            streamHeight = screenHeight * p;
            streamOpacity = p <= 0.2 ? (p / 0.2) : 1.0;
          } else if (progress > 0.3) {
            streamOpacity = 1.0;
            double remainingHeight = screenHeight - poolHeight;
            streamHeight = remainingHeight > 0 ? remainingHeight : 0;
            
            if (poolHeight >= screenHeight) {
              streamOpacity = 0.0;
            }
          }

          return Stack(
            children: [
              // 1. 【上から落ちてきて、溜まる液体の水面から順に消えていく細い線】
              if (streamOpacity > 0 && streamHeight > 0)
                Positioned(
                  top: 0,
                  left: screenWidth / 2 - 8,
                  width: 16,
                  height: streamHeight,
                  child: Opacity(
                    opacity: streamOpacity.clamp(0.0, 1.0),
                    child: Container(
                      color: juiceGreen,
                    ),
                  ),
                ),

              // 2. 【下からだんだん溜まっていく液体】
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  height: poolHeight,
                  decoration: BoxDecoration(
                    color: juiceGreen.withValues(alpha: 0.85),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(25.0),
                      topRight: Radius.circular(25.0),
                    ),
                  ),
                ),
              ),

              // 3. 【手前の文字やボタン】
              SafeArea(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.eco,
                          size: 80,
                          color: primaryGreen,
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          '食事健康アプリ',
                          style: TextStyle(
                            fontSize: 28.0,
                            fontWeight: FontWeight.bold,
                            color: primaryGreen,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _isLoading ? '栄養ジュースを注いでいます...' : 'ボタンを押してジュースを注ぐ',
                          style: TextStyle(
                            fontSize: 16.0,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(height: 50),

                        // 注ぎ始めるボタン
                        SizedBox(
                          width: double.infinity,
                          height: 50.0,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _startLoading,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryGreen,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25.0),
                              ),
                              elevation: 4,
                            ),
                            child: Text(
                              _isLoading ? '注ぎ中...' : 'ジュースを注ぐ',
                              style: const TextStyle(
                                fontSize: 18.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
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