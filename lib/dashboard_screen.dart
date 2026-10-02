import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'database_helper.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    _openDatabase();
  }

  Future<void> _openDatabase() async {
    try {
      final db = await DatabaseHelper.instance.database;
      debugPrint('DATABASE CREATED: ${db.path}');
    } catch (e) {
      debugPrint('DATABASE ERROR: $e');
    }
  }
  int currentIndex = 0;

  final List<Map<String, dynamic>> transactions = [
    {
      'title': 'Ăn trưa',
      'category': 'Ăn uống',
      'date': '03/09/2024',
      'amount': '-50.000 đ',
      'icon': Icons.restaurant,
      'iconColor': Color(0xFFFF7A22),
      'amountColor': Color(0xFFFF3B4A),
    },
    {
      'title': 'Xăng xe',
      'category': 'Di chuyển',
      'date': '03/09/2024',
      'amount': '-100.000 đ',
      'icon': Icons.directions_car,
      'iconColor': Color(0xFF2196F3),
      'amountColor': Color(0xFFFF3B4A),
    },
    {
      'title': 'Lương tháng 9',
      'category': 'Thu nhập',
      'date': '01/09/2024',
      'amount': '+8.000.000 đ',
      'icon': Icons.attach_money,
      'iconColor': Color(0xFF22B74A),
      'amountColor': Color(0xFF16A34A),
    },
    {
      'title': 'Mua sắm',
      'category': 'Mua sắm',
      'date': '31/08/2024',
      'amount': '-300.000 đ',
      'icon': Icons.shopping_cart,
      'iconColor': Color(0xFF9C45F5),
      'amountColor': Color(0xFFFF3B4A),
    },
    {
      'title': 'Học phí',
      'category': 'Giáo dục',
      'date': '30/08/2024',
      'amount': '-500.000 đ',
      'icon': Icons.school,
      'iconColor': Color(0xFF16A6A6),
      'amountColor': Color(0xFFFF3B4A),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // =========================
      // APP BAR
      // =========================
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,

        leading: IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.menu,
            color: Color(0xFF172B4D),
            size: 27,
          ),
        ),

        titleSpacing: 0,

        title: const Text(
          'Quản lý thu chi',
          style: TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        actions: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(
                  Icons.notifications_none,
                  color: Color(0xFF172B4D),
                  size: 28,
                ),
              ),

              Positioned(
                right: 5,
                top: 3,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF4D5A),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // =========================
      // BODY
      // =========================
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // =========================
              // THẺ SỐ DƯ
              // =========================
              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF4D83F6),
                      Color(0xFF1764D8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Stack(
                  children: [

                    // Nội dung số dư
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'SỐ DƯ HIỆN TẠI',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(width: 7),
                                Icon(
                                  Icons.visibility_outlined,
                                  color: Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            const Text(
                              '5.000.000 đ',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Icon ví tiền
                    Positioned(
                      right: 20,
                      top: 30,
                      child: _WalletIllustration(),
                    ),

                    // Dấu chấm
                    Positioned(
                      bottom: 9,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _indicator(true),
                          _indicator(false),
                          _indicator(false),
                          _indicator(false),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // =========================
              // THU NHẬP + CHI TIÊU
              // =========================
              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.arrow_downward,
                      iconColor: const Color(0xFF35B95A),
                      backgroundColor:
                      const Color(0xFFEFF9F0),
                      title: 'TỔNG THU NHẬP',
                      amount: '8.000.000 đ',
                      amountColor:
                      const Color(0xFF18A63B),
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: _SummaryCard(
                      icon: Icons.arrow_upward,
                      iconColor: const Color(0xFFFF525D),
                      backgroundColor:
                      const Color(0xFFFFEFF0),
                      title: 'TỔNG CHI TIÊU',
                      amount: '3.000.000 đ',
                      amountColor:
                      const Color(0xFFFF3647),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =========================
              // GIAO DỊCH GẦN ĐÂY
              // =========================
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      color: Color(0xFF172B4D),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color: Color(0xFF1976D2),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // =========================
              // DANH SÁCH GIAO DỊCH
              // =========================
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFE4E9EF),
                  ),
                ),

                child: Column(
                  children: List.generate(
                    transactions.length,
                        (index) {
                      final item = transactions[index];

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const EditTransactionScreen(),
                            ),
                          );
                        },
                        child: _TransactionItem(
                          title: item['title'],
                          category: item['category'],
                          date: item['date'],
                          amount: item['amount'],
                          icon: item['icon'],
                          iconColor: item['iconColor'],
                          amountColor: item['amountColor'],
                          isLast: index == transactions.length - 1,
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // =========================
      // NÚT +
      // =========================
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1976D2),
        elevation: 5,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTransactionScreen(),
            ),
          );
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 34,
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      // =========================
      // BOTTOM NAVIGATION
      // =========================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF1976D2),
        unselectedItemColor: const Color(0xFF424A57),
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }

  Widget _indicator(bool active) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 3),
      width: active ? 14 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active
            ? Colors.white
            : Colors.white.withOpacity(0.45),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}


