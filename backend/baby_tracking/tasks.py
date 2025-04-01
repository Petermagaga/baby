from celery import shared_task
from django.utils.timezone import now
from .models import ImmunizationRecord,HealthAnalytics,Baby
from django.core.mail import send_mail

@shared_task
def send_immunization_reminders():
    today = now().date()
    upcoming_vaccines = ImmunizationRecord.objects.filter(scheduled_date=today, status='pending')

    for record in upcoming_vaccines:
        parent_email = record.baby.parent.email
        send_mail(
            subject="Immunization Reminder",
            message=f"Reminder: Your baby {record.baby.name} has an upcoming vaccination: {record.vaccine_name} scheduled for today.",
            from_email="noreply@yourapp.com",
            recipient_list=[parent_email],)


@shared_task
def update_bmi_records():
    today = now().date()
    babies = Baby.objects.all()

    for baby in babies:
        latest_growth = baby.growth_records.order_by('-date').first()
        if latest_growth:
            height_m = latest_growth.height / 100  # Convert cm to meters
            bmi = latest_growth.weight / (height_m ** 2)
            
            HealthAnalytics.objects.update_or_create(
                baby=baby,
                defaults={'bmi': round(bmi, 2)}
            )
