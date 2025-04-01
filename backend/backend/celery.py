import os
from celery import Celery
from celery.schedules import crontab

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'backend.settings')

app = Celery('backend')
app.config_from_object('django.conf:settings', namespace='CELERY')

app.autodiscover_tasks()


app.conf.beat_schedule = {
    'send_immunization_reminders_daily': {
        'task': 'baby_tracking.tasks.send_immunization_reminders',
        'schedule': crontab(hour=8, minute=0),  # Runs every day at 8 AM
    },
}

app.conf.beat_schedule['update_bmi_daily'] = {
    'task': 'baby_tracking.tasks.update_bmi_records',
    'schedule': crontab(hour=0, minute=0),  # Runs every midnight
}

app.conf.beat_schedule = {
    'generate_daily_meal_plan': {
        'task': 'nutrition.tasks.generate_daily_meal_plan',
        'schedule': crontab(hour=6, minute=0),  # Runs every morning
    }
}