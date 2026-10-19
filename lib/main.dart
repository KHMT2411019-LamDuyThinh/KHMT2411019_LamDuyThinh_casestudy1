import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Color(0xFFFCFDFE),
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFFCFDFE),
        useMaterial3: false,
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFDFE),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Dùng chiều rộng làm cơ sở để khoảng cách và cỡ chữ
            // giữ được tỉ lệ gần mẫu trên những màn hình cao khác nhau.
            final screenWidth = constraints.maxWidth;
            final walletSize = (screenWidth * 0.37).clamp(100.0, 132.0);
            final walletTop = screenWidth * 0.43;
            final titleTop = screenWidth * 0.86;
            final descriptionTop = screenWidth * 1.04;
            final buttonHeight = (screenWidth * 0.135).clamp(44.0, 54.0);
            final buttonBottom = screenWidth * 0.24;

            return Stack(
              children: [
                Positioned(
                  top: walletTop,
                  left: 0,
                  right: 0,
                  child: Center(child: WalletIcon(size: walletSize)),
                ),
                Positioned(
                  top: titleTop,
                  left: 16,
                  right: 16,
                  child: Text(
                    'Expense Manager',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: TextStyle(
                      color: const Color(0xFF172B4D),
                      fontSize: (screenWidth * 0.08).clamp(25.0, 32.0).toDouble(),
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.35,
                    ),
                  ),
                ),
                Positioned(
                  top: descriptionTop,
                  left: 16,
                  right: 16,
                  child: Text(
                    'Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFF7D899B),
                      fontSize: (screenWidth * 0.047).clamp(15.0, 19.0).toDouble(),
                      height: 1.45,
                    ),
                  ),
                ),
                Positioned(
                  bottom: buttonBottom,
                  left: 24,
                  right: 24,
                  child: SizedBox(
                    height: buttonHeight,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DashboardScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        elevation: 1,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        'Bắt đầu',
                        style: TextStyle(
                          fontSize: (screenWidth * 0.052).clamp(16.0, 21.0).toDouble(),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class WalletIcon extends StatelessWidget {
  final double size;

  const WalletIcon({super.key, this.size = 112});

  @override
  Widget build(BuildContext context) {
    final walletWidth = size * 1.18;

    return SizedBox(
      width: walletWidth,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Tờ tiền phía sau ví.
          Positioned(
            left: walletWidth * 0.35,
            top: size * 0.015,
            child: Transform.rotate(
              angle: -0.30,
              child: Container(
                width: walletWidth * 0.54,
                height: size * 0.28,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF51BD72), Color(0xFF159B58)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(size * 0.055),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x192B8050),
                      blurRadius: 3,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    width: walletWidth * 0.12,
                    height: size * 0.12,
                    margin: EdgeInsets.all(size * 0.035),
                    decoration: BoxDecoration(
                      color: const Color(0xFF8BD99A),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: walletWidth * 0.27,
            top: size * 0.10,
            child: Transform.rotate(
              angle: -0.12,
              child: Container(
                width: walletWidth * 0.58,
                height: size * 0.25,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6CCB80), Color(0xFF279D5F)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(size * 0.045),
                ),
              ),
            ),
          ),
          // Thân ví màu xanh dương.
          Positioned(
            left: 0,
            top: size * 0.26,
            child: Container(
              width: walletWidth * 0.91,
              height: size * 0.64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2789F5), Color(0xFF0864D7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(size * 0.12),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x25245FA8),
                    blurRadius: 5,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
          ),
          // Nắp khóa nhô sang bên phải.
          Positioned(
            right: 0,
            top: size * 0.46,
            child: Container(
              width: walletWidth * 0.40,
              height: size * 0.27,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF1677E8), Color(0xFF0756BA)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(size * 0.075),
                border: Border.all(
                  color: const Color(0xFF0759BF),
                  width: 0.7,
                ),
              ),
              child: Center(
                child: Container(
                  width: size * 0.105,
                  height: size * 0.105,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF8FBFF),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Color(0x22000000),
                        blurRadius: 1,
                        offset: Offset(0, 1),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
