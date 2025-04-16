class Pregnancy {
  final DateTime startDate;
  final DateTime dueDate;
  final int weeksPregnant;
  final int trimester;

  Pregnancy({
    required this.startDate,
    required this.dueDate,
    required this.weeksPregnant,
    required this.trimester,
  });

  factory Pregnancy.fromJson(Map<String, dynamic> json) {
    return Pregnancy(
      startDate: DateTime.parse(json['start_date']),
      dueDate: DateTime.parse(json['due_date']),
      weeksPregnant: json['weeks_pregnant'],
      trimester: json['trimester'],
    );
  }
}
