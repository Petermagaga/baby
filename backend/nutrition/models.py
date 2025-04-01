from django.db import models
from django.contrib.auth import get_user_model

User=get_user_model()


class NutritionGuide(models.Model):
    trimester = models.IntegerField(choices=[(1, "First Trimester"), (2, "Second Trimester"), (3, "Third Trimester")])
    common_symptoms = models.TextField(help_text="Symptoms like nausea, fatigue")
    recommended_foods = models.TextField(help_text="Foods beneficial for this stage")
    foods_to_avoid = models.TextField(help_text="Harmful foods for this stage")
    key_nutrients = models.TextField(help_text="Nutrients needed at this stage")

    def __str__(self):
        return f"Trimester {self.trimester} Guide"

class DailyMealPlan(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="meal_plans")
    date = models.DateField(auto_now_add=True)
    breakfast = models.TextField(help_text="Breakfast meal plan")
    lunch = models.TextField(help_text="Lunch meal plan")
    dinner = models.TextField(help_text="Dinner meal plan")
    snacks = models.TextField(help_text="Recommended snacks")

    def __str__(self):
        return f"{self.user.username} - {self.date}"
