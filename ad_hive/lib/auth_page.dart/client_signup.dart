import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/utils/snackbar.dart';
import 'package:ad_hive/widegts/custom_textfield.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:ad_hive/widegts/text_btn.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class ClientSignUpPage extends StatefulWidget {
  const ClientSignUpPage({super.key});

  @override
  State<ClientSignUpPage> createState() => _ClientSignUpPageState();
}

class _ClientSignUpPageState extends State<ClientSignUpPage> {
  late UserAuthProvider authProvider;

  @override
  void initState() {
    super.initState();

    authProvider = Provider.of<UserAuthProvider>(context, listen: false);
  }

  bool _isSubmitting = false;
  bool _showPassword = false;

  void _handleSignUp() async {
    setState(() => _isSubmitting = true);

    final error = await authProvider.clientSignUpRequest();

    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (error == null) {
      showAppSnackbar(
        message: 'Request submitted successfully!',
        context: context,
      );

      await Future.delayed(const Duration(seconds: 1));

      if (mounted) Navigator.pushNamed(context, '/signup');
    } else {
      showAppSnackbar(message: error, isError: true, context: context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: SingleChildScrollView(
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
                              "Register Your Company",
                              style: Theme.of(
                                context,
                              ).textTheme.titleMedium?.copyWith(fontSize: 31),
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Name',
                              hint: 'Your Full Name',
                              controller: auth.nameController,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Email',
                              hint: 'example@company.com',
                              controller: auth.emailController,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Password',
                              hint: 'At least 6 characters',
                              controller: auth.passwordController,
                              obscureText: !_showPassword,
                              suffixIcon: Icon(
                                _showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: AppColors.mainBlack,
                              ),
                              onSuffixIconTap: () {
                                setState(() {
                                  _showPassword = !_showPassword;
                                });
                              },
                            ),
                            const SizedBox(height: 16),
                            CustomTextField(
                              label: 'Contact Number',
                              hint: '+92XXXXXXXXXX',
                              controller: auth.contactNumberController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),

                            PrimaryButton(
                              text:
                                  _isSubmitting
                                      ? "Submitting..."
                                      : "Submit Request",
                              onPressed: _isSubmitting ? () {} : _handleSignUp,
                            ),

                            const SizedBox(height: 16),
                            Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Already have an Account? "),
                                  PrimaryTextButton(
                                    text: "Login",
                                    size: 16,
                                    fontWeight: FontWeight.w600,
                                    onPressed: () {
                                      Navigator.pushNamed(context, '/login');
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
