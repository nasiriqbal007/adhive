import 'package:ad_hive/models/client_model.dart';
import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/utils/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:ad_hive/utils/app_colors.dart';
import 'package:ad_hive/widegts/serachbar.dart';
import 'package:provider/provider.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _AdminRequestPageState();
}

class _AdminRequestPageState extends State<RequestPage>
    with TickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, String>> deadlineRequests = [
    {
      'member': 'Web Dev Team',
      'task': 'Landing Page',
      'currentDeadline': '2025-06-25',
      'requested': '2025-07-05',
    },
    {
      'member': 'SEO Team',
      'task': 'Keyword Research',
      'currentDeadline': '2025-06-28',
      'requested': '2025-07-02',
    },
  ];

  final List<Map<String, String>> packageExpiryAlerts = [
    {
      'client': 'Ali Khan',
      'package': 'Web Development',
      'expiryDate': '2025-06-30',
    },
    {
      'client': 'Sara Ahmed',
      'package': 'SEO Package',
      'expiryDate': '2025-06-29',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      clientProvider.fetchPendingClients();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Widget _buildClientApprovalCard(ClientModel client) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.borderLightGrey),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          client.name ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${client.email} - Packages: ${client.packages?.join(", ") ?? "None"}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () async {
                final provider = Provider.of<ClientProvider>(
                  context,
                  listen: false,
                );
                provider.approveClient(requestId: client.id!, client: client);
                await provider.fetchPendingClients();

                showAppSnackbar(
                  message: 'Client ${client.name} approved successfully!',
                  context: context,
                );
              },
              child: Text(
                'Approve',
                style: TextStyle(color: AppColors.greenColor),
              ),
            ),
            TextButton(
              onPressed: () {
                // Optionally implement reject logic
              },
              child: Text(
                'Reject',
                style: TextStyle(color: AppColors.redColor),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineRequestCard(Map<String, String> request) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.borderLightGrey),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          '${request['member']} - ${request['task']}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          'Current: ${request['currentDeadline']} → Requested: ${request['requested']}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {},
              child: Text(
                'Approve',
                style: TextStyle(color: AppColors.greenColor),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: Text('Deny', style: TextStyle(color: AppColors.redColor)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPackageExpiryCard(Map<String, String> alert) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.borderLightGrey),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(
          alert['client'] ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          'Package: ${alert['package']} expires on ${alert['expiryDate']}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        trailing: TextButton(
          onPressed: () {},
          child: Text('Extend', style: TextStyle(color: AppColors.primary)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 0 : 20,
              vertical: isMobile ? 0 : 20,
            ),
            child: Container(
              padding: const EdgeInsets.all(15),
              color: AppColors.whiteColor,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child:
                        isMobile
                            ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Requests Overview',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                AppSearchBar(
                                  hintText: "Search Requests",
                                  onChanged: (String v) {},
                                ),
                              ],
                            )
                            : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Requests Overview',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                SizedBox(
                                  width: 200,
                                  child: AppSearchBar(
                                    hintText: "Search Requests",
                                    onChanged: (String v) {},
                                  ),
                                ),
                              ],
                            ),
                  ),

                  // Tabs
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: TabBar(
                      controller: _tabController,
                      labelColor: Colors.black,
                      indicatorColor: AppColors.primary,
                      tabs: const [
                        Tab(text: 'Client Approvals'),
                        Tab(text: 'Deadline Requests'),
                        Tab(text: 'Expiry Alerts'),
                      ],
                    ),
                  ),

                  // Tab Contents
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.75,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        ListView.builder(
                          itemCount: clientProvider.pendingClients.length,
                          itemBuilder: (context, index) {
                            final client = clientProvider.pendingClients[index];
                            return _buildClientApprovalCard(client);
                          },
                        ),
                        ListView.builder(
                          itemCount: deadlineRequests.length,
                          itemBuilder:
                              (context, index) => _buildDeadlineRequestCard(
                                deadlineRequests[index],
                              ),
                        ),
                        ListView.builder(
                          itemCount: packageExpiryAlerts.length,
                          itemBuilder:
                              (context, index) => _buildPackageExpiryCard(
                                packageExpiryAlerts[index],
                              ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
