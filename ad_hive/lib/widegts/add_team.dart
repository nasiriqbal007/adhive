import 'package:ad_hive/provider/auth_provider.dart';
import 'package:ad_hive/widegts/custom_textfield.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void showRegisterTeamDialog(BuildContext parentContext) {
  final authProvider = Provider.of<UserAuthProvider>(
    parentContext,
    listen: false,
  );

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Register Team Member'),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Name',
                  hint: 'Enter name',
                  controller: authProvider.nameController,
                ),
                CustomTextField(
                  label: 'Email',
                  hint: 'Enter email',
                  controller: authProvider.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                CustomTextField(
                  label: 'Phone',
                  hint: 'Enter phone number',
                  controller: authProvider.contactNumberController,
                  keyboardType: TextInputType.phone,
                ),
                CustomTextField(
                  label: 'Job Title',
                  hint: 'Enter job title',
                  controller: authProvider.jobTitleController,
                ),
                CustomTextField(
                  label: 'Country',
                  hint: 'Enter country',
                  controller: authProvider.countryController,
                ),
                CustomTextField(
                  label: 'Password',
                  hint: 'Enter password',
                  controller: authProvider.passwordController,
                  obscureText: true,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          Consumer<UserAuthProvider>(
            builder: (_, authProvider, __) {
              return PrimaryButton(
                onPressed:
                    authProvider.isSignUpLoading
                        ? () {}
                        : () {
                          authProvider.registerTeamMember().then((result) {
                            if (result == null) {
                              Navigator.pop(dialogContext);
                              Future.delayed(
                                const Duration(milliseconds: 200),
                                () {
                                  ScaffoldMessenger.of(
                                    parentContext,
                                  ).showSnackBar(
                                    const SnackBar(
                                      content: Text('Team member registered'),
                                    ),
                                  );
                                },
                              );
                            } else {
                              ScaffoldMessenger.of(
                                parentContext,
                              ).showSnackBar(SnackBar(content: Text(result)));
                            }
                          });
                        },
                text: authProvider.isLoading ? 'Registering...' : 'Register',
              );
            },
          ),
        ],
      );
    },
  );
}
