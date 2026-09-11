import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/ios_button.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  final AppState appState;

  const LoginScreen({super.key, required this.appState});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = await widget.appState.loginWithEmail(email, password);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (!success) {
        setState(() {
          _errorMessage = widget.appState.lastAuthErrorMessage ?? '이메일 또는 비밀번호가 일치하지 않습니다.';
        });
      }
    }
  }

  void _handleSocialLogin(String type) async {
    setState(() {
      _isLoading = true;
    });

    if (type == 'google') {
      await widget.appState.signInWithGoogle();
    } else if (type == 'naver') {
      // 네이버 소셜 로그인 모의 처리 (1초 딜레이)
      await Future.delayed(const Duration(milliseconds: 600));
      await widget.appState.loginWithSocial(
        'naver',
        'clean_naver@naver.com',
        '네이버 사용자',
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              // App Logo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Color(0xFFE6F4EA),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco,
                  color: Color(0xFF2F7D4F),
                  size: 48,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'CleanTrail',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  color: Color(0xFF2F7D4F),
                  letterSpacing: -0.5,
                ),
              ),
              const Text(
                '지구를 지키는 한 걸음, 플로깅 여행',
                style: TextStyle(
                  fontFamily: '-apple-system',
                  fontSize: 13,
                  color: Color(0xFF6E7E73),
                ),
              ),
              const SizedBox(height: 40),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Email input
                    const Text(
                      '이메일 주소',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F7D4F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(fontFamily: '-apple-system', fontSize: 15),
                      decoration: InputDecoration(
                        hintText: 'example@email.com',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2F7D4F), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '이메일을 입력해 주세요.';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return '올바른 이메일 형식을 입력해 주세요.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 18),

                    // Password input
                    const Text(
                      '비밀번호',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F7D4F),
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(fontFamily: '-apple-system', fontSize: 15),
                      decoration: InputDecoration(
                        hintText: '비밀번호를 입력하세요',
                        hintStyle: const TextStyle(color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        filled: true,
                        fillColor: Colors.white,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2F7D4F), width: 1.5),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '비밀번호를 입력해 주세요.';
                        }
                        if (value.length < 6) {
                          return '비밀번호는 최소 6자리 이상이어야 합니다.';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Text(
                  _errorMessage!,
                  style: const TextStyle(
                    fontFamily: '-apple-system',
                    color: Colors.redAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Login Button
              SizedBox(
                width: double.infinity,
                child: IosButton(
                  onPressed: _isLoading ? () {} : _handleEmailLogin,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          '로그인',
                          style: TextStyle(
                            fontFamily: '-apple-system',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),

              // Signup Switch Link
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '아직 회원이 아니신가요? ',
                    style: TextStyle(fontFamily: '-apple-system', fontSize: 13, color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignupScreen(appState: widget.appState),
                        ),
                      );
                    },
                    child: const Text(
                      '회원가입',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F7D4F),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 40),

              // Social Logins Divider
              Row(
                children: [
                  Expanded(child: Divider(color: Colors.grey[300])),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '또는 소셜 계정으로 로그인',
                      style: TextStyle(
                        fontFamily: '-apple-system',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: Colors.grey[300])),
                ],
              ),

              const SizedBox(height: 24),

              // Google Login Button
              GestureDetector(
                onTap: _isLoading ? null : () => _handleSocialLogin('google'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Simple Google G logo color simulator representation
                      Container(
                        width: 18,
                        height: 18,
                        decoration: const BoxDecoration(
                          color: Color(0xFF4285F4),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Google 계정으로 로그인',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Naver Login Button
              GestureDetector(
                onTap: _isLoading ? null : () => _handleSocialLogin('naver'),
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF03C75A), // Naver Green
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'N',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        '네이버 계정으로 로그인',
                        style: TextStyle(
                          fontFamily: '-apple-system',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
