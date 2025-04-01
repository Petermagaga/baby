class UserProfile {
  String name;
  int age;
  String healthConditions;
  String location;
  String job;
  String pregnancyStartDate;

  UserProfile({
    required this.name,
    required this.age,
    required this.healthConditions,
    required this.location,
    required this.job,
    required this.pregnancyStartDate,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "age": age,
      "health_conditions": healthConditions,
      "location": location,
      "job": job,
      "pregnancy_start_date": pregnancyStartDate,
    };
  }
}
