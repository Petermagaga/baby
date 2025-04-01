from django.db import models
from django.contrib.auth import get_user_model

User=get_user_model()

class HealthProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="health_profile")
    age = models.IntegerField(null=True,blank=True)
    pre_existing_conditions = models.TextField(blank=True, null=True)  # E.g., Diabetes, Hypertension
    activity_level = models.CharField(
        max_length=20, choices=[("Low", "Low"), ("Moderate", "Moderate"), ("High", "High")], default="Moderate"
    )
    dietary_preferences = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"Health Profile - {self.user.username}"

class HealthRecommendation(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="health_recommendations")
    recommendation_text = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Recommendation for {self.user.username} - {self.created_at}"
