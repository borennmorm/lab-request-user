import 'package:intl/intl.dart';

class Request {
  final int? id;
  final int labId;
  final int sessionId;
  final int userId;
  final DateTime requestDate;
  final String major;
  final String subject;
  final int generation;
  final String softwareNeed;
  final int numberOfStudent;
  final String? additional;

  Request({
    this.id,
    required this.labId,
    required this.sessionId,
    required this.userId,
    required this.requestDate,
    required this.major,
    required this.subject,
    required this.generation,
    required this.softwareNeed,
    required this.numberOfStudent,
    this.additional,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      id: json['id'],
      labId: json['lab_id'],
      sessionId: json['session_id'],
      userId: json['user_id'],
      requestDate: DateTime.parse(json['request_date']),
      major: json['major'],
      subject: json['subject'],
      generation: json['generation'],
      softwareNeed: json['software_need'],
      numberOfStudent: json['number_of_student'],
      additional: json['additional'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lab_id': labId,
      'session_id': sessionId,
      'user_id': userId,
      'request_date': DateFormat('yyyy-MM-dd').format(requestDate),
      'major': major,
      'subject': subject,
      'generation': generation,
      'software_need': softwareNeed,
      'number_of_student': numberOfStudent,
      'additional': additional,
    };
  }
}
