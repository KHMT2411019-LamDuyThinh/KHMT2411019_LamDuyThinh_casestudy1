import 'package:flutter/material.dart';

/// Nội dung tab Cá nhân.
/// Thanh điều hướng dưới cùng được giữ ở DashboardScreen để tránh bị lặp.
class PersonalScreen extends StatefulWidget {
  const PersonalScreen({super.key});

  @override
  State<PersonalScreen> createState() => _PersonalScreenState();
}

class _PersonalScreenState extends State<PersonalScreen> {
  static const Color _navy = Color(0xFF172B4D);
  static const Color _muted = Color(0xFF718096);
  static const Color _divider = Color(0xFFE4EAF2);
  static const Color _blue = Color(0xFF1976D2);
  static const Color _background = Color(0xFFF7F9FC);
  static const Color _red = Color(0xFFE94B65);

  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(title),
        content: Text(message),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Future<void> _changePassword() async {
    final formKey = GlobalKey<FormState>();
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu hiện tại',
                    prefixIcon: Icon(Icons.lock_outline),
                  ),
                  validator: (value) =>
                  value == null || value.isEmpty
                      ? 'Vui lòng nhập mật khẩu hiện tại'
                      : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: newController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Mật khẩu mới',
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập mật khẩu mới';
                    }
                    if (value.length < 6) {
                      return 'Mật khẩu cần ít nhất 6 ký tự';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Nhập lại mật khẩu mới',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập lại mật khẩu mới';
                    }
                    if (value != newController.text) {
                      return 'Mật khẩu nhập lại chưa khớp';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Thông tin hợp lệ. Chức năng đổi mật khẩu thực tế cần được kết nối với hệ thống tài khoản.',
                  ),
                ),
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

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 20),
          children: [
            // Thông tin tài khoản ở đầu trang, theo hình mẫu.
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 22),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 32,
                    backgroundColor: Color(0xFF4DA3F5),
                    child: Icon(Icons.person, color: Colors.white, size: 42),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Nguyễn Văn A',
                          style: TextStyle(
                            color: _navy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'nguyenvana@example.com',
                          style: TextStyle(color: _muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: _divider),
            const SizedBox(height: 10),
            _PersonalMenuRow(
              icon: Icons.person_outline,
              title: 'Thông tin cá nhân',
              onTap: () => _showInfo(
                'Thông tin cá nhân',
                'Tên: Nguyễn Văn A\nEmail: nguyenvana@example.com',
              ),
            ),
            _PersonalMenuRow(
              icon: Icons.settings_outlined,
              title: 'Cài đặt ngân sách',
              onTap: () => _showInfo(
                'Cài đặt ngân sách',
                'Chức năng cài đặt ngân sách sẽ được bổ sung sau.',
              ),
            ),
            _PersonalMenuRow(
              icon: Icons.category_outlined,
              title: 'Danh mục chi tiêu',
              onTap: () => _showInfo(
                'Danh mục chi tiêu',
                'Chức năng quản lý danh mục sẽ được bổ sung sau.',
              ),
            ),
            _PersonalMenuRow(
              icon: Icons.cloud_upload_outlined,
              title: 'Sao lưu dữ liệu',
              onTap: () => _showInfo(
                'Sao lưu dữ liệu',
                'Chức năng sao lưu chưa được kết nối.',
              ),
            ),
            _PersonalMenuRow(
              icon: Icons.lock_outline,
              title: 'Đổi mật khẩu',
              onTap: _changePassword,
            ),
            _PersonalMenuRow(
              icon: Icons.logout,
              title: 'Đăng xuất',
              color: _red,
              showDivider: false,
              onTap: () => _showInfo(
                'Đăng xuất',
                'Ứng dụng hiện chưa có hệ thống đăng nhập/đăng xuất.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PersonalMenuRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color color;
  final bool showDivider;

  const _PersonalMenuRow({
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
        SizedBox(
          height: 58,
          child: InkWell(
            onTap: onTap,
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
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
                  Icons.chevron_right,
                  color: Color(0xFF8494AC),
                  size: 23,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(height: 1, color: Color(0xFFE4EAF2)),
      ],
    );
  }
}
