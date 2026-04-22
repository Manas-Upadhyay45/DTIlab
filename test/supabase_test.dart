import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  test('Testing Supabase Insert restrictions natively...', () async {
    SupabaseClient client;
    try {
      client = SupabaseClient(
        'https://oaicbhaourwpvsotgpur.supabase.co', 
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9haWNiaGFvdXJ3cHZzb3RncHVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3ODQwMTEsImV4cCI6MjA5MjM2MDAxMX0.x2h7zCBTiJaz72-7w2iayQDbEBsGIcqDkohGeLXLRoY'
      );
    } catch (e) {
      throw Exception('Failed to init client: $e');
    }
    
    final email = 'robot_${DateTime.now().millisecondsSinceEpoch}@test.com';
    
    try {
      final authResp = await client.auth.signUp(password: 'dummyPassword123', email: email);
      final uid = authResp.user!.id;
      
      await client.from('profiles').insert({
        'id': uid,
        'name': 'Test Robot',
        'role': 'student',
        'is_approved_shopkeeper': false,
      });
      
    } catch(e) {
      throw Exception('!!! FATAL DATABASE REJECTION: $e !!!');
    }
  });
}
