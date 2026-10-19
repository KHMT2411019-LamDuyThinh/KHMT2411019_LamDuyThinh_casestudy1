import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'database_helper.dart';
import 'filter_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int currentIndex = 0;
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  bool hideBalance = false;
  String _statisticsPeriod = 'Tháng này';

  // Trạng thái riêng cho màn hình Giao dịch (màn hình số 3).
  String _transactionSearchQuery = '';
  final TextEditingController _transactionSearchController = TextEditingController();
  String _transactionTypeFilter = 'all';
  String _transactionCategoryFilter = 'Tất cả danh mục';
  String _transactionPeriodFilter = 'all';
  DateTime? _transactionStartDate;
  DateTime? _transactionEndDate;

  static const Color primaryBlue = Color(0xFF0878F9);
  static const Color darkBlue = Color(0xFF10264D);
  static const Color backgroundColor = Color(0xFFF5F8FC);

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _transactionSearchController.dispose();
    super.dispose();
  }

  Future<void> _loadTransactions() async {
    try {
      final data = await DatabaseHelper.instance.getTransactions();
      if (!mounted) return;
      setState(() {
        transactions = data;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('DATABASE ERROR: $e');
      if (!mounted) return;
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không thể tải dữ liệu giao dịch.')),
      );
    }
  }

  double get totalIncome => transactions.fold<double>(0, (total, item) {
    if (item['type'] == 'income') {
      return total + ((item['amount'] as num?)?.toDouble() ?? 0);
    }
    return total;
  });

  double get totalExpense => transactions.fold<double>(0, (total, item) {
    if (item['type'] == 'expense') {
      return total + ((item['amount'] as num?)?.toDouble() ?? 0);
    }
    return total;
  });

  double get balance => totalIncome - totalExpense;

  String formatMoney(double amount) {
    final value = amount.abs().round().toString();
    final buffer = StringBuffer();
    for (int i = 0; i < value.length; i++) {
      buffer.write(value[i]);
      final remaining = value.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write('.');
    }
    return '${amount < 0 ? '-' : ''}$buffer';
  }

  String displayAmount(Map<String, dynamic> item) {
    final amount = (item['amount'] as num?)?.toDouble() ?? 0;
    final isIncome = item['type'] == 'income';
    return '${isIncome ? '+' : '-'}${formatMoney(amount)} đ';
  }

  DateTime? _parseDate(dynamic value) {
    if (value == null) return null;
    final text = value.toString().trim();
    final parsed = DateTime.tryParse(text);
    if (parsed != null) return parsed;

    final parts = text.split('/');
    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      if (day != null && month != null && year != null) {
        return DateTime(year, month, day);
      }
    }
    return null;
  }

  List<Map<String, dynamic>> get sortedTransactions {
    final result = List<Map<String, dynamic>>.from(transactions);
    result.sort((a, b) {
      final dateA = _parseDate(a['date']);
      final dateB = _parseDate(b['date']);
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return dateB.compareTo(dateA);
    });
    return result;
  }

  IconData getIcon(String category, bool isIncome) {
    if (isIncome) return Icons.account_balance_wallet_rounded;
    switch (category) {
      case 'Ăn uống':
      case 'Ăn uống ':
        return Icons.restaurant_rounded;
      case 'Di chuyển':
      case 'Xăng':
        return Icons.directions_car_filled_rounded;
      case 'Mua sắm':
      case 'Đồ dùng sinh hoạt':
        return Icons.shopping_cart_rounded;
      case 'Giáo dục':
      case 'Tiền học':
        return Icons.menu_book_rounded;
      case 'Giải trí':
      case 'Nạp Game':
        return Icons.sports_esports_rounded;
      case 'Lương':
        return Icons.payments_rounded;
      default:
        return Icons.receipt_long_rounded;
    }
  }

  Color getIconColor(String category, bool isIncome) {
    if (isIncome) return const Color(0xFF28BD70);
    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFF5964);
      case 'Di chuyển':
      case 'Xăng':
        return const Color(0xFF9B5CF6);
      case 'Mua sắm':
      case 'Đồ dùng sinh hoạt':
        return const Color(0xFF18A9EE);
      case 'Giáo dục':
      case 'Tiền học':
        return const Color(0xFF8D5CF6);
      case 'Giải trí':
      case 'Nạp Game':
        return const Color(0xFFFFA51F);
      default:
        return const Color(0xFF14B8A6);
    }
  }

  Future<void> _openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddTransactionScreen()),
    );
    if (mounted) await _loadTransactions();
  }

  Future<void> _openEditTransaction(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(transactionId: id),
      ),
    );
    if (mounted) await _loadTransactions();
  }

  void _selectTab(int index) {
    setState(() => currentIndex = index);
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: IndexedStack(
        index: currentIndex,
        children: [
          _buildDashboard(),
          _buildTransactionList(),
          _buildStatistics(),
          _buildProfile(),
        ],
      ),
      // Theo mẫu, nút + chỉ hiện ở các tab khác, không hiện trong màn hình Giao dịch.
      floatingActionButton: currentIndex == 1
          ? null
          : FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 31),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: _selectTab,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: primaryBlue,
        unselectedItemColor: const Color(0xFF718096),
        selectedLabelStyle:
        const TextStyle(fontWeight: FontWeight.w600, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Trang chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long_rounded),
            label: 'Giao dịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 28),
        children: [
          SizedBox(
            // Chiếm đủ chiều cao cho thẻ số dư và hai thẻ tổng quan,
            // tránh để tiêu đề giao dịch chồng lên mép thẻ bên dưới.
            height: 390,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Nền xanh nằm ở lớp sau để không che phần thẻ số dư.
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 200,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.of(context).padding.top + 11,
                      20,
                      0,
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF1687FF), Color(0xFF0863E5)],
                      ),
                      borderRadius: BorderRadius.vertical(
                        bottom: Radius.circular(26),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Xin chào!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Hôm nay, là một ngày tốt lành!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        ),
                        InkWell(
                          onTap: () => _selectTab(3),
                          borderRadius: BorderRadius.circular(30),
                          child: const CircleAvatar(
                            radius: 25,
                            backgroundColor: Color(0xFF80B9FF),
                            child: Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Thẻ số dư và hai thẻ tổng quan luôn hiển thị phía trên nền xanh.
                Positioned(
                  // Hạ cụm thẻ xuống để giữ khoảng cách rõ ràng với lời chào.
                  top: 175,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 20,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(17),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.09),
                              blurRadius: 16,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    'Số dư hiện tại',
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 12,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    hideBalance
                                        ? '••••••••'
                                        : '${formatMoney(balance)} đ',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: darkBlue,
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              tooltip: hideBalance ? 'Hiện số dư' : 'Ẩn số dư',
                              onPressed: () => setState(
                                    () => hideBalance = !hideBalance,
                              ),
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFFEAF3FF),
                                fixedSize: const Size(44, 44),
                              ),
                              icon: Icon(
                                hideBalance
                                    ? Icons.visibility_off_outlined
                                    : Icons.account_balance_wallet_rounded,
                                color: primaryBlue,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: 'Thu nhập',
                              amount: totalIncome,
                              icon: Icons.arrow_upward_rounded,
                              color: const Color(0xFF20B66A),
                              background: const Color(0xFFDDF8E8),
                              hideAmount: hideBalance,
                              formatMoney: formatMoney,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: 'Chi tiêu',
                              amount: totalExpense,
                              icon: Icons.arrow_downward_rounded,
                              color: const Color(0xFFFF535D),
                              background: const Color(0xFFFFE6E8),
                              hideAmount: hideBalance,
                              formatMoney: formatMoney,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 12, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Giao dịch gần đây',
                    style: TextStyle(
                      color: darkBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => _selectTab(1),
                  child: const Text(
                    'Xem tất cả',
                    style: TextStyle(
                      color: primaryBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.all(28),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (transactions.isEmpty)
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 35),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFFB6C2D0),
                    size: 46,
                  ),
                  SizedBox(height: 9),
                  Text(
                    'Chưa có giao dịch',
                    style: TextStyle(
                      color: Color(0xFF7A8494),
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Nhấn nút + để thêm giao dịch đầu tiên',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10264D).withOpacity(0.035),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: sortedTransactions.take(7).map((item) {
                      final category = item['category']?.toString() ?? 'Khác';
                      final savedTitle = item['title']?.toString().trim() ?? '';
                      final title = savedTitle.isNotEmpty ? savedTitle : category;
                      final isIncome = item['type'] == 'income';
                      final id = (item['id'] as num).toInt();
                      return _TransactionTile(
                        roomy: true,
                        title: title,
                        date: item['date']?.toString() ?? '',
                        amount: displayAmount(item),
                        icon: getIcon(category, isIncome),
                        iconColor: getIconColor(category, isIncome),
                        amountColor: isIncome
                            ? const Color(0xFF19A85B)
                            : const Color(0xFFFF4D57),
                        onTap: () => _openEditTransaction(id),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  bool _matchesTransactionPeriod(Map<String, dynamic> item) {
    if (_transactionPeriodFilter == 'all') return true;
    final date = _parseDate(item['date']);
    if (date == null) return false;

    final dateOnly = DateTime(date.year, date.month, date.day);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    switch (_transactionPeriodFilter) {
      case 'today':
        return dateOnly == today;
      case 'week':
        final firstDay = today.subtract(const Duration(days: 6));
        return !dateOnly.isBefore(firstDay) && !dateOnly.isAfter(today);
      case 'month':
        return dateOnly.year == now.year && dateOnly.month == now.month;
      case 'custom':
        final start = _transactionStartDate == null
            ? null
            : DateTime(
          _transactionStartDate!.year,
          _transactionStartDate!.month,
          _transactionStartDate!.day,
        );
        final end = _transactionEndDate == null
            ? null
            : DateTime(
          _transactionEndDate!.year,
          _transactionEndDate!.month,
          _transactionEndDate!.day,
        );
        if (start != null && dateOnly.isBefore(start)) return false;
        if (end != null && dateOnly.isAfter(end)) return false;
        return true;
      default:
        return true;
    }
  }

  Future<void> _openFilterScreen() async {
    final categories = transactions
        .map((item) => item['category']?.toString().trim() ?? 'Khác')
        .where((category) => category.isNotEmpty)
        .toSet()
        .toList()
      ..sort();

    final result = await Navigator.push<TransactionFilterResult>(
      context,
      MaterialPageRoute(
        builder: (_) => FilterScreen(
          categories: categories,
          initialType: _transactionTypeFilter,
          initialCategory: _transactionCategoryFilter,
          initialPeriod: _transactionPeriodFilter,
          initialStartDate: _transactionStartDate,
          initialEndDate: _transactionEndDate,
        ),
      ),
    );

    if (result == null || !mounted) return;
    setState(() {
      _transactionTypeFilter = result.type;
      _transactionCategoryFilter = result.category;
      _transactionPeriodFilter = result.period;
      _transactionStartDate = result.startDate;
      _transactionEndDate = result.endDate;
    });
  }

  Widget _buildTransactionList() {
    final query = _transactionSearchQuery.trim().toLowerCase();
    final items = sortedTransactions.where((item) {
      final type = item['type']?.toString() ?? '';
      final category = item['category']?.toString().trim() ?? 'Khác';
      final title = item['title']?.toString().trim() ?? '';
      final note = item['note']?.toString() ?? '';
      final date = item['date']?.toString() ?? '';
      final matchesType = _transactionTypeFilter == 'all' ||
          type == _transactionTypeFilter;
      final matchesCategory = _transactionCategoryFilter == 'Tất cả danh mục' ||
          category == _transactionCategoryFilter;
      final matchesPeriod = _matchesTransactionPeriod(item);
      final searchableText = '$title $category $note $date ${displayAmount(item)}'
          .toLowerCase();
      final matchesSearch = query.isEmpty || searchableText.contains(query);
      return matchesType && matchesCategory && matchesPeriod && matchesSearch;
    }).toList();

    return RefreshIndicator(
      onRefresh: _loadTransactions,
      child: SafeArea(
        bottom: false,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Tiêu đề màn hình số 3.
            Padding(
              padding: const EdgeInsets.fromLTRB(2, 4, 0, 8),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Giao dịch',
                      style: TextStyle(
                        color: darkBlue,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Lọc theo danh mục',
                    onPressed: _openFilterScreen,
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Color(0xFF53677F),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            // Thanh tìm kiếm và nút lọc nhanh ở bên phải.
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F5FA),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE5ECF4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          color: Color(0xFF718096),
                          size: 21,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _transactionSearchController,
                            onChanged: (value) {
                              setState(() => _transactionSearchQuery = value);
                            },
                            textInputAction: TextInputAction.search,
                            style: const TextStyle(
                              color: darkBlue,
                              fontSize: 13,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Tìm kiếm giao dịch...',
                              hintStyle: TextStyle(
                                color: Color(0xFF8291A5),
                                fontSize: 13,
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        if (_transactionSearchQuery.isNotEmpty)
                          InkWell(
                            onTap: () {
                              _transactionSearchController.clear();
                              setState(() => _transactionSearchQuery = '');
                            },
                            child: const Icon(
                              Icons.close_rounded,
                              color: Color(0xFF718096),
                              size: 18,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5ECF4)),
                  ),
                  child: IconButton(
                    tooltip: 'Lọc danh mục',
                    onPressed: _openFilterScreen,
                    icon: const Icon(
                      Icons.filter_alt_outlined,
                      color: Color(0xFF53677F),
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // Ba nút loại giao dịch như trong ảnh mẫu.
            Row(
              children: [
                Expanded(child: _buildTransactionTypeChip('all', 'Tất cả')),
                const SizedBox(width: 8),
                Expanded(child: _buildTransactionTypeChip('income', 'Thu nhập')),
                const SizedBox(width: 8),
                Expanded(child: _buildTransactionTypeChip('expense', 'Chi tiêu')),
              ],
            ),
            const SizedBox(height: 16),
            if (isLoading)
              const Padding(
                padding: EdgeInsets.all(30),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 64, left: 16, right: 16),
                child: Column(
                  children: [
                    const Icon(
                      Icons.receipt_long_outlined,
                      size: 54,
                      color: Color(0xFFB6C2D0),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      transactions.isEmpty
                          ? 'Chưa có giao dịch'
                          : 'Không tìm thấy giao dịch phù hợp',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      transactions.isEmpty
                          ? 'Nhấn nút + ở Trang chủ để thêm giao dịch mới.'
                          : 'Thử thay đổi từ khóa tìm kiếm hoặc bộ lọc.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                    if (_transactionCategoryFilter != 'Tất cả danh mục' ||
                        _transactionTypeFilter != 'all' || query.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          _transactionSearchController.clear();
                          setState(() {
                            _transactionSearchQuery = '';
                            _transactionTypeFilter = 'all';
                            _transactionCategoryFilter = 'Tất cả danh mục';
                            _transactionPeriodFilter = 'all';
                            _transactionStartDate = null;
                            _transactionEndDate = null;
                          });
                        },
                        child: const Text('Xóa bộ lọc'),
                      ),
                  ],
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFEDF1F6)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF10264D).withOpacity(0.025),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Column(
                    children: items.map((item) {
                      final category = item['category']?.toString() ?? 'Khác';
                      final savedTitle = item['title']?.toString().trim() ?? '';
                      final title = savedTitle.isNotEmpty ? savedTitle : category;
                      final isIncome = item['type'] == 'income';
                      final id = (item['id'] as num).toInt();
                      return _TransactionTile(
                        title: title,
                        date: item['date']?.toString() ?? '',
                        amount: displayAmount(item),
                        icon: getIcon(category, isIncome),
                        iconColor: getIconColor(category, isIncome),
                        amountColor: isIncome
                            ? const Color(0xFF19A85B)
                            : const Color(0xFFFF4D57),
                        onTap: () => _openEditTransaction(id),
                      );
                    }).toList(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionTypeChip(String value, String label) {
    final selected = _transactionTypeFilter == value;
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => setState(() => _transactionTypeFilter = value),
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primaryBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? primaryBlue : const Color(0xFFE3EAF2),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: primaryBlue.withOpacity(0.12),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : darkBlue,
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Color _statisticsColorForCategory(String category) {
    switch (category.trim()) {
      case 'Ăn uống':
        return const Color(0xFFF04F64);
      case 'Mua sắm':
        return const Color(0xFF8B5CF6);
      case 'Di chuyển':
      case 'Đi lại':
      case 'Xăng':
        return const Color(0xFF32B76A);
      case 'Giáo dục':
      case 'Học tập':
      case 'Tiền học':
        return const Color(0xFF1976E9);
      default:
        return const Color(0xFFF5AE38);
    }
  }

  Widget _buildStatisticsPeriodChip(String period) {
    final selected = _statisticsPeriod == period;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: () => setState(() => _statisticsPeriod = period),
        child: Container(
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? primaryBlue : const Color(0xFFE5EBF3),
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: primaryBlue.withOpacity(0.10),
                blurRadius: 7,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
          ),
          child: Text(
            period,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? Colors.white : const Color(0xFF64748B),
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatistics() {
    final now = DateTime.now();
    final previousMonth = DateTime(now.year, now.month - 1);
    final expenseByCategory = <String, double>{};

    bool isInSelectedPeriod(DateTime? date) {
      if (date == null) return false;
      switch (_statisticsPeriod) {
        case 'Tháng trước':
          return date.year == previousMonth.year &&
              date.month == previousMonth.month;
        case 'Năm nay':
          return date.year == now.year;
        case 'Tháng này':
        default:
          return date.year == now.year && date.month == now.month;
      }
    }

    for (final item in transactions) {
      if (item['type'] != 'expense') continue;
      if (!isInSelectedPeriod(_parseDate(item['date']))) continue;

      final rawCategory = item['category']?.toString().trim() ?? '';
      final category = rawCategory.isEmpty ? 'Khác' : rawCategory;
      final amount = ((item['amount'] as num?)?.toDouble() ?? 0).abs();
      expenseByCategory[category] = (expenseByCategory[category] ?? 0) + amount;
    }

    final entries = expenseByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final totalForPeriod = entries.fold<double>(
      0,
          (total, entry) => total + entry.value,
    );
    final chartSegments = entries
        .map(
          (entry) => DonutSegment(
        value: entry.value,
        color: _statisticsColorForCategory(entry.key),
      ),
    )
        .toList();

    return SafeArea(
      bottom: false,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          const Text(
            'Thống kê',
            style: TextStyle(
              color: darkBlue,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatisticsPeriodChip('Tháng này'),
              const SizedBox(width: 7),
              _buildStatisticsPeriodChip('Tháng trước'),
              const SizedBox(width: 7),
              _buildStatisticsPeriodChip('Năm nay'),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFEDF1F6)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF10264D).withOpacity(0.025),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                _ExpenseDonutChart(
                  total: totalForPeriod,
                  segments: chartSegments,
                  hideAmount: hideBalance,
                  formatMoney: formatMoney,
                ),
                const SizedBox(height: 12),
                if (entries.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(8, 4, 8, 16),
                    child: Text(
                      'Chưa có dữ liệu chi tiêu trong kỳ này',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF8794A7),
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  ...entries.map((entry) {
                    final ratio = totalForPeriod <= 0
                        ? 0.0
                        : entry.value / totalForPeriod;
                    final color = _statisticsColorForCategory(entry.key);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 7),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              entry.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF263956),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 98,
                            child: Text(
                              hideBalance
                                  ? '••••••'
                                  : '${formatMoney(entry.value)} đ',
                              textAlign: TextAlign.right,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF34445D),
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            width: 32,
                            child: Text(
                              '${(ratio * 100).round()}%',
                              textAlign: TextAlign.right,
                              style: const TextStyle(
                                color: Color(0xFF718096),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfile() {
    return SafeArea(
      bottom: false,
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Phần đầu tài khoản theo mẫu màn hình Cá nhân.
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(22, 26, 22, 22),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundColor: Color(0xFF4DA3F5),
                    child: Icon(Icons.person, color: Colors.white, size: 45),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nguyễn Văn A',
                          style: TextStyle(
                            color: Color(0xFF172B4D),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'nguyenvana@example.com',
                          style: TextStyle(
                            color: Color(0xFF718096),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE4EAF2)),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                children: [
                  _ProfileOption(
                    icon: Icons.person_outline_rounded,
                    title: 'Thông tin cá nhân',
                    onTap: () => _showMessage(
                      'Thông tin tài khoản: Nguyễn Văn A · nguyenvana@example.com',
                    ),
                  ),
                  _ProfileOption(
                    icon: Icons.settings_outlined,
                    title: 'Cài đặt ngân sách',
                    onTap: () => _showMessage(
                      'Chức năng cài đặt ngân sách sẽ được bổ sung.',
                    ),
                  ),
                  _ProfileOption(
                    icon: Icons.category_outlined,
                    title: 'Danh mục chi tiêu',
                    onTap: () => _showMessage(
                      'Chức năng quản lý danh mục sẽ được bổ sung.',
                    ),
                  ),
                  _ProfileOption(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Sao lưu dữ liệu',
                    onTap: () => _showMessage(
                      'Chức năng sao lưu dữ liệu chưa được kết nối.',
                    ),
                  ),
                  _ProfileOption(
                    icon: Icons.lock_outline_rounded,
                    title: 'Đổi mật khẩu',
                    onTap: _showChangePasswordDialog,
                  ),
                  _ProfileOption(
                    icon: Icons.logout_rounded,
                    title: 'Đăng xuất',
                    color: const Color(0xFFE94B65),
                    showDivider: false,
                    onTap: () => _showMessage(
                      'Ứng dụng hiện chưa có hệ thống đăng nhập/đăng xuất.',
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

  Future<void> _showChangePasswordDialog() async {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: oldController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu hiện tại'),
              ),
              TextField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Mật khẩu mới'),
              ),
              TextField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Nhập lại mật khẩu mới'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _showMessage(
                newController.text.isEmpty
                    ? 'Vui lòng nhập mật khẩu mới.'
                    : newController.text != confirmController.text
                    ? 'Mật khẩu nhập lại chưa khớp.'
                    : 'Giao diện đã hoàn tất; chức năng đổi mật khẩu chưa kết nối hệ thống tài khoản.',
              );
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    oldController.dispose();
    newController.dispose();
    confirmController.dispose();
  }

}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color color;
  final Color background;
  final bool hideAmount;
  final String Function(double) formatMoney;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.background,
    required this.hideAmount,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 102),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 23),
          const SizedBox(height: 7),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hideAmount ? '••••••' : '${formatMoney(amount)} đ',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final String title;
  final String date;
  final String amount;
  final IconData icon;
  final Color iconColor;
  final Color amountColor;
  final VoidCallback onTap;
  final bool roomy;

  const _TransactionTile({
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.amountColor,
    required this.onTap,
    this.roomy = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 12,
            vertical: roomy ? 15 : 14,
          ),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDF0F5)),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: roomy ? 46 : 42,
                height: roomy ? 46 : 42,
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: roomy ? 23 : 20),
              ),
              SizedBox(width: roomy ? 13 : 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: const Color(0xFF172B4D),
                        fontSize: roomy ? 14.0 : 13.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: roomy ? 4 : 5),
                    Text(
                      date,
                      style: TextStyle(
                        color: const Color(0xFF8190A5),
                        fontSize: roomy ? 12 : 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  amount,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: amountColor,
                    fontSize: roomy ? 12.5 : 12.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 3),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF9AA7B8),
                size: 19,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;
  final bool showDivider;

  const _ProfileOption({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color = const Color(0xFF172B4D),
    this.showDivider = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 15),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(0xFF94A3B8),
                  size: 21,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, thickness: 1, color: Color(0xFFEAF0F6)),
      ],
    );
  }
}


/// Một phần dữ liệu của biểu đồ chi tiêu theo danh mục.
class DonutSegment {
  final double value;
  final Color color;

  const DonutSegment({required this.value, required this.color});
}

/// Biểu đồ vành khuyên dùng trên màn hình Thống kê.
class _ExpenseDonutChart extends StatelessWidget {
  final double total;
  final List<DonutSegment> segments;
  final bool hideAmount;
  final String Function(double) formatMoney;

  const _ExpenseDonutChart({
    required this.total,
    required this.segments,
    required this.hideAmount,
    required this.formatMoney,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 228,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(210, 210),
            painter: _ExpenseDonutPainter(
              total: total,
              segments: segments,
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hideAmount ? '••••••' : '${formatMoney(total)} đ',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF172B4D),
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Tổng chi tiêu',
                style: TextStyle(
                  color: Color(0xFF7A8494),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ExpenseDonutPainter extends CustomPainter {
  final double total;
  final List<DonutSegment> segments;

  const _ExpenseDonutPainter({required this.total, required this.segments});

  @override
  void paint(Canvas canvas, Size size) {
    const strokeWidth = 25.0;
    final side = math.min(size.width, size.height).toDouble();
    final center = Offset(size.width / 2, size.height / 2);
    final radius = side / 2 - strokeWidth / 2 - 2;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final trackPaint = Paint()
      ..color = const Color(0xFFE9EEF5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    if (total <= 0 || segments.isEmpty) return;

    var startAngle = -math.pi / 2;
    for (final segment in segments) {
      if (segment.value <= 0) continue;
      final sweepAngle = segment.value / total * math.pi * 2;
      final paint = Paint()
        ..color = segment.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.butt;
      // Tạo một khe mảnh giữa các phần màu để giống biểu đồ trong mẫu.
      final visibleSweep = math.max(0.0, sweepAngle - 0.025).toDouble();
      canvas.drawArc(rect, startAngle, visibleSweep, false, paint);
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant _ExpenseDonutPainter oldDelegate) {
    if (oldDelegate.total != total || oldDelegate.segments.length != segments.length) {
      return true;
    }
    for (var i = 0; i < segments.length; i++) {
      if (oldDelegate.segments[i].value != segments[i].value ||
          oldDelegate.segments[i].color != segments[i].color) {
        return true;
      }
    }
    return false;
  }
}
