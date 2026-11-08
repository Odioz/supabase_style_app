import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'design/theme.dart';

// Импортируйте ваши классы из main.dart или отдельных файлов:
// import 'design/supabase_colors.dart';
// import 'design/supabase_theme.dart';
// import 'widgets/supabase_alert.dart';

enum _LoginState { idle, loading, sent, error }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  _LoginState _state = _LoginState.idle;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendMagicLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _state = _LoginState.loading;
      _errorMessage = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: _emailController.text.trim(),
        emailRedirectTo: 'io.supabase.myapp://login-callback/',
      );
      if (mounted) setState(() => _state = _LoginState.sent);
    } catch (e) {
      if (mounted) {
        setState(() {
          _state = _LoginState.error;
          _errorMessage = _parseError(e);
        });
      }
    }
  }

  String _parseError(Object e) {
    final msg = e.toString();
    // Ловим ошибку нашего PostgreSQL-триггера из allowed_emails
    if (msg.contains('Доступ запрещен') || msg.contains('allowed_emails')) {
      return 'Этот email не входит в список разрешённых. Обратитесь к администратору.';
    }
    if (msg.contains('rate limit')) {
      return 'Слишком много попыток. Подождите минуту и попробуйте снова.';
    }
    return 'Не удалось отправить ссылку. Проверьте email и попробуйте снова.';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Мягкий радиальный glow за формой — фирменный приём Supabase
          Positioned(
            top: -300,
            left: 0,
            right: 0,
            child: Container(
              height: 700,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    SupabaseColors.emerald.withValues(alpha:0.08),
                    Colors.transparent,
                  ],
                  radius: 0.6,
                ),
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _state == _LoginState.sent
                      ? _buildCheckEmailView()
                      : _buildForm(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Форма входа ---
  Widget _buildForm() {
    return Container(
      key: const ValueKey('form'),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: SupabaseColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: SupabaseColors.border),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildLogo(),
            const SizedBox(height: 24),
            Text(
              'Sign in to your account',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: SupabaseColors.textPrimary,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "We'll send a magic link to your email",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: SupabaseColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            // Техническая метка над полем — как в реальном UI Supabase
            Text(
              'EMAIL',
              style: GoogleFonts.sourceCodePro(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: SupabaseColors.textSecondary,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              style: GoogleFonts.inter(
                fontSize: 14,
                color: SupabaseColors.textPrimary,
              ),
              decoration: const InputDecoration(
                hintText: 'you@example.com',
                prefixIcon: Icon(
                  Icons.mail_outline,
                  size: 18,
                  color: SupabaseColors.textSecondary,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Введите email';
                final re = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
                if (!re.hasMatch(v.trim())) return 'Неверный формат email';
                return null;
              },
              onFieldSubmitted: (_) => _sendMagicLink(),
            ),
            const SizedBox(height: 16),
            if (_state == _LoginState.error && _errorMessage != null) ...[
              SupabaseAlert(
                message: _errorMessage!,
                variant: SupabaseAlertVariant.error,
                onDismiss: () => setState(() {
                  _state = _LoginState.idle;
                  _errorMessage = null;
                }),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed:
                    _state == _LoginState.loading ? null : _sendMagicLink,
                style: ElevatedButton.styleFrom(
                  backgroundColor: SupabaseColors.emerald,
                  foregroundColor: Colors.black,
                  disabledBackgroundColor:
                      SupabaseColors.emerald.withValues(alpha:0.4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  textStyle: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: _state == _LoginState.loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.black),
                        ),
                      )
                    : const Text('Send magic link'),
              ),
            ),
            const SizedBox(height: 24),
            _buildDivider(),
            const SizedBox(height: 20),
            _buildOAuthRow(),
            const SizedBox(height: 24),
            Text(
              'By continuing, you agree to our Terms of Service and Privacy Policy.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: SupabaseColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: SupabaseColors.emerald,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: SupabaseColors.emerald.withValues(alpha:0.35),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.bolt, color: Colors.black, size: 28),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(color: SupabaseColors.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: GoogleFonts.sourceCodePro(
              fontSize: 11,
              color: SupabaseColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const Expanded(child: Divider(color: SupabaseColors.border)),
      ],
    );
  }

  Widget _buildOAuthRow() {
    return Row(
      children: [
        Expanded(child: _oauthButton('Google', Icons.g_mobiledata)),
        const SizedBox(width: 12),
        Expanded(child: _oauthButton('GitHub', Icons.code)),
      ],
    );
  }

  Widget _oauthButton(String label, IconData icon) {
    return OutlinedButton.icon(
      onPressed: () {
        // TODO: реализуем позже — supabase.auth.signInWithOAuth(...)
      },
      icon: Icon(icon, size: 18, color: SupabaseColors.textPrimary),
      label: Text(
        label,
        style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: SupabaseColors.textPrimary,
        side: const BorderSide(color: SupabaseColors.border),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      ),
    );
  }

  // --- Состояние «проверьте почту» ---
  Widget _buildCheckEmailView() {
    return Container(
      key: const ValueKey('sent'),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: SupabaseColors.surface,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: SupabaseColors.border),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: SupabaseColors.emerald.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: SupabaseColors.emerald.withValues(alpha: 0.3),
              ),
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              color: SupabaseColors.emerald,
              size: 28,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Check your email',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: SupabaseColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: GoogleFonts.inter(
                fontSize: 14,
                color: SupabaseColors.textSecondary,
                height: 1.5,
              ),
              children: [
                const TextSpan(text: 'We sent a sign-in link to\n'),
                TextSpan(
                  text: _emailController.text.trim(),
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: SupabaseColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => setState(() => _state = _LoginState.idle),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: SupabaseColors.border),
                foregroundColor: SupabaseColors.textPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              child: Text(
                'Use a different email',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Didn't receive anything? Check spam or try again in a minute.",
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: SupabaseColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}