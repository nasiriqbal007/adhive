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
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final clientProvider = Provider.of<ClientProvider>(
        context,
        listen: false,
      );
      clientProvider.fetchPendingClients();
    });
  }

  Widget _buildClientApprovalCard(ClientModel client, bool isMobile) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColors.whiteColor,
        border: Border.all(color: AppColors.borderLightGrey),
      ),
      child: ListTile(
        title: Text(
          client.name ?? '',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        trailing:
            isMobile
                ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.check_circle,
                        color: AppColors.greenColor,
                      ),
                      onPressed: () async {
                        final provider = Provider.of<ClientProvider>(
                          context,
                          listen: false,
                        );
                        await provider.approveClient(
                          requestId: client.id!,
                          client: client,
                        );
                        await provider.fetchPendingClients();
                        showAppSnackbar(
                          message:
                              'Client ${client.name} approved successfully!',
                          context: context,
                        );
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.cancel, color: AppColors.redColor),
                      onPressed: () async {
                        final provider = Provider.of<ClientProvider>(
                          context,
                          listen: false,
                        );
                        await provider.rejectClient(client.id!);
                        showAppSnackbar(
                          message: 'Client ${client.name} rejected.',
                          context: context,
                        );
                      },
                    ),
                  ],
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextButton.icon(
                      icon: Icon(
                        Icons.check_circle,
                        color: AppColors.greenColor,
                        size: 20,
                      ),
                      label: Text(
                        'Approve',
                        style: TextStyle(color: AppColors.greenColor),
                      ),
                      onPressed: () async {
                        final provider = Provider.of<ClientProvider>(
                          context,
                          listen: false,
                        );
                        await provider.approveClient(
                          requestId: client.id!,
                          client: client,
                        );
                        await provider.fetchPendingClients();
                        showAppSnackbar(
                          message:
                              'Client ${client.name} approved successfully!',
                          context: context,
                        );
                      },
                    ),
                    TextButton.icon(
                      icon: Icon(
                        Icons.cancel,
                        color: AppColors.redColor,
                        size: 20,
                      ),
                      label: Text(
                        'Reject',
                        style: TextStyle(color: AppColors.redColor),
                      ),
                      onPressed: () async {
                        final provider = Provider.of<ClientProvider>(
                          context,
                          listen: false,
                        );
                        await provider.rejectClient(client.id!);
                        showAppSnackbar(
                          message: 'Client ${client.name} rejected.',
                          context: context,
                        );
                      },
                    ),
                  ],
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clientProvider = Provider.of<ClientProvider>(context);

    final filteredClients =
        clientProvider.pendingClients.where((client) {
          final name = client.name?.toLowerCase() ?? '';
          final email = client.email?.toLowerCase() ?? '';
          return name.contains(searchQuery) || email.contains(searchQuery);
        }).toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isMobile ? 0 : 20,
            vertical: isMobile ? 0 : 20,
          ),
          child: Container(
            padding: EdgeInsets.all(12),
            color: AppColors.whiteColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Client Approvals',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                AppSearchBar(
                  hintText: "Search Clients",
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value.toLowerCase();
                    });
                  },
                ),
                const SizedBox(height: 20),
                if (filteredClients.isEmpty)
                  Center(
                    child: Text(
                      'No pending client requests.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredClients.length,
                    itemBuilder:
                        (context, index) => _buildClientApprovalCard(
                          filteredClients[index],
                          isMobile,
                        ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
