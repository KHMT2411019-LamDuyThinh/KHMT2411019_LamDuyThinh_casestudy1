import 'package:flutter/material.dart';

class EditTransactionScreen extends StatefulWidget {
  const EditTransactionScreen({super.key});

  @override
  State<EditTransactionScreen> createState() =>
      _EditTransactionScreenState();
}

class _EditTransactionScreenState
    extends State<EditTransactionScreen> {

  final TextEditingController amountController =
  TextEditingController(text: '100.000');

  final TextEditingController noteController =
  TextEditingController(text: 'Ăn trưa');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF172B4D),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Sửa giao dịch',
          style: TextStyle(
            color: Color(0xFF172B4D),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const SizedBox(height: 10),

            // Chi tiêu / Thu nhập
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6469),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Center(
                      child: Text(
                        'Chi tiêu',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Container(
                    height: 45,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color(0xFFE0E5EA),
                      ),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: const Center(
                      child: Text(
                        'Thu nhập',
                        style: TextStyle(
                          color: Color(0xFF172B4D),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Danh mục',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            // Danh mục
            Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color(0xFFE0E5EA),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: Color(0xFFFF6469),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: Colors.white,
                      size: 17,
                    ),
                  ),

                  const SizedBox(width: 10),

                  const Text(
                    'Ăn uống',
                    style: TextStyle(
                      color: Color(0xFF172B4D),
                    ),
                  ),

                  const Spacer(),

                  const Icon(
                    Icons.keyboard_arrow_down,
                    color: Color(0xFF607080),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

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
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                suffixText: 'đ',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E5EA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

            const Text(
              'Ngày giao dịch',
              style: TextStyle(
                color: Color(0xFF172B4D),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              readOnly: true,
              decoration: InputDecoration(
                hintText: '12/04/2025',
                suffixIcon: const Icon(Icons.calendar_month),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E5EA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 22),

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
              maxLines: 3,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(9),
                  borderSide: const BorderSide(
                    color: Color(0xFFE0E5EA),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Nút Lưu
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
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
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
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