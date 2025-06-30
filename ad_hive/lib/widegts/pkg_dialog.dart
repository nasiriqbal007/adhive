import 'package:ad_hive/widegts/custom_textfield.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:flutter/material.dart';
import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/services/db_services.dart';

void showAddPackageDialog(BuildContext parentContext) {
  final nameController = TextEditingController();
  final priceController = TextEditingController();
  final durationController = TextEditingController();
  final descriptionController = TextEditingController();
  final typeController = TextEditingController(); // ✅ Type controller
  bool isActive = true;

  showDialog(
    context: parentContext,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            title: const Text('Add New Package'),
            content: SingleChildScrollView(
              child: SizedBox(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomTextField(
                      label: 'Package Name',
                      hint: 'Enter package name',
                      controller: nameController,
                    ),
                    CustomTextField(
                      label: 'Price',
                      hint: 'Enter price (e.g. 4999)',
                      controller: priceController,
                      keyboardType: TextInputType.number,
                    ),
                    CustomTextField(
                      label: 'Duration',
                      hint: 'Enter duration in months (e.g. 1, 2, 3)',

                      controller: durationController,
                      keyboardType: TextInputType.number,
                    ),
                    CustomTextField(
                      label: 'Job Type',
                      hint: 'e.g. SEO, Web, App',
                      controller: typeController,
                    ),
                    const SizedBox(height: 8),
                    CustomTextField(
                      label: 'Description',
                      hint: 'Write points separated by comma, dot or new line',
                      controller: descriptionController,
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      title: const Text('Active'),
                      value: isActive,
                      onChanged: (val) => setState(() => isActive = val),
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
              PrimaryButton(
                text: 'Add Package',
                onPressed: () async {
                  final name = nameController.text.trim();
                  final priceText = priceController.text.trim();
                  final durationText = durationController.text.trim();
                  final descText = descriptionController.text.trim();
                  final type = typeController.text.trim(); // ✅ added here

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Package name is required')),
                    );
                    return;
                  }

                  final double? price = double.tryParse(priceText);
                  if (price == null || price <= 0) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Enter a valid price')),
                    );
                    return;
                  }

                  final int? duration = int.tryParse(durationText);
                  if (duration == null || duration <= 0) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(content: Text('Enter a valid duration')),
                    );
                    return;
                  }

                  final features =
                      descText
                          .split(RegExp(r'[.,\n]+'))
                          .map((e) => e.trim())
                          .where((e) => e.isNotEmpty)
                          .take(6)
                          .toList();

                  if (features.isEmpty) {
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Please add at least one feature'),
                      ),
                    );
                    return;
                  }

                  final pointWordCounts =
                      features
                          .map(
                            (point) =>
                                point
                                    .split(RegExp(r'\s+'))
                                    .where((w) => w.isNotEmpty)
                                    .length,
                          )
                          .toList();

                  final package = PackageModel(
                    serviceName: name,
                    price: price,
                    duration: duration,
                    type: type, // ✅ now included in model
                    isActive: isActive,
                    descriptionPoints: features,
                    pointWordCounts: pointWordCounts,
                    createdAt: DateTime.now(),
                  );

                  try {
                    await DbServices().addPackage(package);
                    Navigator.pop(dialogContext);
                    ScaffoldMessenger.of(parentContext).showSnackBar(
                      const SnackBar(
                        content: Text('Package added successfully'),
                      ),
                    );
                  } catch (e) {
                    ScaffoldMessenger.of(
                      parentContext,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
              ),
            ],
          );
        },
      );
    },
  );
}
