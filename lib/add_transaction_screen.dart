import 'package:flutter/material.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() =>
      _AddTransactionScreenState();
}

class _AddTransactionScreenState
    extends State<AddTransactionScreen> {
  bool isExpense = true;

  String category = 'Ăn uống';

  DateTime selectedDate = DateTime(2025, 4, 12);

  final TextEditingController amountController =
  TextEditingController();

  final TextEditingController noteController =
  TextEditingController();

  Future<void> selectDate() async {
    final DateTime? picked = await showDatePicker(
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

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

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
          'Thêm giao dịch',
          style: TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // =========================
            // CHI TIÊU / THU NHẬP
            // =========================

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
                      height: 46,
                      decoration: BoxDecoration(
                        color: isExpense
                            ? const Color(0xFFFF6464)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: const Color(0xFFE1E6ED),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Chi tiêu',
                          style: TextStyle(
                            color: isExpense
                                ? Colors.white
                                : const Color(0xFF172B4D),
                            fontWeight: FontWeight.bold,
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
                      height: 46,
                      decoration: BoxDecoration(
                        color: !isExpense
                            ? const Color(0xFFFF6464)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: const Color(0xFFE1E6ED),
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Thu nhập',
                          style: TextStyle(
                            color: !isExpense
                                ? Colors.white
                                : const Color(0xFF172B4D),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // =========================
            // DANH MỤC
            // =========================

            const Text(
              'Danh mục',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 7),

            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFDDE3EA),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: category,
                  isExpanded: true,

                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF718096),
                  ),

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
                      child: Text('Di chuyển'),
                    ),
                    DropdownMenuItem(
                      value: 'Mua sắm',
                      child: Text('Mua sắm'),
                    ),
                    DropdownMenuItem(
                      value: 'Giải trí',
                      child: Text('Giải trí'),
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

            const SizedBox(height: 18),

            // =========================
            // SỐ TIỀN
            // =========================

            const Text(
              'Số tiền',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Nhập số tiền',
                suffixText: 'đ',

                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: Color(0xFFDDE3EA),
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: Color(0xFFDDE3EA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // NGÀY GIAO DỊCH
            // =========================

            const Text(
              'Ngày giao dịch',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 7),

            GestureDetector(
              onTap: selectDate,
              child: Container(
                height: 48,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFDDE3EA),
                  ),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  children: [
                    Text(
                      formatDate(selectedDate),
                      style: const TextStyle(
                        color: Color(0xFF172B4D),
                      ),
                    ),

                    const Spacer(),

                    const Icon(
                      Icons.calendar_month_outlined,
                      size: 19,
                      color: Color(0xFF718096),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // =========================
            // GHI CHÚ
            // =========================

            const Text(
              'Ghi chú',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF172B4D),
              ),
            ),

            const SizedBox(height: 7),

            TextField(
              controller: noteController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Nhập ghi chú (tùy chọn)',

                contentPadding: const EdgeInsets.all(12),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: Color(0xFFDDE3EA),
                  ),
                ),

                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: Color(0xFFDDE3EA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // =========================
            // NÚT LƯU
            // =========================

            SizedBox(
              width: double.infinity,
              height: 46,
              child: ElevatedButton(
                onPressed: () {
                  print('Đã lưu giao dịch');
                },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                  elevation: 0,

                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),

                child: const Text(
                  'Lưu',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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
}