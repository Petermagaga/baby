from django.db import models
from django.contrib.auth import get_user_model
from datetime import timedelta

User = get_user_model()

class Pregnancy(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name='pregnancy')
    start_date = models.DateField()
    due_date = models.DateField()

    def __str__(self):
        return f"{self.user.username} Pregnancy - Due: {self.due_date}"

    @property
    def weeks_pregnant(self):
        return (models.DateField().to_python(str(models.functions.Now())) - self.start_date).days // 7

    @property
    def trimester(self):
        weeks = self.weeks_pregnant
        if weeks <= 13:
            return 1
        elif weeks <= 27:
            return 2
        else:
            return 3
