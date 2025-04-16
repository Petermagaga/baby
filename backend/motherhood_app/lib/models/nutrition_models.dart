class NutritionGuide {
  final String trimester;
  final String recommendations;

  NutritionGuide({required this.trimester, required this.recommendations});

  factory NutritionGuide.fromJson(Map<String, dynamic> json) {
    return NutritionGuide(
      trimester: json['trimester'],
      recommendations: json['recommendations'],
    );
  }
}

class DailyMeal {
  // Fields from both versions
  final String? breakfast;
  final String? lunch;
  final String? dinner;
  final String? date;
  final String? title;
  final String? description;

  // Constructor to initialize all fields
  DailyMeal({
    this.breakfast,
    this.lunch,
    this.dinner,
    this.date,
    this.title,
    this.description,
  });

  // Factory constructor to create a DailyMeal from JSON
  factory DailyMeal.fromJson(Map<String, dynamic> json) {
    return DailyMeal(
      breakfast: json['breakfast'],
      lunch: json['lunch'],
      dinner: json['dinner'],
      date: json['date'],
      title: json['title'],        // Assuming the API might return title and description
      description: json['description'],
    );
  }
}
