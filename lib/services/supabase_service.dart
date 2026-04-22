import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/print_job.dart';
import '../models/user.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(email: email, password: password);
  }

  Future<AuthResponse> signUp(String email, String password, String name, String role) async {
    final response = await client.auth.signUp(
      email: email,
      password: password,
      data: {'name': name, 'role': role},
    );
    
    // Automatically insert the new user into the profiles table!
    if (response.user != null) {
      try {
        await client.from('profiles').insert({
          'id': response.user!.id,
          'name': name,
          'role': role,
          'is_approved_shopkeeper': false,
        });
      } catch (e) {
        throw Exception('Insert Failed: $e');
      }
    }
    
    return response;
  }

  Future<void> signOut() async {
    await client.auth.signOut();
  }

  Future<List<UserProfile>> fetchApprovedShopkeepers() async {
    final response = await client
        .from('profiles')
        .select()
        .eq('role', 'shopkeeper');
    return (response as List).map((data) => UserProfile.fromJson(Map<String, dynamic>.from(data))).toList();
  }

  Future<List<UserProfile>> fetchPendingShopkeepers() async {
    final response = await client
        .from('profiles')
        .select()
        .eq('role', 'shopkeeper')
        .eq('is_approved_shopkeeper', false);
    return (response as List).map((data) => UserProfile.fromJson(Map<String, dynamic>.from(data))).toList();
  }

  Future<void> approveShopkeeper(String userId) async {
    await client
        .from('profiles')
        .update({'is_approved_shopkeeper': true})
        .eq('id', userId);
  }

  Future<void> createPrintJob(PrintJob job) async {
    await client.from('print_jobs').insert(job.toJson());
  }

  Stream<List<Map<String, dynamic>>> streamJobsForShopkeeper(String shopId) {
    return client.from('print_jobs').stream(primaryKey: ['id']).eq('shop_id', shopId);
  }

  Stream<List<Map<String, dynamic>>> streamJobsForStudent(String studentName) {
    return client.from('print_jobs').stream(primaryKey: ['id']).eq('student_name', studentName);
  }

  Future<void> updateJobStatus(String jobId, String status) async {
    await client.from('print_jobs').update({'status': status}).eq('id', jobId);
  }
}
