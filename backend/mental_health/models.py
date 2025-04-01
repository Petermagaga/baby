from django.db import models
from django.contrib.auth import get_user_model

User=get_user_model()


class CounselingSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="counseling_sessions")
    counselor_name = models.CharField(max_length=255)
    session_date = models.DateTimeField()
    session_notes = models.TextField(blank=True, null=True)
    status = models.CharField(
        max_length=20,
        choices=[("Pending", "Pending"), ("Confirmed", "Confirmed"), ("Completed", "Completed")],
        default="Pending"
    )

    def __str__(self):
        return f"Session with {self.counselor_name} - {self.user.username}"

class MotivationalMessage(models.Model):
    message = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Motivational Message - {self.created_at}"
