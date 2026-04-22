import 'package:flutter/material.dart';
import '../models/print_job.dart';

class MockDb extends ChangeNotifier {
  static final MockDb instance = MockDb._internal();

  MockDb._internal();

  final List<PrintJob> _jobs = [
    // Pre-populate with some mock data for the shopkeeper
    PrintJob(
      id: "jb_001",
      studentName: "Alice Smith",
      documentName: "Physics_Assignment.pdf",
      copies: 2,
      isColor: false,
      paymentMethod: "Advance",
      status: "Pending",
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      shopId: "shop_001",
    ),
    PrintJob(
      id: "jb_002",
      studentName: "Bob Jones",
      documentName: "Event_Poster.png",
      copies: 50,
      isColor: true,
      paymentMethod: "Cash",
      status: "Pending",
      createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
      shopId: "shop_001",
    ),
  ];

  // Dummy student name for the sake of presentation
  final String currentStudentName = "John Doe";

  List<PrintJob> get allJobs => List.unmodifiable(_jobs);

  List<PrintJob> get pendingJobs =>
      _jobs.where((j) => j.status == 'Pending').toList();

  List<PrintJob> get completedJobs => _jobs
      .where((j) => j.status == 'Printed' || j.status == 'Collected')
      .toList();

  List<PrintJob> jobsForStudent(String name) =>
      _jobs.where((j) => j.studentName == name).toList();

  void addJob(PrintJob job) {
    _jobs.insert(0, job); // Add to top
    notifyListeners();
  }

  void updateJobStatus(String id, String newStatus) {
    final index = _jobs.indexWhere((j) => j.id == id);
    if (index != -1) {
      _jobs[index].status = newStatus;
      notifyListeners();
    }
  }
}
