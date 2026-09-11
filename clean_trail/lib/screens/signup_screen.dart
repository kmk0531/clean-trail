import 'package:flutter/material.dart';
import '../state/app_state.dart';
import '../widgets/ios_button.dart';

class SignupScreen extends StatefulWidget {
  final AppState appState;

  const SignupScreen({super.key, required this.appState});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final success = await widget.appState.signupWithEmail(email, password, name);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });

      if (success) {
        // 회원가입 성공 및 로그인 완료 -> 화면 모두 닫고 홈으로 진입
        Navigator.pop(context); // 회원가입 화면 닫기 (이전 화면인 로그인 화면에서 로그인 이벤트를 받아 라우터가 갱신됨)
      } else {
        setState(() {
          _errorMessage = widget.appState.lastAuthErrorMessage ?? '회원가입에 실패했습니다.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FBF8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF2F7D4F)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            fontFamily: '-apple-system',
            fontWeight: FontWeight.bold,
            color: Color(0xFF2F7D4F),
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 10.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'CleanTrail 계정 만들기',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF233529),
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '간단한 정보 입력으로 환경 보호 여정을 동참하세요.',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 36),

                // Name/Nickname Input
                const Text(
                  '닉네임',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F7D4F),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(fontFamily: '-apple-system', fontSize: 15),
                  decoration: _buildInputDecoration('닉네임을 입력하세요'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '닉네임을 입력해 주세요.';
                    }
                    if (value.length < 2) {
                      return '닉네임은 최소 2글자 이상이어야 합니다.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 18),

                // Email Input
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
                  decoration: _buildInputDecoration('example@email.com'),
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

                // Password Input
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
                  decoration: _buildInputDecoration('비밀번호 (6자리 이상)'),
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
                const SizedBox(height: 18),

                // Confirm Password Input
                const Text(
                  '비밀번호 확인',
                  style: TextStyle(
                    fontFamily: '-apple-system',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2F7D4F),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  style: const TextStyle(fontFamily: '-apple-system', fontSize: 15),
                  decoration: _buildInputDecoration('비밀번호 재입력'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '비밀번호 확인을 입력해 주세요.';
                    }
                    if (value != _passwordController.text) {
                      return '비밀번호가 서로 일치하지 않습니다.';
                    }
                    return null;
                  },
                ),

                if (_errorMessage != null) ...[
                  const SizedBox(height: 18),
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

                const SizedBox(height: 36),

                // Signup Action Button
                SizedBox(
                  width: double.infinity,
                  child: IosButton(
                    onPressed: _isLoading ? () {} : _handleSignup,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            '가입 완료',
                            style: TextStyle(
                              fontFamily: '-apple-system',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
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
    );
  }
}
