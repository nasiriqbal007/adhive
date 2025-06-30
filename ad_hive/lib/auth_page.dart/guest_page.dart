import 'dart:async';
import 'package:ad_hive/models/feedback_model.dart';
import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/services/db_services.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/pkg_card.dart';
import 'package:flutter/material.dart';

class GuestDashBoardPage extends StatefulWidget {
  const GuestDashBoardPage({super.key});

  @override
  State<GuestDashBoardPage> createState() => _GuestPackagesPageState();
}

class _GuestPackagesPageState extends State<GuestDashBoardPage> {
  List<PackageModel> allPackages = [];
  List<FeedbackModel> feedbaks = [];
  bool isLoading = true;

  final PageController _pageController = PageController(viewportFraction: 0.85);
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, String>> dummyFeedbacks = [
    {
      "name": "Ali Raza",
      "feedback": "Great service! Loved the professionalism.",
    },
    {"name": "Sara Khan", "feedback": "Timely delivery and great support."},
    {
      "name": "John Doe",
      "feedback": "Affordable packages and effective results.",
    },
    {"name": "Fatima Noor", "feedback": "Amazing team, will hire again."},
  ];

  @override
  void initState() {
    super.initState();
    fetchPackages();
    fetchFeedBacks();
    startAutoSlide();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void startAutoSlide() {
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= dummyFeedbacks.length) _currentPage = 0;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  Future<void> fetchPackages() async {
    final result = await DbServices().fetchAllPackages();
    setState(() {
      allPackages = result;
      isLoading = false;
    });
  }

  Future<void> fetchFeedBacks() async {
    final result = await DbServices().fetchAllFeedbacks();
    setState(() {
      feedbaks = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        color: AppColors.whiteColor,
        child: ListView(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "Our Packages",
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (allPackages.isEmpty)
              const Center(child: Text("No packages available"))
            else
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children:
                    allPackages
                        .map(
                          (pkg) => SizedBox(
                            width: 320,
                            child: PackageCard(pkg: pkg),
                          ),
                        )
                        .toList(),
              ),

            const SizedBox(height: 40),
            Text(
              "Client Feedback",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child: PageView.builder(
                controller: _pageController,
                itemCount: feedbaks.length,
                itemBuilder: (_, index) {
                  final item = feedbaks[index];
                  return _buildFeedbackCard(
                    item.clientName ?? 'Unkown',
                    item.feedback ?? "N/A",
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard(String name, String feedback) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(color: AppColors.borderLightGrey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(name, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(feedback, style: Theme.of(context).textTheme.titleSmall),
          ],
        ),
      ),
    );
  }
}
