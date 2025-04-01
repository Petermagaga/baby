
from django.db import models
from django.contrib.auth import get_user_model

User=get_user_model()

class FAQ(models.Model):
    question = models.CharField(max_length=255)
    answer = models.TextField()
    category = models.CharField(
        max_length=50, choices=[("Pregnancy", "Pregnancy"), ("Postnatal", "Postnatal"), ("General", "General")]
    )

    def __str__(self):
        return self.question

class ExpertQuestion(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="expert_questions")
    question = models.TextField()
    answer = models.TextField(blank=True, null=True)
    answered_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name="answered_questions")
    created_at = models.DateTimeField(auto_now_add=True)
    answered_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"Question by {self.user.username}"
