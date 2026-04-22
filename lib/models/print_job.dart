class PrintJob {
  final String id;
  final String studentName;
  final String documentName;
  final int copies;
  final bool isColor;
  final String paymentMethod; // 'Advance' or 'Cash'
  String status; // 'Pending', 'Printed', 'Collected'
  final DateTime createdAt;
  final String shopId;

  PrintJob({
    required this.id,
    required this.studentName,
    required this.documentName,
    required this.copies,
    required this.isColor,
    required this.paymentMethod,
    this.status = 'Pending',
    required this.createdAt,
    required this.shopId,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_name': studentName,
      'document_name': documentName,
      'copies': copies,
      'is_color': isColor,
      'payment_method': paymentMethod,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'shop_id': shopId,
    };
  }

  factory PrintJob.fromJson(Map<String, dynamic> json) {
    return PrintJob(
      id: json['id']?.toString() ?? '',
      studentName: json['student_name']?.toString() ?? '',
      documentName: json['document_name']?.toString() ?? '',
      copies: int.tryParse(json['copies']?.toString() ?? '1') ?? 1,
      isColor: json['is_color'] == true,
      paymentMethod: json['payment_method']?.toString() ?? 'Cash',
      status: json['status']?.toString() ?? 'Pending',
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? '') ?? DateTime.now(),
      shopId: json['shop_id']?.toString() ?? '',
    );
  }
}
