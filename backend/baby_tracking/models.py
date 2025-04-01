from django.db import models
from django.contrib.auth import get_user_model

User = get_user_model()

class Baby(models.Model):
    parent = models.ForeignKey(User, on_delete=models.CASCADE, related_name="babies")
    name = models.CharField(max_length=100)
    date_of_birth = models.DateField()
    weight_at_birth = models.FloatField(help_text="Weight in kg")
    
    def __str__(self):
        return f"{self.name} ({self.date_of_birth})"

class ImmunizationRecord(models.Model):
    baby = models.ForeignKey(Baby, on_delete=models.CASCADE, related_name="immunizations")
    vaccine_name = models.CharField(max_length=255)
    scheduled_date = models.DateField()
    status = models.CharField(
        max_length=10,
        choices=[('pending', 'Pending'), ('completed', 'Completed')],
        default='pending'
    )

    def __str__(self):
        return f"{self.baby.name} - {self.vaccine_name} ({self.status})"
    

class GrowthRecord(models.Model):
    baby = models.ForeignKey(Baby, on_delete=models.CASCADE, related_name="growth_records")
    date = models.DateField(auto_now_add=True)
    weight = models.FloatField(help_text="Weight in kg")
    height = models.FloatField(help_text="Height in cm")
    head_circumference = models.FloatField(help_text="Head circumference in cm")

    def __str__(self):
        return f"{self.baby.name} - {self.date}"

class BreastfeedingLog(models.Model):
    baby = models.ForeignKey(Baby, on_delete=models.CASCADE, related_name="breastfeeding_logs")
    date = models.DateField(auto_now_add=True)
    duration = models.IntegerField(help_text="Duration in minutes")
    side = models.CharField(max_length=10, choices=[('left', 'Left'), ('right', 'Right'), ('both', 'Both')])

    def __str__(self):
        return f"{self.baby.name} - {self.date} - {self.duration} min"

class HealthAnalytics(models.Model):
    baby = models.ForeignKey(Baby, on_delete=models.CASCADE, related_name="health_analytics")
    bmi = models.FloatField(help_text="BMI Calculation")
    immunization_status = models.CharField(max_length=50, default="Pending")

    def __str__(self):
        return f"{self.baby.name} - {self.bmi} BMI - {self.immunization_status}"
