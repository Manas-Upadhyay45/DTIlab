import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import '../auth/login_screen.dart';

class ShopkeeperDashboard extends StatefulWidget {
  const ShopkeeperDashboard({super.key});

  @override
  State<ShopkeeperDashboard> createState() => _ShopkeeperDashboardState();
}

class _ShopkeeperDashboardState extends State<ShopkeeperDashboard> {
  final _supabaseService = SupabaseService();
  final _shopId = Supabase.instance.client.auth.currentUser?.id;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Shopkeeper Dashboard'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await _supabaseService.signOut();
                if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            )
          ],
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Pending Requests'),
              Tab(text: 'Completed / History'),
            ],
          ),
        ),
        body: StreamBuilder<List<Map<String, dynamic>>>(
          stream: _shopId != null ? _supabaseService.streamJobsForShopkeeper(_shopId!) : null,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            final allJobs = snapshot.data ?? [];
            final pending = allJobs.where((j) => j['status'] == 'Pending').toList();
            final completed = allJobs.where((j) => j['status'] != 'Pending').toList();

            return TabBarView(
              children: [
                _buildJobList(pending, true),
                _buildJobList(completed, false),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildJobList(List<Map<String, dynamic>> jobs, bool isPendingTab) {
    if (jobs.isEmpty) {
      return Center(
        child: Text(
          isPendingTab ? 'No pending requests.' : 'No completed jobs yet.',
          style: const TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16.0),
      itemCount: jobs.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        return _ShopJobCard(job: jobs[index]);
      },
    );
  }
}

class _ShopJobCard extends StatelessWidget {
  final Map<String, dynamic> job;

  const _ShopJobCard({required this.job});

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.parse(job['created_at']);
    final timeStr = DateFormat('hh:mm a').format(createdAt);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  job['student_name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                Text(timeStr, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.description, size: 20, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    job['document_name'],
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Copies', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text('${job['copies']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Color', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(job['is_color'] == true ? 'Yes' : 'No', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Payment', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(job['payment_method'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (job['status'] == 'Pending') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () async {
            await SupabaseService().updateJobStatus(job['id'], 'Printed');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Printed.')));
          },
          icon: const Icon(Icons.print),
          label: const Text('Mark as Printed'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.orange,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    } else if (job['status'] == 'Printed') {
      return SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () async {
            await SupabaseService().updateJobStatus(job['id'], 'Collected');
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Marked as Collected.')));
          },
          icon: const Icon(Icons.check_circle),
          label: const Text('Mark as Collected'),
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
    } else {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Job Completed & Collected',
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }
  }
}
