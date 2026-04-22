import 'package:supabase/supabase.dart';

Future<void> main() async {
  final client = SupabaseClient(
    'https://oaicbhaourwpvsotgpur.supabase.co', 
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9haWNiaGFvdXJ3cHZzb3RncHVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3ODQwMTEsImV4cCI6MjA5MjM2MDAxMX0.x2h7zCBTiJaz72-7w2iayQDbEBsGIcqDkohGeLXLRoY'
  );
  try {
    final email = 'bot_${DateTime.now().millisecondsSinceEpoch}@test.com';
    final authResp = await client.auth.signUp(password: 'password123', email: email);
    final uid = authResp.user!.id;
    await client.from('profiles').insert({
      'id': uid,
      'name': 'Test Robot',
      'role': 'student',
      'is_approved_shopkeeper': false,
    });
    print('### SUCCESS ###');
  } catch (e) {
    print('### FAILURE: $e ###');
  }
}
