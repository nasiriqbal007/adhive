import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:ad_hive/provider/client_provider.dart';
import 'package:ad_hive/widegts/serachbar.dart';
import 'package:ad_hive/utils/app_colors.dart';

class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});

  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ClientProvider>(
        context,
        listen: false,
      ).fetchApprovedClients();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ClientProvider>(context);
    final clients = provider.approvedClients;

    final filteredClients =
        clients.where((client) {
          final query = searchQuery.toLowerCase();
          final name = client.name?.toLowerCase() ?? '';
          final email = client.email?.toLowerCase() ?? '';
          return name.contains(query) || email.contains(query);
        }).toList();

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
                  // ✅ Header
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Customers',
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
                            hintText: "Search Member",
                            onChanged: (String v) {
                              setState(() {
                                searchQuery = v;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ✅ Table
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minWidth: constraints.minWidth,
                      ),
                      child: DataTable(
                        headingTextStyle: Theme.of(
                          context,
                        ).textTheme.bodySmall?.copyWith(fontSize: 13),
                        dataTextStyle: Theme.of(context).textTheme.titleSmall,
                        columns: const [
                          DataColumn(label: Text('Client Name')),

                          DataColumn(label: Text('Phone Number')),
                          DataColumn(label: Text('Email')),
                          DataColumn(label: Text('Joined On')),
                          DataColumn(label: Text('Packages')),
                        ],
                        rows:
                            filteredClients.asMap().entries.map((entry) {
                              final client = entry.value;

                              return DataRow(
                                cells: [
                                  DataCell(Text(client.name ?? '')),

                                  DataCell(Text(client.contactNumber ?? '')),
                                  DataCell(Text(client.email ?? '')),
                                  DataCell(
                                    Text(
                                      client.approvedAt != null
                                          ? "${client.approvedAt!.toDate().toLocal().year}/${client.approvedAt!.toDate().toLocal().month.toString().padLeft(2, '0')}/${client.approvedAt!.toDate().toLocal().day.toString().padLeft(2, '0')}"
                                          : "Not Approved",
                                    ),
                                  ),
                                  DataCell(
                                    Text('${client.packages?.length ?? 0}'),
                                  ),
                                ],
                              );
                            }).toList(),
                      ),
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
