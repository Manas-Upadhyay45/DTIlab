import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/supabase_service.dart';
import '../user/user_dashboard.dart';
import '../shopkeeper/shopkeeper_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabaseService = SupabaseService();
  bool _isLoading = false;

  Future<void> _login() async {
    setState(() => _isLoading = true);
    try {
      final authResp = await _supabaseService.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (authResp.user != null) {
        Map<String, dynamic>? userProfile;
        try {
          userProfile = await Supabase.instance.client
              .from('profiles')
              .select()
              .eq('id', authResp.user!.id)
              .maybeSingle();
        } catch (_) {}
            
        if (userProfile == null) {
          final meta = authResp.user!.userMetadata ?? {};
          final name = meta['name']?.toString() ?? 'User';
          final role = meta['role']?.toString() ?? 'student';
          try {
             await Supabase.instance.client.from('profiles').insert({
               'id': authResp.user!.id,
               'name': name,
               'role': role,
               'is_approved_shopkeeper': false,
             });
          } catch (e) {
             throw Exception('Login Insert Failed: $e');
          }
          userProfile = {
            'role': role,
            'is_approved_shopkeeper': false,
          };
        }

        final role = userProfile['role']?.toString() ?? 'student';

        if (!mounted) return;

        if (role == 'shopkeeper') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ShopkeeperDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const UserDashboard()));
        }
      }
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Exact Error'),
            content: Text(e.toString()),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))
            ],
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campus Print Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 16),
              TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
              const SizedBox(height: 32),
              _isLoading 
                ? const CircularProgressIndicator()
                : FilledButton(onPressed: _login, child: const Text('Login')),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                },
                child: const Text('Create an account'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
