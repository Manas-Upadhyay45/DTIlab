import 'dart:convert';
import 'dart:io';

void main() async {
  final url = Uri.parse('https://oaicbhaourwpvsotgpur.supabase.co/rest/v1/profiles');
  final key = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9haWNiaGFvdXJ3cHZzb3RncHVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzY3ODQwMTEsImV4cCI6MjA5MjM2MDAxMX0.x2h7zCBTiJaz72-7w2iayQDbEBsGIcqDkohGeLXLRoY';
  
  final request = await HttpClient().getUrl(url);
  request.headers.add('apikey', key);
  request.headers.add('Authorization', 'Bearer ' + key);
  
  final response = await request.close();
  final responseBody = await response.transform(utf8.decoder).join();
  
  print('HTTP STATUS: ' + response.statusCode.toString());
  print('BODY: ' + responseBody);
}
