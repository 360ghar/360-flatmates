import 'package:flutter/material.dart';
import 'package:flatmates_app/core/theme/app_semantic_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth_controller.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../l10n/gen/app_localizations.dart';
import '../../shared/presentation/components.dart';
import 'widgets/terms_checkbox.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({required this.phone, super.key});

  final String? phone;

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late final TextEditingController _phoneController;
  final _passwordController = TextEditingController();
  bool _termsAccepted = false;

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.phone ?? '+91');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final locale = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return FlatmatesScreen(
      appBar: AppBar(),
      scrollable: true,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.signupTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.screen),
          FlatmatesCard(
            child: Column(
              children: [
                TextField(
                  key: const Key('signup_name_input'),
                  controller: _nameController,
                  decoration: InputDecoration(labelText: locale.fullNameLabel),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  key: const Key('signup_email_input'),
                  controller: _emailController,
                  decoration: InputDecoration(labelText: locale.emailLabel),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  key: const Key('signup_phone_input'),
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: locale.phoneNumberLabel,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                TextField(
                  key: const Key('signup_password_input'),
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(labelText: locale.passwordLabel),
                ),
                const SizedBox(height: AppSpacing.lg),
                TermsCheckbox(
                  accepted: _termsAccepted,
                  onChanged: (v) => setState(() => _termsAccepted = v),
                  locale: locale,
                  theme: theme,
                ),
                if (auth.status == AuthStatus.error &&
                    auth.errorMessage != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    auth.errorMessage!,
                    style: TextStyle(color: AppSemanticColors.error),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.screen),
          FlatmatesButton(
            key: const Key('signup_submit_button'),
            label: locale.createAccountCta,
            fullWidth: true,
            onPressed: auth.status == AuthStatus.submitting || !_termsAccepted
                ? null
                : () {
                    ref
                        .read(authControllerProvider.notifier)
                        .signUpWithPassword(
                          fullName: _nameController.text.trim(),
                          phone: _phoneController.text.trim(),
                          password: _passwordController.text,
                          email: _emailController.text.trim(),
                        );
                  },
          ),
          const SizedBox(height: AppSpacing.md),
          _GoogleSignInButton(
            label: locale.signUpWithGoogleCta,
            isLoading: auth.status == AuthStatus.submitting,
            onPressed: () {
              ref.read(authControllerProvider.notifier).signInWithGoogle();
            },
          ),
],
       ),
     );
   }
 }

class _GoogleSignInButton extends StatelessWidget {
  const _GoogleSignInButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: theme.colorScheme.outline),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
        ),
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.g_mobiledata, size: 24),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
