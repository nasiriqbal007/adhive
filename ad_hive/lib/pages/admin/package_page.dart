import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/services/db_services.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/pkg_card.dart';
import 'package:ad_hive/widegts/pkg_dialog.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:ad_hive/widegts/serachbar.dart';
import 'package:flutter/material.dart';

class PackagePage extends StatefulWidget {
  const PackagePage({super.key});

  @override
  State<PackagePage> createState() => _PackagePageState();
}

class _PackagePageState extends State<PackagePage> {
  List<PackageModel> packages = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPackages();
  }

  Future<void> fetchPackages() async {
    final result = await DbServices().fetchAllPackages();
    setState(() {
      packages = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        color: AppColors.whiteColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                if (isWide) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 20,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Packages (${packages.length})",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Row(
                          children: [
                            SizedBox(
                              width: 250,

                              child: AppSearchBar(
                                hintText: "Search Package",
                                onChanged: (s) {},
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 250,
                              child: PrimaryButton(
                                text: "Add Package",
                                onPressed: () async {
                                  showAddPackageDialog(context);
                                  fetchPackages();
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                } else {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 20,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Packages (${packages.length})",
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        AppSearchBar(
                          hintText: "Search Package",
                          onChanged: (s) {},
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: PrimaryButton(
                            text: "Add New",
                            onPressed: () async {
                              showAddPackageDialog(context);
                              fetchPackages();
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),

            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (packages.isEmpty)
              const Center(child: Text("No packages found"))
            else
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SingleChildScrollView(
                    child: Wrap(
                      alignment: WrapAlignment.start,
                      spacing: 16,
                      runSpacing: 16,
                      children:
                          packages.map((pkg) {
                            return PackageCard(pkg: pkg);
                          }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
