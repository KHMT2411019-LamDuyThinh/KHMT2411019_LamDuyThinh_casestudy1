import 'package:flutter/material.dart';
import 'database_helper.dart';

class EditTransactionScreen extends StatefulWidget {
  final int transactionId;

  const EditTransactionScreen({
    super.key,
    required this.transactionId,
  });

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {

  // =====================================================
  // CONTROLLER
  // =====================================================

  final TextEditingController titleController =
  TextEditingController();

  final TextEditingController amountController =
  TextEditingController();

  final TextEditingController noteController =
  TextEditingController();

  // =====================================================
  // DỮ LIỆU
  // =====================================================

  bool isExpense = true;

  String category = 'Ăn uống';

  DateTime selectedDate = DateTime.now();

  bool isLoading = true;

  // =====================================================
  // INIT
  // =====================================================

  @override
  void initState() {
    super.initState();

    _loadTransaction();
  }

  // =====================================================
  // LOAD GIAO DỊCH TỪ SQLITE
  // =====================================================

  Future<void> _loadTransaction() async {
    try {
      final transaction =
      await DatabaseHelper.instance.getTransactionById(
        widget.transactionId,
      );

      if (!mounted) return;

      if (transaction == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Không tìm thấy giao dịch',
            ),
          ),
        );

        Navigator.pop(context);
        return;
      }

