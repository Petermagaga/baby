from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class PregnancyStage(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    week = models.IntegerField()  # Week number (1-40)
    symptoms = models.TextField()  # Expected symptoms
    baby_development = models.TextField()  # Baby growth details
    health_tips = models.TextField()  # Health & nutrition tips
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Week {self.week} - {self.user.username}"
    

class Notification(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)
    sent = models.BooleanField(default=False)

    def __str__(self):
        return f"Notification for {self.user.username}"

