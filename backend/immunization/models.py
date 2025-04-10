from django.db import models

class ImmunizationRecord(models.Model):
    vaccine_name = models.CharField(max_length=255)
    date_given = models.DateField()
    next_due_date = models.DateField(null=True, blank=True)

    def __str__(self):
        return self.vaccine_name