      setState(() {
        // Nội dung
        titleController.text =
            transaction['title']?.toString() ?? '';

        // Số tiền
        final amount =
            (transaction['amount'] as num?)?.toDouble() ??
                0;

        amountController.text =
            formatMoney(amount);

        // Loại giao dịch
        isExpense =
            transaction['type'] == 'expense';

        // Danh mục
        category =
            transaction['category']?.toString() ??
                'Ăn uống';

        // Ghi chú
        noteController.text =
            transaction['note']?.toString() ?? '';

        // Ngày
        selectedDate =
            parseDate(
              transaction['date']?.toString() ?? '',
            );

        isLoading = false;
      });
    } catch (e) {
      debugPrint(
        'LOAD TRANSACTION ERROR: $e',
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể tải giao dịch',
          ),
        ),
      );
    }
  }

  // =====================================================
  // FORMAT MONEY
  // Ví dụ:
  // 50000 -> 50.000
  // =====================================================

  String formatMoney(double amount) {
    final value = amount.round().toString();

    final buffer = StringBuffer();

    for (int i = 0; i < value.length; i++) {
      final positionFromEnd =
          value.length - i;

      buffer.write(value[i]);

      if (positionFromEnd > 1 &&
          positionFromEnd % 3 == 1) {
        buffer.write('.');
      }
    }

    return buffer.toString();
  }

  // =====================================================
  // PARSE MONEY
  // 50.000 -> 50000
  // =====================================================

  double parseMoney(String value) {
    final cleanValue =
    value.replaceAll('.', '').replaceAll(',', '');

    return double.tryParse(cleanValue) ?? 0;
  }

  // =====================================================
  // FORMAT DATE
  // =====================================================

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  // =====================================================
  // PARSE DATE
  // 03/09/2024 -> DateTime
  // =====================================================

  DateTime parseDate(String value) {
    try {
      final parts = value.split('/');

      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        return DateTime(
          year,
          month,
          day,
        );
      }
    } catch (e) {
      debugPrint(
        'DATE PARSE ERROR: $e',
      );
    }

    return DateTime.now();
  }

  // =====================================================
  // CHỌN NGÀY
  // =====================================================

  Future<void> selectDate() async {
    final DateTime? picked =
    await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // =====================================================
  // UPDATE GIAO DỊCH
  // =====================================================

  Future<void> _updateTransaction() async {
    // Kiểm tra title
    if (titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập nội dung giao dịch',
          ),
        ),
      );

      return;
    }

    // Lấy số tiền
    final amount =
    parseMoney(amountController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vui lòng nhập số tiền hợp lệ',
          ),
        ),
      );

      return;
    }

    try {
      final transaction = {
        'title': titleController.text.trim(),
        'amount': amount,
        'type': isExpense
            ? 'expense'
            : 'income',
        'date': formatDate(selectedDate),
        'category': category,
        'note': noteController.text.trim(),
      };

      await DatabaseHelper.instance.updateTransaction(
        widget.transactionId,
        transaction,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Đã cập nhật giao dịch',
          ),
        ),
      );

      // Trả kết quả về Dashboard
      Navigator.pop(context, true);
    } catch (e) {
      debugPrint(
        'UPDATE TRANSACTION ERROR: $e',
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Không thể cập nhật giao dịch',
          ),
        ),
      );
    }
  }

  // =====================================================
  // BUILD
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // =================================================
      // APP BAR
      // =================================================

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF172B4D),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          'Sửa giao dịch',
          style: TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =================================================
      // BODY
      // =================================================

      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : SingleChildScrollView(
        padding:
        const EdgeInsets.symmetric(
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            // =====================================
            // CHI TIÊU / THU NHẬP
            // =====================================

            Row(
              children: [

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpense = true;
                      });
                    },
                    child: Container(
                      height: 45,
                      decoration: BoxDecoration(
                        color: isExpense
                            ? const Color(
                          0xFFFF6469,
                        )
                            : Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          9,
                        ),
                        border: Border.all(
                          color:
                          const Color(
                            0xFFE0E5EA,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Chi tiêu',
                          style: TextStyle(
                            color: isExpense
                                ? Colors.white
                                : const Color(
                              0xFF172B4D,
                            ),
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isExpense = false;
                      });
                    },
                    child: Container(
                      height: 45,
                      decoration:
                      BoxDecoration(
                        color: !isExpense
                            ? const Color(
                          0xFF35B95A,
                        )
                            : Colors.white,
                        borderRadius:
                        BorderRadius.circular(
                          9,
                        ),
                        border: Border.all(
                          color:
                          const Color(
                            0xFFE0E5EA,
                          ),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Thu nhập',
                          style: TextStyle(
                            color: !isExpense
                                ? Colors.white
                                : const Color(
                              0xFF172B4D,
                            ),
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // =====================================
            // NỘI DUNG GIAO DỊCH
            // =====================================

            const Text(
              'Nội dung giao dịch',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: titleController,
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Nhập nội dung giao dịch',
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    9,
                  ),
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    9,
                  ),
                  borderSide:
                  const BorderSide(
                    color:
                    Color(0xFFE0E5EA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================================
            // DANH MỤC
            // =====================================

            const Text(
              'Danh mục',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Container(
              height: 48,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              decoration:
              BoxDecoration(
                border: Border.all(
                  color:
                  const Color(0xFFE0E5EA),
                ),
                borderRadius:
                BorderRadius.circular(9),
              ),
              child:
              DropdownButtonHideUnderline(
                child:
                DropdownButton<String>(
                  value: category,
                  isExpanded: true,

                  items: const [
                    DropdownMenuItem(
                      value: 'Ăn uống',
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: Color(0xFFFF7078),
                            child: Icon(
                              Icons.restaurant,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Ăn uống'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Di chuyển',
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: Color(0xFF2196F3),
                            child: Icon(
                              Icons.directions_car,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Di chuyển'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Mua sắm',
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: Color(0xFF9C45F5),
                            child: Icon(
                              Icons.shopping_cart,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Mua sắm'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Giáo dục',
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: Color(0xFF16A6A6),
                            child: Icon(
                              Icons.school,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Giáo dục'),
                        ],
                      ),
                    ),
                    DropdownMenuItem(
                      value: 'Giải trí',
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 11,
                            backgroundColor: Color(0xFFFF9800),
                            child: Icon(
                              Icons.movie,
                              size: 13,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 10),
                          Text('Giải trí'),
                        ],
                      ),
                    ),
                  ],

                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        category = value;
                      });
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================================
            // SỐ TIỀN
            // =====================================

            const Text(
              'Số tiền',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: amountController,
              keyboardType:
              TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'đ',
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    9,
                  ),
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    9,
                  ),
                  borderSide:
                  const BorderSide(
                    color:
                    Color(0xFFE0E5EA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================================
            // NGÀY GIAO DỊCH
            // =====================================

            const Text(
              'Ngày giao dịch',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            GestureDetector(
              onTap: selectDate,
              child: Container(
                height: 48,
                padding:
                const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration:
                BoxDecoration(
                  border: Border.all(
                    color:
                    const Color(
                      0xFFE0E5EA,
                    ),
                  ),
                  borderRadius:
                  BorderRadius.circular(
                    9,
                  ),
                ),
                child: Row(
                  children: [

                    Text(
                      formatDate(
                        selectedDate,
                      ),
                      style:
                      const TextStyle(
                        color:
                        Color(0xFF172B4D),
                      ),
                    ),

                    const Spacer(),

                    const Icon(
                      Icons.calendar_month,
                      color:
                      Color(0xFF607080),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 22),

            // =====================================
            // GHI CHÚ
            // =====================================

            const Text(
              'Ghi chú',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: noteController,
              keyboardType: TextInputType.multiline,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú (tùy chọn)',
                border:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    9,
                  ),
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(
                    9,
                  ),
                  borderSide:
                  const BorderSide(
                    color:
                    Color(0xFFE0E5EA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // =====================================
            // NÚT LƯU
            // =====================================

            SizedBox(
              width: double.infinity,
              height: 48,
              child:
              ElevatedButton(
                onPressed:
                _updateTransaction,
                style:
                ElevatedButton.styleFrom(
                  backgroundColor:
                  const Color(
                    0xFF1976D2,
                  ),
                  foregroundColor:
                  Colors.white,
                  elevation: 0,
                  shape:
                  RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(
                      9,
                    ),
                  ),
                ),
                child: const Text(
                  'Lưu',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    titleController.dispose();
    amountController.dispose();
    noteController.dispose();

    super.dispose();
  }
}