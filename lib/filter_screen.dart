import 'package:flutter/material.dart';

/// Kết quả bộ lọc trả về DashboardScreen để lọc danh sách giao dịch thực tế.
class TransactionFilterResult {
  final String type;
  final String category;
  final String period;
  final DateTime? startDate;
  final DateTime? endDate;

  const TransactionFilterResult({
    required this.type,
    required this.category,
    required this.period,
    this.startDate,
    this.endDate,
  });
}

class FilterScreen extends StatefulWidget {
  final List<String> categories;
  final String initialType;
  final String initialCategory;
  final String initialPeriod;
  final DateTime? initialStartDate;
  final DateTime? initialEndDate;

  const FilterScreen({
    super.key,
    required this.categories,
    required this.initialType,
    required this.initialCategory,
    required this.initialPeriod,
    required this.initialStartDate,
    required this.initialEndDate,
  });

  @override
  State<FilterScreen> createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  static const Color _blue = Color(0xFF1976D2);
  static const Color _navy = Color(0xFF172B4D);
  static const Color _muted = Color(0xFF718096);
  static const Color _line = Color(0xFFE4EAF2);

  late String _type;
  late String _category;
  late String _period;
  DateTime? _startDate;
  DateTime? _endDate;

  List<String> get _categoryOptions {
    final values = <String>{'Tất cả danh mục', ...widget.categories};
    final result = values.toList();
    result.sort((a, b) {
      if (a == 'Tất cả danh mục') return -1;
      if (b == 'Tất cả danh mục') return 1;
      return a.compareTo(b);
    });
    return result;
  }

  @override
  void initState() {
    super.initState();
    _type = widget.initialType;
    _category = widget.initialCategory;
    // Hình mẫu chọn "Hôm nay" lúc mở. Nếu danh sách trước đó không áp dụng thời gian,
    // chỉ bộ lọc trên màn hình mới chọn Hôm nay; danh sách chỉ lọc sau khi bấm Áp dụng.
    _period = widget.initialPeriod == 'all' ? 'today' : widget.initialPeriod;
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
    if (!_categoryOptions.contains(_category)) {
      _category = 'Tất cả danh mục';
    }
    if (_period == 'custom') {
      final now = DateTime.now();
      _startDate ??= DateTime(now.year, now.month, now.day);
      _endDate ??= DateTime(now.year, now.month, now.day);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Chọn ngày';
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  Future<void> _pickDate({required bool isStart}) async {
    final now = DateTime.now();
    final initial = (isStart ? _startDate : _endDate) ??
        DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Chọn ngày bắt đầu' : 'Chọn ngày kết thúc',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = picked;
        }
      } else {
        _endDate = picked;
        if (_startDate != null && _startDate!.isAfter(picked)) {
          _startDate = picked;
        }
      }
    });
  }

  void _apply() {
    Navigator.pop(
      context,
      TransactionFilterResult(
        type: _type,
        category: _category,
        period: _period,
        startDate: _period == 'custom' ? _startDate : null,
        endDate: _period == 'custom' ? _endDate : null,
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: _navy,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _typeCheckbox(String label, String value) {
    final checked = _type == value;
    return InkWell(
      onTap: () => setState(() => _type = value),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Checkbox(
                value: checked,
                onChanged: (valueChecked) {
                  if (valueChecked == true) setState(() => _type = value);
                },
                activeColor: _blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(3),
                ),
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: _navy, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  Widget _periodOption(String label, String value) {
    final selected = _period == value;
    return InkWell(
      onTap: () => setState(() => _period = value),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Radio<String>(
                value: value,
                groupValue: _period,
                onChanged: (next) {
                  if (next != null) setState(() => _period = next);
                },
                activeColor: _blue,
                visualDensity: VisualDensity.compact,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: _navy,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _datePickerButton(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: _navy,
          side: const BorderSide(color: _line),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
            const SizedBox(height: 5),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatDate(date),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const Icon(Icons.calendar_month_outlined, size: 17),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FC),
        elevation: 0,
        leading: IconButton(
          tooltip: 'Quay lại',
          icon: const Icon(Icons.arrow_back_rounded, color: _navy),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Bộ lọc',
          style: TextStyle(color: _navy, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
        children: [
          _sectionTitle('Loại giao dịch'),
          _typeCheckbox('Tất cả', 'all'),
          _typeCheckbox('Thu nhập', 'income'),
          _typeCheckbox('Chi tiêu', 'expense'),
          const SizedBox(height: 20),
          _sectionTitle('Danh mục'),
          DropdownButtonFormField<String>(
            value: _categoryOptions.contains(_category)
                ? _category
                : 'Tất cả danh mục',
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _line),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _line),
              ),
            ),
            items: _categoryOptions
                .map((category) => DropdownMenuItem<String>(
              value: category,
              child: Text(category, style: const TextStyle(fontSize: 13)),
            ))
                .toList(),
            onChanged: (value) {
              if (value != null) setState(() => _category = value);
            },
          ),
          const SizedBox(height: 22),
          _sectionTitle('Khoảng thời gian'),
          _periodOption('Hôm nay', 'today'),
          _periodOption('7 ngày qua', 'week'),
          _periodOption('Tháng này', 'month'),
          _periodOption('Tùy chỉnh', 'custom'),
          if (_period == 'custom') ...[
            const SizedBox(height: 8),
            Row(
              children: [
                _datePickerButton('Từ ngày', _startDate, () => _pickDate(isStart: true)),
                const SizedBox(width: 10),
                _datePickerButton('Đến ngày', _endDate, () => _pickDate(isStart: false)),
              ],
            ),
          ],
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: _line)),
          ),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              onPressed: _apply,
              style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text(
                'Áp dụng',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
