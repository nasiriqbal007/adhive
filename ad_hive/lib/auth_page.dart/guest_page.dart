import 'dart:async';
import 'package:ad_hive/models/feedback_model.dart';
import 'package:ad_hive/models/package_model.dart';
import 'package:ad_hive/services/db_services.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/pkg_card.dart';
import 'package:ad_hive/widegts/primary_btn.dart';
import 'package:ad_hive/widegts/text_btn.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

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

  @override
  void initState() {
    super.initState();
    html.window.localStorage['guestSeen'] = 'true';
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
        _currentPage = (_currentPage + 1) % (feedbaks.length);
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
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        elevation: 0,
        title: Text(
          'Welcome to AdHive',
          style: TextStyle(
            color: AppColors.mainBlack,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          PrimaryTextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            },
            text: 'Login',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(30),
        children: [
          // Intro section
          Text(
            "Digital Solutions That Drive Results",
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "AdHive is your trusted partner in crafting modern websites, powerful SEO, and effective marketing campaigns.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Static Highlights
          Center(child: _buildSectionTitle("What We Offer")),
          const SizedBox(height: 12),
          Center(child: _buildHighlightGrid()),

          const SizedBox(height: 32),

          // Package Section
          _buildSectionTitle("Our Packages"),
          const SizedBox(height: 12),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (allPackages.isEmpty)
            const Text("No packages available")
          else
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children:
                  allPackages
                      .map(
                        (pkg) =>
                            SizedBox(width: 320, child: PackageCard(pkg: pkg)),
                      )
                      .toList(),
            ),

          const SizedBox(height: 40),

          // Feedback
          _buildSectionTitle("What Clients Say"),
          const SizedBox(height: 16),
          if (feedbaks.isEmpty)
            const Text("No feedback available")
          else
            SizedBox(
              height:
                  MediaQuery.of(context).size.width < 600
                      ? MediaQuery.of(context).size.height * 0.290
                      : MediaQuery.of(context).size.height * 0.240,
              child: PageView.builder(
                controller: _pageController,
                itemCount: feedbaks.length,
                itemBuilder: (_, index) {
                  final item = feedbaks[index];
                  return _buildFeedbackCard(
                    item.clientName ?? 'Unknown',
                    item.feedback ?? "N/A",
                  );
                },
              ),
            ),

          const SizedBox(height: 40),

          // Final CTA
          _buildSectionTitle("Why Choose Us?"),
          const SizedBox(height: 8),
          Text(
            "✅ Expert Team\n✅ Timely Delivery\n✅ Affordable Packages\n✅ Real Results\n✅ Full Support",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 32),
          Center(
            child: SizedBox(
              height: 30,
              width: 300,
              child: PrimaryButton(
                text: "Get Started",
                onPressed: () => Navigator.pushNamed(context, '/signup'),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  Widget _buildHighlightGrid() {
    final items = [
      {"icon": Icons.web, "text": "Modern Websites"},
      {"icon": Icons.analytics, "text": "SEO & Ranking"},
      {"icon": Icons.campaign, "text": "Digital Marketing"},
      {"icon": Icons.design_services, "text": "UI/UX Design"},
    ];

    return Wrap(
      spacing: 20,
      runSpacing: 20,
      children:
          items.map((item) {
            return Container(
              width: 200,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.whiteColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLightGrey),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item["icon"] as IconData,
                    size: 50,
                    color: AppColors.primary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item["text"] as String,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildFeedbackCard(String name, String feedback) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          border: Border.all(color: AppColors.borderLightGrey),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(feedback, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
