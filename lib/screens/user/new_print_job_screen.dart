import 'package:flutter/material.dart';
import '../../models/print_job.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NewPrintJobScreen extends StatefulWidget {
  const NewPrintJobScreen({super.key});

  @override
  State<NewPrintJobScreen> createState() => _NewPrintJobScreenState();
}

class _NewPrintJobScreenState extends State<NewPrintJobScreen> {
  String? _selectedFileName;
  int _copies = 1;
  bool _isColor = false;
  String _paymentMethod = 'Cash'; 
  final _supabaseService = SupabaseService();
  List<UserProfile> _shopkeepers = [];
  String? _selectedShopId;
  bool _isLoadingShops = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  Future<void> _loadShops() async {
    try {
      final shops = await _supabaseService.fetchApprovedShopkeepers();
      if (mounted) {
        setState(() {
          _shopkeepers = shops;
          if (shops.isNotEmpty) {
            _selectedShopId = shops.first.id;
          }
          _isLoadingShops = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingShops = false);
    }
  }

  void _simulateFilePicker() {
    setState(() {
      _selectedFileName = "Assignment_Final_v2.pdf";
    });
  }

  Future<void> _submitJob() async {
    if (_selectedFileName == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a document')));
      return;
    }
    if (_selectedShopId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a print shop')));
      return;
    }

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final newJob = PrintJob(
      id: "jb_${DateTime.now().millisecondsSinceEpoch}",
      studentName: user.email ?? "Student",
      documentName: _selectedFileName!,
      copies: _copies,
      isColor: _isColor,
      paymentMethod: _paymentMethod,
      createdAt: DateTime.now().toUtc(),
      shopId: _selectedShopId!,
    );

    try {
      await _supabaseService.createPrintJob(newJob);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Print job requested successfully!')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Print')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Print Shop', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _isLoadingShops 
              ? const CircularProgressIndicator()
              : _shopkeepers.isEmpty
                ? const Text('No approved shops available.')
                : DropdownButtonFormField<String>(
                    value: _selectedShopId,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: _shopkeepers.map((shop) {
                      return DropdownMenuItem(value: shop.id, child: Text(shop.name));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedShopId = val);
                    },
                  ),
            const SizedBox(height: 32),
            const Text('Upload Document', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            InkWell(
              onTap: _simulateFilePicker,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  border: Border.all(color: Theme.of(context).colorScheme.primary),
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ),
                child: Column(
                  children: [
                    Icon(Icons.upload_file, size: 48, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 12),
                    Text(
                      _selectedFileName ?? 'Tap to select a document',
                      style: TextStyle(
                        color: _selectedFileName != null ? Colors.black : Colors.grey.shade600,
                        fontWeight: _selectedFileName != null ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Print Options', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Number of Copies', style: TextStyle(fontSize: 16)),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () {
                                if (_copies > 1) setState(() => _copies--);
                              },
                            ),
                            Text('$_copies', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              onPressed: () {
                                setState(() => _copies++);
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                    const Divider(),
                    SwitchListTile(
                      title: const Text('Color Print'),
                      subtitle: Text(_isColor ? 'Color printing is selected' : 'Black & White'),
                      value: _isColor,
                      onChanged: (val) => setState(() => _isColor = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            const Text('Payment Method', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  RadioListTile(
                    title: const Text('Pay Cash at Shop'),
                    subtitle: const Text('Hand cash directly to the shopkeeper when collecting.'),
                    value: 'Cash',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                  ),
                  const Divider(height: 1),
                  RadioListTile(
                    title: const Text('Pay in Advance (UPI/Card)'),
                    subtitle: const Text('Skip the payment line.'),
                    value: 'Advance',
                    groupValue: _paymentMethod,
                    onChanged: (val) => setState(() => _paymentMethod = val.toString()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitJob,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Submit Print Request', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
