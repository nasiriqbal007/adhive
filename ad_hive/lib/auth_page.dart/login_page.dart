import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/utils/snackbar.dart';
import 'package:ad_hive/widegts/custom_textfield.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:ad_hive/widegts/text_btn.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late UserAuthProvider authProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    authProvider = Provider.of<UserAuthProvider>(context, listen: false);
  }

  void _handleLogin() async {
    final error = await authProvider.loginUser(
      email: authProvider.loginEmailController.text.trim(),
      password: authProvider.loginPasswordController.text.trim(),
    );

    if (!mounted) return;

    if (error == null) {
      showAppSnackbar(message: 'Logged in successfully!', context: context);
      context.go('/');
    } else if (error.isNotEmpty) {
      showAppSnackbar(message: error, isError: true, context: context);
    }
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
              padding: const EdgeInsets.all(12),
              child: Consumer<UserAuthProvider>(
                builder:
                    (context, auth, _) => Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Welcome!",
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w300),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Log in to",
                          style: Theme.of(
                            context,
                          ).textTheme.titleMedium?.copyWith(fontSize: 31),
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Email',
                          hint: 'example@test.com',
                          controller: auth.loginEmailController,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Password',
                          hint: 'Password',
                          controller: auth.loginPasswordController,
                          obscureText: !auth.isLoginPasswordVisible,
                          suffixIcon: Icon(
                            auth.isLoginPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.mainBlack,
                          ),
                          onSuffixIconTap: auth.toggleLoginPasswordVisibility,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: auth.isRememberMe,
                                  onChanged:
                                      (val) =>
                                          auth.toggleRememberMe(val ?? false),
                                ),
                                Text(
                                  "Remember me",
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                              ],
                            ),
                            PrimaryTextButton(
                              text: "Forgot Password?",
                              onPressed: () {
                                context.push('/forgot-password');
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          text: auth.isLoginLoading ? "Logging in..." : "Login",
                          onPressed: auth.isLoginLoading ? () {} : _handleLogin,
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("Don’t have an Account? "),
                              PrimaryTextButton(
                                text: "Register",
                                size: 16,
                                fontWeight: FontWeight.w600,
                                onPressed: () {
                                  context.go('/signup');
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                        Center(
                          child: PrimaryTextButton(
                            size: 16,
                            fontWeight: FontWeight.w600,
                            text: "Continue as Guest",
                            onPressed: () {
                              context.go('/guest-dashboard');
                            },
                          ),
                        ),
                      ],
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
