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
  int currentIndex = 0;

  List<Map<String, dynamic>> transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  // =====================================================
  // LOAD DỮ LIỆU TỪ SQLITE
  // =====================================================

  Future<void> _loadTransactions() async {
    try {
      final data =
      await DatabaseHelper.instance.getTransactions();

      if (!mounted) return;

      setState(() {
        transactions = data;
      });
    } catch (e) {
      debugPrint('DATABASE ERROR: $e');
    }
  }

  // =====================================================
  // TỔNG THU NHẬP
  // =====================================================

  double get totalIncome {
    double total = 0;

    for (final transaction in transactions) {
      if (transaction['type'] == 'income') {
        total +=
            (transaction['amount'] as num).toDouble();
      }
    }

    return total;
  }

  // =====================================================
  // TỔNG CHI TIÊU
  // =====================================================

  double get totalExpense {
    double total = 0;

    for (final transaction in transactions) {
      if (transaction['type'] == 'expense') {
        total +=
            (transaction['amount'] as num).toDouble();
      }
    }

    return total;
  }

  // =====================================================
  // SỐ DƯ
  // =====================================================

  double get balance {
    return totalIncome - totalExpense;
  }

  // =====================================================
  // FORMAT TIỀN
  // 50000 -> 50.000
  // =====================================================

  String formatMoney(double amount) {
    final isNegative = amount < 0;

    final value = amount.abs().round().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final positionFromEnd = value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return '${isNegative ? '-' : ''}${buffer.toString()}';
  }

  // =====================================================
  // FORMAT SỐ TIỀN GIAO DỊCH
  // =====================================================

  String displayAmount(
      Map<String, dynamic> item,
      ) {
    final amount =
    (item['amount'] as num).toDouble();

    final isIncome = item['type'] == 'income';

    return '${isIncome ? '+' : '-'}'
        '${formatMoney(amount)} đ';
  }

  // =====================================================
  // ICON THEO DANH MỤC
  // =====================================================

  IconData getIcon(
      String category,
      bool isIncome,
      ) {
    if (isIncome) {
      return Icons.attach_money;
    }

    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;

      case 'Di chuyển':
        return Icons.directions_car;

      case 'Mua sắm':
        return Icons.shopping_cart;

      case 'Giáo dục':
        return Icons.school;

      case 'Giải trí':
        return Icons.movie;

      default:
        return Icons.receipt_long;
    }
  }

  // =====================================================
  // MÀU ICON THEO DANH MỤC
  // =====================================================

  Color getIconColor(
      String category,
      bool isIncome,
      ) {
    if (isIncome) {
      return const Color(0xFF22B74A);
    }

    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFF7A22);

      case 'Di chuyển':
        return const Color(0xFF2196F3);

      case 'Mua sắm':
        return const Color(0xFF9C45F5);

      case 'Giáo dục':
        return const Color(0xFF16A6A6);

      case 'Giải trí':
        return const Color(0xFFFF9800);

      default:
        return const Color(0xFF64748B);
    }
  }

  // =====================================================
  // MỞ MÀN HÌNH THÊM
  // =====================================================

  Future<void> _openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
        const AddTransactionScreen(),
      ),
    );

    await _loadTransactions();
  }

  // =====================================================
  // MỞ MÀN HÌNH SỬA
  // =====================================================

  Future<void> _openEditTransaction(
      int transactionId,
      ) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            EditTransactionScreen(
              transactionId: transactionId,
            ),
      ),
    );

    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),

      // =================================================
      // APP BAR
      // =================================================

      appBar: AppBar(
        backgroundColor:
        const Color(0xFFF7F9FC),
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
                  decoration:
                  const BoxDecoration(
                    color: Color(0xFFFF4D5A),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      '3',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),

      // =================================================
      // BODY
      // =================================================

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            16,
            0,
            16,
            20,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              // =========================================
              // THẺ SỐ DƯ
              // =========================================

              Container(
                width: double.infinity,
                height: 170,
                decoration: BoxDecoration(
                  gradient:
                  const LinearGradient(
                    begin:
                    Alignment.topLeft,
                    end:
                    Alignment.bottomRight,
                    colors: [
                      Color(0xFF4D83F6),
                      Color(0xFF1764D8),
                    ],
                  ),
                  borderRadius:
                  BorderRadius.circular(18),
                ),
                child: Stack(
                  children: [

                    Align(
                      alignment:
                      Alignment.centerLeft,
                      child: Padding(
                        padding:
                        const EdgeInsets.only(
                          left: 28,
                        ),
                        child: Column(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [

                            const Row(
                              children: [
                                Text(
                                  'SỐ DƯ HIỆN TẠI',
                                  style: TextStyle(
                                    color:
                                    Colors.white,
                                    fontSize: 13,
                                    fontWeight:
                                    FontWeight.w500,
                                  ),
                                ),
                                SizedBox(
                                  width: 7,
                                ),
                                Icon(
                                  Icons
                                      .visibility_outlined,
                                  color:
                                  Colors.white,
                                  size: 18,
                                ),
                              ],
                            ),

                            const SizedBox(
                              height: 10,
                            ),

                            Text(
                              '${formatMoney(balance)} đ',
                              style:
                              const TextStyle(
                                color:
                                Colors.white,
                                fontSize: 36,
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Positioned(
                      right: 20,
                      top: 30,
                      child:
                      _WalletIllustration(),
                    ),

                    Positioned(
                      bottom: 9,
                      left: 0,
                      right: 0,
                      child: Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
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

              // =========================================
              // TỔNG THU + TỔNG CHI
              // =========================================

              Row(
                children: [

                  Expanded(
                    child: _SummaryCard(
                      icon:
                      Icons.arrow_downward,
                      iconColor:
                      const Color(
                        0xFF35B95A,
                      ),
                      backgroundColor:
                      const Color(
                        0xFFEFF9F0,
                      ),
                      title:
                      'TỔNG THU NHẬP',
                      amount:
                      '${formatMoney(totalIncome)} đ',
                      amountColor:
                      const Color(
                        0xFF18A63B,
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 10,
                  ),

                  Expanded(
                    child: _SummaryCard(
                      icon:
                      Icons.arrow_upward,
                      iconColor:
                      const Color(
                        0xFFFF525D,
                      ),
                      backgroundColor:
                      const Color(
                        0xFFFFEFF0,
                      ),
                      title:
                      'TỔNG CHI TIÊU',
                      amount:
                      '${formatMoney(totalExpense)} đ',
                      amountColor:
                      const Color(
                        0xFFFF3647,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // =========================================
              // TIÊU ĐỀ GIAO DỊCH
              // =========================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [

                  const Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      color: Color(0xFF172B4D),
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),

                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Xem tất cả',
                      style: TextStyle(
                        color:
                        Color(0xFF1976D2),
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              // =========================================
              // DANH SÁCH GIAO DỊCH
              // =========================================

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                  BorderRadius.circular(14),
                  border: Border.all(
                    color:
                    const Color(0xFFE4E9EF),
                  ),
                ),
                child: transactions.isEmpty
                    ? const Padding(
                  padding:
                  EdgeInsets.all(30),
                  child: Center(
                    child: Text(
                      'Chưa có giao dịch',
                      style: TextStyle(
                        color:
                        Color(0xFF7A8494),
                      ),
                    ),
                  ),
                )
                    : Column(
                  children:
                  List.generate(
                    transactions.length,
                        (index) {

                      final item =
                      transactions[
                      index];

                      final int id =
                      item['id'] as int;

                      final String title =
                          item['title']
                              ?.toString() ??
                              '';

                      final String category =
                          item['category']
                              ?.toString() ??
                              '';

                      final String date =
                          item['date']
                              ?.toString() ??
                              '';

                      final bool isIncome =
                          item['type'] ==
                              'income';

                      return GestureDetector(
                        onTap: () {
                          _openEditTransaction(
                            id,
                          );
                        },
                        child:
                        _TransactionItem(
                          title: title,
                          category:
                          category,
                          date: date,
                          amount:
                          displayAmount(
                            item,
                          ),
                          icon:
                          getIcon(
                            category,
                            isIncome,
                          ),
                          iconColor:
                          getIconColor(
                            category,
                            isIncome,
                          ),
                          amountColor:
                          isIncome
                              ? const Color(
                            0xFF16A34A,
                          )
                              : const Color(
                            0xFFFF3B4A,
                          ),
                          isLast:
                          index ==
                              transactions
                                  .length -
                                  1,
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

      // =================================================
      // NÚT +
      // =================================================

      floatingActionButton:
      FloatingActionButton(
        backgroundColor:
        const Color(0xFF1976D2),
        elevation: 5,
        onPressed:
        _openAddTransaction,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 34,
        ),
      ),

      floatingActionButtonLocation:
      FloatingActionButtonLocation.endFloat,

      // =================================================
      // BOTTOM NAVIGATION
      // =================================================

      bottomNavigationBar:
      BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        backgroundColor: Colors.white,
        type:
        BottomNavigationBarType.fixed,
        selectedItemColor:
        const Color(0xFF1976D2),
        unselectedItemColor:
        const Color(0xFF424A57),
        selectedLabelStyle:
        const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        items: const [
          BottomNavigationBarItem(
            icon:
            Icon(Icons.home_outlined),
            activeIcon:
            Icon(Icons.home),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.receipt_long_outlined,
            ),
            activeIcon: Icon(
              Icons.receipt_long,
            ),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.pie_chart_outline,
            ),
            activeIcon: Icon(
              Icons.pie_chart,
            ),
            label: 'Thống kê',
          ),
        ],
      ),
    );
  }

  // =====================================================
  // INDICATOR
  // =====================================================

  Widget _indicator(bool active) {
    return Container(
      margin:
      const EdgeInsets.symmetric(
        horizontal: 3,
      ),
      width: active ? 14 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: active
            ? Colors.white
            : Colors.white.withValues(
          alpha: 0.45,
        ),
        borderRadius:
        BorderRadius.circular(10),
      ),
    );
  }
}

// =======================================================
// SUMMARY CARD
// =======================================================

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
      padding:
      const EdgeInsets.symmetric(
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: Row(
        children: [

          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withValues(
                alpha: 0.15,
              ),
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
              mainAxisAlignment:
              MainAxisAlignment.center,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    fontSize: 10,
                    color:
                    Color(0xFF5F6672),
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  amount,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14,
                    color: amountColor,
                    fontWeight:
                    FontWeight.bold,
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

// =======================================================
// TRANSACTION ITEM
// =======================================================

class _TransactionItem
    extends StatelessWidget {

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
      padding:
      const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 11,
      ),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
          bottom: BorderSide(
            color:
            Color(0xFFEAECEF),
          ),
        ),
      ),
      child: Row(
        children: [

          Container(
            width: 42,
            height: 42,
            decoration:
            BoxDecoration(
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

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [

                Text(
                  title,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF172B4D),
                    fontSize: 14,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  category,
                  maxLines: 1,
                  overflow:
                  TextOverflow.ellipsis,
                  style:
                  const TextStyle(
                    color:
                    Color(0xFF7A8494),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Text(
            date,
            style: const TextStyle(
              color:
              Color(0xFF9AA3AF),
              fontSize: 10,
            ),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 88,
            child: Text(
              amount,
              textAlign:
              TextAlign.right,
              maxLines: 1,
              overflow:
              TextOverflow.ellipsis,
              style: TextStyle(
                color: amountColor,
                fontSize: 12,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =======================================================
// WALLET ILLUSTRATION
// =======================================================

class _WalletIllustration
    extends StatelessWidget {

  const _WalletIllustration();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [

          // TỜ TIỀN 1
          Positioned(
            left: 22,
            top: 3,
            child:
            Transform.rotate(
              angle: 0.12,
              child: Container(
                width: 36,
                height: 55,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFF77C96F,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(3),
                  border: Border.all(
                    color:
                    const Color(
                      0xFF5DA957,
                    ),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.attach_money,
                    color:
                    Color(0xFF39883C),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

          // TỜ TIỀN 2
          Positioned(
            left: 39,
            top: 7,
            child:
            Transform.rotate(
              angle: 0.19,
              child: Container(
                width: 34,
                height: 52,
                decoration:
                BoxDecoration(
                  color:
                  const Color(
                    0xFF8BD67E,
                  ),
                  borderRadius:
                  BorderRadius
                      .circular(3),
                ),
              ),
            ),
          ),

          // THÂN VÍ
          Positioned(
            left: 14,
            bottom: 12,
            child: Container(
              width: 68,
              height: 55,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFF3F68B5,
                ),
                borderRadius:
                BorderRadius
                    .circular(10),
              ),
            ),
          ),

          // KHÓA VÍ
          Positioned(
            left: 61,
            bottom: 28,
            child: Container(
              width: 24,
              height: 20,
              decoration:
              BoxDecoration(
                color:
                const Color(
                  0xFF6B8CCC,
                ),
                borderRadius:
                BorderRadius
                    .circular(5),
              ),
              child: const Center(
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor:
                  Colors.white,
                ),
              ),
            ),
          ),

          // ĐỒNG XU
          Positioned(
            left: 7,
            bottom: 0,
            child: Row(
              children: [
                _coin(0),
                const SizedBox(
                  width: 2,
                ),
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
        decoration:
        const BoxDecoration(
          color:
          Color(0xFFF7B82B),
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.attach_money,
            color:
            Color(0xFF9B6D05),
            size: 15,
          ),
        ),
      ),
    );
  }
}