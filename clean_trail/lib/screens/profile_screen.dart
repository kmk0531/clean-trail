import 'package:flutter/material.dart';
import '../state/app_state.dart';

class ProfileScreen extends StatelessWidget {
  final AppState appState;
  final VoidCallback onOpenStoreScanner;

  const ProfileScreen({
    super.key,
    required this.appState,
    required this.onOpenStoreScanner,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Header Title
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '프로필',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF233529),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Profile Summary Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: const Color(0xFFE2EBE5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                children: [
                  // Profile image placeholder with Level circle indicator
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4EA),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF2F7D4F), width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF2F7D4F),
                          size: 36,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2F7D4F),
                          shape: BoxShape.circle,
                        ),
                        child: const Text(
                          'Lv.4',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),

                  // Info details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          appState.userName ?? '초록발자국',
                          style: const TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF233529),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE6F4EA),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            '에코워커 등급',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F7D4F),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Point balance
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        '보유 포인트',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${appState.totalPoints} P',
                        style: const TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2F7D4F),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Settings Group Header
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '앱 설정',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // iOS standard styled setting item lists
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EBE5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  _buildSettingRow(context, Icons.notifications_none, '알림 설정'),
                  _buildDivider(),
                  _buildSettingRow(context, Icons.person_outline, '계정 관리'),
                  _buildDivider(),
                  _buildSettingRow(context, Icons.storefront_outlined, '제휴 상점 안내'),
                  _buildDivider(),
                  _buildSettingRow(context, Icons.help_outline, '도움말 및 고객센터'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Merchant Simulation Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '제휴 가맹점주용',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 8),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EBE5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.qr_code_scanner, color: Color(0xFFD6683C)),
                    title: const Text(
                      '사장님 전용 쿠폰 스캐너',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD6683C),
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                    onTap: onOpenStoreScanner,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout row
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2EBE5)),
              ),
              clipBehavior: Clip.antiAlias,
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent),
                title: const Text(
                  '로그아웃',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    color: Colors.redAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () async {
                  await appState.logout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('안전하게 로그아웃되었습니다.')),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingRow(BuildContext context, IconData icon, String title) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF5C6F61)),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: '-apple-system',
          fontWeight: FontWeight.w500,
          color: Color(0xFF233529),
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('"$title" 설정 메뉴를 로드합니다.')),
        );
      },
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 56, color: Color(0xFFE2EBE5));
  }
}
