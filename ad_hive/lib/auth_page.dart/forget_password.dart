import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/utils/snackbar.dart';
import 'package:ad_hive/widegts/custom_textfield.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  bool isSending = false;

  void _sendResetLink() async {
    final authProvider = Provider.of<UserAuthProvider>(context, listen: false);
    setState(() => isSending = true);

    final error = await authProvider.sendResetLink(emailController.text.trim());

    setState(() => isSending = false);

    if (!mounted) return;

    showAppSnackbar(
      context: context,
      message: error ?? "Password reset link sent to your email.",
      isError: error != null,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Card(
            color: Theme.of(context).cardColor,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Forgot Password?",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Enter your email to receive password reset link.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  CustomTextField(
                    label: 'Email',
                    hint: 'example@test.com',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    text: isSending ? "Sending..." : "Send Reset Link",
                    onPressed: isSending ? () {} : _sendResetLink,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
