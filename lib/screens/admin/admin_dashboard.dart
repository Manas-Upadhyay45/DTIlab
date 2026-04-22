import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../models/user.dart';
import '../auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final _supabaseService = SupabaseService();
  List<UserProfile> _pendingShopkeepers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPending();
  }

  Future<void> _loadPending() async {
    setState(() => _isLoading = true);
    try {
      final list = await _supabaseService.fetchPendingShopkeepers();
      if (mounted) setState(() => _pendingShopkeepers = list);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _approve(String id) async {
    try {
      await _supabaseService.approveShopkeeper(id);
      _loadPending();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Shopkeeper approved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _supabaseService.signOut();
              if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: _pendingShopkeepers.length,
            itemBuilder: (context, index) {
              final user = _pendingShopkeepers[index];
              return ListTile(
                title: Text(user.name),
                subtitle: const Text('Pending Shopkeeper Approval'),
                trailing: ElevatedButton(
                  onPressed: () => _approve(user.id),
                  child: const Text('Approve'),
                ),
              );
            },
          ),
    );
  }
}
