import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/models/client_model.dart';
import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/services/db_services.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/client_pkg_card.dart';
import 'package:ad_hive/widegts/pkg_card.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:ad_hive/widegts/serachbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CleintPackagesPage extends StatefulWidget {
  const CleintPackagesPage({super.key});

  @override
  State<CleintPackagesPage> createState() => _CleintPackagesPageState();
}

class _CleintPackagesPageState extends State<CleintPackagesPage> {
  List<PackageModel> allPackages = [];
  List<PackageModel> recommendedPackages = [];
  List<ClientPackage> clientPackages = [];
  bool isLoading = true;
  bool showRecommendedOnly = true;

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final clientId = user.uid;
    final clientProvider = Provider.of<ClientProvider>(context, listen: false);
    final client = await clientProvider.fetchClientPackagesByUserId(clientId);

    final result = await DbServices().fetchAllPackages();
    final clientTypes =
        client?.packages
            ?.map((cp) {
              final match = result.firstWhere(
                (p) => p.id == cp.packageId,
                orElse: () => PackageModel(),
              );
              return match.type;
            })
            .whereType<String>()
            .toSet();

    final recommended =
        result
            .where((pkg) => clientTypes?.contains(pkg.type) ?? false)
            .toList();

    setState(() {
      allPackages = result;
      recommendedPackages = recommended;
      clientPackages = client?.packages ?? [];
      isLoading = false;
    });
  }

  Future<void> buyPackage(PackageModel pkg) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final expiry = now.add(Duration(days: (pkg.duration ?? 1) * 30));

    final newClientPackage = ClientPackage(
      packageId: pkg.id ?? '',
      startDate: now,
      expiryDate: expiry,
    );

    await DbServices().buyPackageForClient(
      clientId: user.uid,
      clientPackage: newClientPackage,
    );

    await fetchPackages();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Package bought successfully!")));
  }

  Future<void> simulatePaymentAndBuy(PackageModel pkg) async {
    final phoneController = TextEditingController();
    final cnicController = TextEditingController();

    bool confirmed =
        await showDialog<bool>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text("Fake JazzCash Payment"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: phoneController,
                    decoration: InputDecoration(labelText: "JazzCash Number"),
                    keyboardType: TextInputType.phone,
                  ),
                  TextField(
                    controller: cnicController,
                    decoration: InputDecoration(labelText: "CNIC"),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed:
                      () =>
                          Navigator.of(context, rootNavigator: true).pop(false),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    final phone = phoneController.text.trim();
                    final cnic = cnicController.text.trim();

                    if (phone.isNotEmpty && cnic.isNotEmpty) {
                      Navigator.of(context, rootNavigator: true).pop(true);
                    }
                  },
                  child: Text("Confirm"),
                ),
              ],
            );
          },
        ) ??
        false;

    if (confirmed) {
      await buyPackage(pkg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayPackages =
        showRecommendedOnly ? recommendedPackages : allPackages;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(16),
        color: AppColors.whiteColor,
        child: ListView(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 20,
                  ),
                  child:
                      isWide
                          ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Packages",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              SizedBox(
                                width: 250,
                                child: AppSearchBar(
                                  hintText: "Search Package",
                                  onChanged: (s) {},
                                ),
                              ),
                            ],
                          )
                          : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Packages",
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              AppSearchBar(
                                hintText: "Search Package",
                                onChanged: (s) {},
                              ),
                            ],
                          ),
                );
              },
            ),
            const SizedBox(height: 10),
            if (clientPackages.isNotEmpty) ...[
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children:
                      clientPackages.map((cp) {
                        final matchingPackage = allPackages.firstWhere(
                          (pkg) => pkg.id == cp.packageId,
                          orElse:
                              () => PackageModel(
                                serviceName: "Not Found",
                                price: 0,
                              ),
                        );
                        return Padding(
                          padding: const EdgeInsets.only(right: 16.0),
                          child: SizedBox(
                            width: 320,
                            child: ClientPackageCard(
                              clientPackage: cp,
                              packageModel: matchingPackage,
                            ),
                          ),
                        );
                      }).toList(),
                ),
              ),
              const SizedBox(height: 30),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  showRecommendedOnly ? "Recommended Packages" : "All Packages",
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                TextButton(
                  onPressed: () {
                    setState(() {
                      showRecommendedOnly = !showRecommendedOnly;
                    });
                  },
                  child: Text(
                    showRecommendedOnly ? "Show All" : "Show Recommended",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (displayPackages.isEmpty)
              const Center(child: Text("No packages found"))
            else
              SingleChildScrollView(
                child: Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children:
                      displayPackages.map((pkg) {
                        final alreadyBought = clientPackages.any(
                          (cp) => cp.packageId == pkg.id,
                        );
                        return SizedBox(
                          width: 320,

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              PackageCard(pkg: pkg),
                              const SizedBox(height: 8),
                              ConstrainedBox(
                                constraints: BoxConstraints(maxWidth: 200),
                                child: PrimaryButton(
                                  onPressed:
                                      alreadyBought
                                          ? () {}
                                          : () => simulatePaymentAndBuy(pkg),
                                  text: alreadyBought ? "Purchased" : "Buy",
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
