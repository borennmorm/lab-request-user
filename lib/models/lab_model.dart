class LabModel {
  final int id;
  final String name;
  final String building;
  final bool labStatus;

  LabModel({
    required this.id,
    required this.name,
    required this.building,
    required this.labStatus,
  });

  factory LabModel.fromJson(Map<String, dynamic> json) {
    return LabModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      building: json['building'] as String? ?? '',
      labStatus: json['lab_status'] is bool
          ? json['lab_status']
          : json['lab_status'] == 1, // Convert to boolean if stored as 1 or 0
    );
  }
}
