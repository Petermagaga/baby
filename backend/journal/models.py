from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class PregnancyJournal(models.Model):
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="journals",  
    )
    date = models.DateField(auto_now_add=True)
    mood = models.CharField(
        max_length=20,
        choices=[("Happy", "Happy"), ("Anxious", "Anxious"), ("Tired", "Tired"), ("Excited", "Excited")],
        null=True,  
        blank=True 
    )
    symptoms = models.TextField(blank=True, null=True)
    notes = models.TextField(blank=True, null=True)

    def __str__(self):
        return f"Journal Entry - {self.user.username if self.user else 'Anonymous'} - {self.date}"
