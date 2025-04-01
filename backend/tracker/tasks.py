from celery import shared_task
from django.utils.timezone import now
from .models import PregnancyStage, Notification
from django.contrib.auth import get_user_model

User = get_user_model()

@shared_task
def send_weekly_notifications():
    users = User.objects.all()
    for user in users:
        # Get the user's current pregnancy week
        pregnancy_stage = PregnancyStage.objects.filter(user=user).order_by('-week').first()
        if pregnancy_stage:
            message = f"Week {pregnancy_stage.week} Update: {pregnancy_stage.baby_development}. Tips: {pregnancy_stage.health_tips}"
        else:
            message = "Welcome! Please update your pregnancy details for weekly tips."

        # Save notification to database
        Notification.objects.create(user=user, message=message, sent=True)

    return "Weekly Notifications Sent"
