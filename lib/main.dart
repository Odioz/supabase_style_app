import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';
import 'login_screen.dart';

void main() {
  runApp(const SupabaseStyleApp());
}


// --- Главное приложение ---
class SupabaseStyleApp extends StatelessWidget {
  const SupabaseStyleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Supabase Style App',
      debugShowCheckedModeBanner: false,
      theme: SupabaseTheme.dark,
      home: //const LoginScreen(),
      const SupabaseDashboard(),
    );
  }
}

class SupabaseDashboard extends StatelessWidget {
  const SupabaseDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Верхняя навигация
                  _buildNavBar(context),
                  const SizedBox(height: 80),
                  // Hero-секция
                  _buildHeroSection(context),
                  const SizedBox(height: 64),
                  // Секция с карточками проектов
                  _buildProjectsSection(context),
                  const SizedBox(height: 64),
                  // Секция с кодом / техническая метка
                  _buildCodeSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Логотип (стилизованный)
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: SupabaseColors.emerald,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset('assets/logo.png', ),
            ),
            const SizedBox(width: 12),
            Text(
              'supabase',
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: SupabaseColors.textPrimary,
              ),
            ),
          ],
        ),
        // Ссылки навигации
        Row(
          children: [
            _navLink('Product'),
            const SizedBox(width: 24),
            _navLink('Developers'),
            const SizedBox(width: 24),
            _navLink('Pricing'),
            const SizedBox(width: 24),
            _navLink('Blog'),
          ],
        ),
      ],
    );
  }

  Widget _navLink(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: SupabaseColors.textSecondary,
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Техническая метка
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: SupabaseColors.emerald.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(9999),
            border: Border.all(color: SupabaseColors.emerald.withValues(alpha: 0.3)),
          ),
          child: Text(
            'POSTGRES DEVELOPMENT PLATFORM',
            style: GoogleFonts.sourceCodePro(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: SupabaseColors.emerald,
              letterSpacing: 1.2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Заголовок
        Text(
          'Build in a weekend.\nScale to millions.',
          style: Theme.of(context).textTheme.displayLarge,
        ),
        const SizedBox(height: 24),
        // Подзаголовок
        SizedBox(
          width: 600,
          child: Text(
            'Supabase is an open source Firebase alternative. Start your project with a Postgres database, Authentication, instant APIs, Edge Functions, Realtime subscriptions, and Storage.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        const SizedBox(height: 32),
        // Кнопки
        Row(
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: SupabaseColors.emerald,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(9999),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('Start your project'),
            ),
            const SizedBox(width: 16),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: SupabaseColors.textPrimary,
                side: const BorderSide(color: SupabaseColors.border),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                textStyle: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
              child: const Text('Request a demo'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProjectsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your projects',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: SupabaseColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 24),
        // Пример карточки проекта
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: SupabaseColors.surface,
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: SupabaseColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'my-awesome-app',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: SupabaseColors.textPrimary,
                    ),
                  ),
                  // Индикатор статуса
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: SupabaseColors.emerald.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      'Active',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: SupabaseColors.emerald,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Postgres database · 2 Edge Functions',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: SupabaseColors.textSecondary,
                ),
              ),
              const SizedBox(height: 20),
              // Поле ввода в стиле Supabase (пример)
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Project API key...',
                  prefixIcon: Icon(Icons.key, size: 18, color: SupabaseColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 16),
      const SupabaseAlert(
        message: 'В отпуске',
        variant: SupabaseAlertVariant.error,
      ),
      const SizedBox(height: 12),
      const SupabaseAlert(
        message: 'На больничном',
        variant: SupabaseAlertVariant.warning,
      ),
      const SizedBox(height: 12),
      const SupabaseAlert(
        message: 'На дежурстве',
        variant: SupabaseAlertVariant.success,
      ),
      const SizedBox(height: 12),
      const SupabaseAlert(
        message: 'На выходном',
        variant: SupabaseAlertVariant.info,
      ),
      ],
    );
  }

  Widget _buildCodeSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: SupabaseColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TERMINAL',
            style: GoogleFonts.sourceCodePro(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: SupabaseColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            r'$ npx supabase start',
            style: GoogleFonts.sourceCodePro(
              fontSize: 14,
              color: SupabaseColors.emerald,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Supabase local development setup is running.',
            style: GoogleFonts.sourceCodePro(
              fontSize: 14,
              color: SupabaseColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
  
}