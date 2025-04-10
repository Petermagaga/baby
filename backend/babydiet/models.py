from django.db import models

class NutritionAdvice(models.Model):
    weight = models.PositiveIntegerField(unique=True) 
    advice = models.TextField()

    def __str__(self):
        return f"{self.weight}kg - Advice"