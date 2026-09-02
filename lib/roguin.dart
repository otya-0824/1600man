import 'package:flutter/material.dart';
import 'roudo.dart';

void main() {
  runApp(const CaloMimicApp());
}

class CaloMimicApp extends StatelessWidget {
  const CaloMimicApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF388E3C);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '鬟滉ｺ句▼蠎ｷ繧｢繝励Μ',
      theme: ThemeData(
        primaryColor: primaryGreen,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: primaryGreen,
        ),
      ),
      home: const CaloMimicHomePage(),
    );
  }
}

class CaloMimicHomePage extends StatefulWidget {
  const CaloMimicHomePage({super.key});

  @override
  State<CaloMimicHomePage> createState() => _CaloMimicHomePageState();
}

class _CaloMimicHomePageState extends State<CaloMimicHomePage> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    const Color primaryGreen = Color(0xFF388E3C);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // 笘�縺薙％縺ｫ縺ゅ▲縺滓凾髢薙ｄ繧｢繧､繧ｳ繝ｳ縺ｮ繧ｳ繝ｼ繝峨ｒ蜑企勁縺励∪縺励◆
        title: const Text(''), 
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    const SizedBox(height: 80.0), // 繧ｹ繝�繝ｼ繧ｿ繧ｹ繝舌�ｼ蜑企勁蛻�縲∝ｰ代＠荳企Κ菴咏區繧定ｪｿ謨ｴ
                    Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4)),
                        ],
                      ),
                      child: const Center(
                        child: Icon(Icons.eco, size: 50, color: primaryGreen),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    // 笘�縺薙％繧偵碁｣滉ｺ句▼蠎ｷ繧｢繝励Μ縲阪↓螟画峩縺励∪縺励◆
                    const Text(
                      '鬟滉ｺ句▼蠎ｷ繧｢繝励Μ',
                      style: TextStyle(
                        fontSize: 28.0,
                        fontWeight: FontWeight.bold,
                        color: primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 50.0),
                    _buildTextField(
                      hintText: '繝｡繝ｼ繝ｫ繧｢繝峨Ξ繧ｹ',
                      prefixIcon: Icons.email_outlined,
                    ),
                    const SizedBox(height: 20.0),
                    _buildTextField(
                      hintText: '繝代せ繝ｯ繝ｼ繝�',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                    ),
                    const SizedBox(height: 30.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          '繝ｭ繧ｰ繧､繝ｳ',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30.0),
                    TextButton(
                      onPressed: () {},
                      child: const Text(
                        '繝代せ繝ｯ繝ｼ繝峨ｒ蠢倥ｌ縺滓婿縺ｯ縺薙■繧�',
                        style: TextStyle(
                          color: primaryGreen,
                          fontSize: 14.0,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Text('縺ｾ縺溘�ｯ', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 20.0),
                    SizedBox(
                      width: double.infinity,
                      height: 50.0,
                      child: OutlinedButton(
                        onPressed: () {},
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.grey, width: 1.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          '譁ｰ隕冗匳骭ｲ',
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
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
      ),
    );
  }

  Widget _buildTextField({required String hintText, required IconData prefixIcon, bool isPassword = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
        ],
      ),
      child: TextField(
        obscureText: isPassword ? _obscurePassword : false,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey.shade400),
          prefixIcon: Icon(prefixIcon, color: Colors.grey.shade600, size: 22),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey.shade600,
                    size: 22,
                  ),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
        ),
      ),
    );
  }
}