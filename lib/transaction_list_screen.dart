
import 'package:flutter/material.dart';
import 'add_transaction_screen.dart';
import 'edit_transaction_screen.dart';
import 'database_helper.dart';

class TransactionListScreen extends StatefulWidget {
  const TransactionListScreen({super.key});

  @override
  State<TransactionListScreen> createState() =>
      _TransactionListScreenState();
}

class _TransactionListScreenState
    extends State<TransactionListScreen> {
  final TextEditingController _searchController =
  TextEditingController();

  List<Map<String, dynamic>> transactions = [];

  int selectedFilter = 0;

  String searchText = '';

  static const Color primaryColor = Color(0xFF0878F9);
  static const Color textColor = Color(0xFF172B4D);
  static const Color borderColor = Color(0xFFE6EDF5);

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Lấy dữ liệu giao dịch từ SQLite
  Future<void> _loadTransactions() async {
    try {
      final data =
      await DatabaseHelper.instance.getTransactions();

      if (!mounted) return;

      setState(() {
        transactions = data;
      });
    } catch (e) {
      debugPrint('Lỗi tải giao dịch: $e');
    }
  }

  // Định dạng số tiền: 500000 -> 500.000
  String formatMoney(dynamic value) {
    final amount = (value as num).round();
    final digits = amount.abs().toString();
    final buffer = StringBuffer();

    for (int i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);

      final remaining = digits.length - i - 1;

      if (remaining > 0 && remaining % 3 == 0) {
        buffer.write('.');
      }
    }

    return '${amount < 0 ? '-' : ''}$buffer';
  }

  // Định dạng ngày giao dịch
  String formatDate(dynamic value) {
    final rawDate = value?.toString() ?? '';

    try {
      final date = DateTime.parse(rawDate);

      return '${date.day.toString().padLeft(2, '0')}/'
          '${date.month.toString().padLeft(2, '0')}/'
          '${date.year}';
    } catch (_) {
      return rawDate;
    }
  }

  // Icon theo danh mục
  IconData categoryIcon(String category, bool isIncome) {
    if (isIncome) return Icons.account_balance_wallet_outlined;

    switch (category) {
      case 'Ăn uống':
        return Icons.restaurant;
      case 'Mua sắm':
        return Icons.shopping_cart;
      case 'Di chuyển':
        return Icons.directions_car;
      case 'Giáo dục':
      case 'Học tập':
        return Icons.menu_book;
      case 'Giải trí':
        return Icons.movie;
      case 'Lương':
        return Icons.payments_outlined;
      default:
        return Icons.receipt_long;
    }
  }

  // Màu icon theo danh mục
  Color categoryColor(String category, bool isIncome) {
    if (isIncome) return const Color(0xFF35BD69);

    switch (category) {
      case 'Ăn uống':
        return const Color(0xFFFF5360);
      case 'Mua sắm':
        return const Color(0xFF16A9ED);
      case 'Di chuyển':
        return const Color(0xFF9B5CF6);
      case 'Giáo dục':
      case 'Học tập':
        return const Color(0xFF9955F6);
      case 'Giải trí':
        return const Color(0xFFFFA21A);
      default:
        return const Color(0xFF20B875);
    }
  }

  // Lọc theo loại và từ khóa
  List<Map<String, dynamic>> get filteredTransactions {
    final result = transactions.where((item) {
      final type = item['type']?.toString() ?? '';
      final title = item['title']?.toString() ?? '';
      final category = item['category']?.toString() ?? '';

      final matchesType = selectedFilter == 0 ||
          (selectedFilter == 1 && type == 'income') ||
          (selectedFilter == 2 && type == 'expense');

      final query = searchText.toLowerCase();

      final matchesSearch =
          title.toLowerCase().contains(query) ||
              category.toLowerCase().contains(query);

      return matchesType && matchesSearch;
    }).toList();

    // Giao dịch mới nhất hiển thị trước
    result.sort((a, b) {
      final dateA = DateTime.tryParse(
        a['date']?.toString() ?? '',
      ) ??
          DateTime(2000);

      final dateB = DateTime.tryParse(
        b['date']?.toString() ?? '',
      ) ??
          DateTime(2000);

      return dateB.compareTo(dateA);
    });

    return result;
  }

  Future<void> _openAddTransaction() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddTransactionScreen(),
      ),
    );

    await _loadTransactions();
  }

  Future<void> _openEditTransaction(
      Map<String, dynamic> item,
      ) async {
    final id = int.tryParse(item['id'].toString());

    if (id == null) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditTransactionScreen(
          transactionId: id,
        ),
      ),
    );

    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final items = filteredTransactions;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Giao dịch',
          style: TextStyle(
            color: textColor,
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Bộ lọc',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Bạn có thể lọc nhanh theo loại giao dịch '
                        'và tìm kiếm ngay trên màn hình này.',
                  ),
                ),
              );
            },
            icon: const Icon(
              Icons.filter_alt_outlined,
              color: Color(0xFF008D91),
              size: 25,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Ô tìm kiếm
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F7FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      searchText = value.trim();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm giao dịch...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF8998AA),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF50677E),
                      size: 22,
                    ),
                    suffixIcon: searchText.isNotEmpty
                        ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          searchText = '';
                        });
                      },
                      icon: const Icon(Icons.close, size: 19),
                    )
                        : null,
                    border: InputBorder.none,
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),

            // Ba nút lọc nhanh
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  _filterButton('Tất cả', 0),
                  const SizedBox(width: 10),
                  _filterButton('Thu nhập', 1),
                  const SizedBox(width: 10),
                  _filterButton('Chi tiêu', 2),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Danh sách giao dịch
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadTransactions,
                child: items.isEmpty
                    ? ListView(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 150),
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 58,
                      color: Colors.blueGrey.shade200,
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        transactions.isEmpty
                            ? 'Chưa có giao dịch'
                            : 'Không tìm thấy giao dịch',
                        style: const TextStyle(
                          color: Color(0xFF8998AA),
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                )
                    : ListView.separated(
                  physics:
                  const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    4,
                    16,
                    90,
                  ),
                  itemCount: items.length,
                  separatorBuilder: (_, __) =>
                  const Divider(
                    height: 1,
                    indent: 60,
                    color: borderColor,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];

                    final category =
                        item['category']?.toString() ?? 'Khác';

                    final title =
                        item['title']?.toString() ?? '';

                    final isIncome =
                        item['type'] == 'income';

                    final amount =
                    (item['amount'] as num).toDouble();

                    final color =
                    categoryColor(category, isIncome);

                    return InkWell(
                      onTap: () =>
                          _openEditTransaction(item),
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 2,
                        ),
                        child: Row(
                          children: [
                            // Icon danh mục
                            Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: color,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                categoryIcon(
                                  category,
                                  isIncome,
                                ),
                                color: Colors.white,
                                size: 21,
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Tên và ngày
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.isEmpty
                                        ? category
                                        : title,
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: textColor,
                                      fontSize: 14,
                                      fontWeight:
                                      FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formatDate(item['date']),
                                    style: const TextStyle(
                                      color: Color(0xFF8796A8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 8),

                            // Số tiền
                            Flexible(
                              child: Text(
                                '${isIncome ? '+' : '-'}'
                                    '${formatMoney(amount)} đ',
                                textAlign: TextAlign.right,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: isIncome
                                      ? const Color(0xFF16A34A)
                                      : const Color(0xFFFF424F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            const SizedBox(width: 5),

                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFF8292A5),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // Nút thêm giao dịch
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddTransaction,
        backgroundColor: primaryColor,
        elevation: 3,
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),

      // Thanh điều hướng
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: const Color(0xFF65758B),
        selectedLabelStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
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
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Thống kê',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Cá nhân',
          ),
        ],
        onTap: (index) {
          if (index == 1) return;

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                index == 0
                    ? 'Màn hình Trang chủ'
                    : index == 2
                    ? 'Màn hình Thống kê'
                    : 'Màn hình Cá nhân',
              ),
              duration: const Duration(seconds: 1),
            ),
          );
        },
      ),
    );
  }

  // Nút lọc theo loại giao dịch
  Widget _filterButton(String label, int index) {
    final isSelected = selectedFilter == index;

    return Expanded(
      child: SizedBox(
        height: 40,
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              selectedFilter = index;
            });
          },
          style: OutlinedButton.styleFrom(
            backgroundColor:
            isSelected ? primaryColor : Colors.white,
            foregroundColor:
            isSelected ? Colors.white : textColor,
            side: BorderSide(
              color: isSelected
                  ? primaryColor
                  : const Color(0xFFE2EAF3),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(11),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
          child: Text(
            label,
            maxLines: 1,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
