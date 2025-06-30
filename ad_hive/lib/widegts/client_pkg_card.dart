import 'package:ad_hive/models/client_model.dart';
import 'package:ad_hive/utils/date_format.dart';
import 'package:flutter/material.dart';

import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/utils/app_colors.dart';

class ClientPackageCard extends StatelessWidget {
  final ClientPackage clientPackage;
  final PackageModel packageModel;

  const ClientPackageCard({
    super.key,
    required this.clientPackage,
    required this.packageModel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.whiteColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLightGrey),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            packageModel.serviceName ?? '-',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 10),

          // Price
          Text(
            'Rs. ${packageModel.price}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Text(
            'Start: ${formatDate(clientPackage.startDate)}',
            style: const TextStyle(color: Colors.black87),
          ),
          Text(
            'Expiry: ${formatDate(clientPackage.expiryDate)}',
            style: const TextStyle(color: Colors.black87),
          ),

          const SizedBox(height: 10),

          // Description points
          ...?packageModel.descriptionPoints?.map(
            (point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  const Icon(Icons.circle, size: 6, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(point, style: const TextStyle(fontSize: 14)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