// =====================================================
// WIDGET: THẺ TỔNG THU NHẬP / CHI TIÊU
// =====================================================

class _SummaryCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;
  final String title;
  final String amount;
  final Color amountColor;

  const _SummaryCard({
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
    required this.title,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10,
                    color: Color(0xFF5F6672),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  amount,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: amountColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// =====================================================
// WIDGET: GIAO DỊCH
// =====================================================

class _TransactionItem extends StatelessWidget {
  final String title;
  final String category;
  final String date;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color amountColor;
  final bool isLast;

  const _TransactionItem({
    required this.title,
    required this.category,
    required this.date,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.amountColor,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
          bottom: BorderSide(
            color: Color(0xFFEAECEF),
          ),
        ),
      ),
      child: Row(
        children: [

          // ICON
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 21,
            ),
          ),

          const SizedBox(width: 12),

          // TÊN + DANH MỤC
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF172B4D),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category,
                  style: const TextStyle(
                    color: Color(0xFF7A8494),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // NGÀY
          Text(
            date,
            style: const TextStyle(
              color: Color(0xFF9AA3AF),
              fontSize: 11,
            ),
          ),

          const SizedBox(width: 12),

          // SỐ TIỀN
          SizedBox(
            width: 92,
            child: Text(
              amount,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: amountColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// =====================================================
// WIDGET: VÍ TIỀN
// =====================================================

class _WalletIllustration extends StatelessWidget {
  const _WalletIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Tờ tiền
          Positioned(
            left: 22,
            top: 3,
            child: Transform.rotate(
              angle: 0.12,
              child: Container(
                width: 36,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFF77C96F),
                  borderRadius: BorderRadius.circular(3),
                  border: Border.all(
                    color: const Color(0xFF5DA957),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.attach_money,
                    color: Color(0xFF39883C),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // Tờ tiền thứ 2
          Positioned(
            left: 39,
            top: 7,
            child: Transform.rotate(
              angle: 0.19,
              child: Container(
                width: 34,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFF8BD67E),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
          ),

          // Thân ví
          Positioned(
            left: 14,
            bottom: 12,
            child: Container(
              width: 68,
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF3F68B5),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),

          // Khóa ví
          Positioned(
            left: 61,
            bottom: 28,
            child: Container(
              width: 24,
              height: 20,
              decoration: BoxDecoration(
                color: const Color(0xFF6B8CCC),
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),

          // Đồng xu
          Positioned(
            left: 7,
            bottom: 0,
            child: Row(
              children: [
                _coin(0),
                const SizedBox(width: 2),
                _coin(4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _coin(double rotation) {
    return Transform.rotate(
      angle: rotation / 10,
      child: Container(
        width: 24,
        height: 24,
        decoration: const BoxDecoration(
          color: Color(0xFFF7B82B),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.attach_money,
            color: Color(0xFF9B6D05),
            size: 15,
          ),
        ),
      ),
    );
  }
}