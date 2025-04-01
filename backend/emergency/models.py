from django.db import models
from django.contrib.auth import get_user_model

User=get_user_model()

class EmergencyContact(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="emergency_contacts")
    name = models.CharField(max_length=255)
    phone_number = models.CharField(max_length=20)
    relationship = models.CharField(
        max_length=50, choices=[("Doctor", "Doctor"), ("Family", "Family"), ("Hospital", "Hospital")]
    )
    is_primary = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.name} - {self.relationship}"

class EmergencyAlert(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="emergency_alerts")
    alert_message = models.TextField()
    sent_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Alert from {self.user.username} at {self.sent_at}"
