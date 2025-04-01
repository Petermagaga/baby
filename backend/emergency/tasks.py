
from celery import shared_task
from .models import EmergencyAlert,EmergencyContact
from twilio.rest import Client
from django.conf import settings
from .utils import send_sms

@shared_task
def send_emergency_notification(alert_id):
    alert = EmergencyAlert.objects.get(id=alert_id)
    user = alert.user
    contacts = EmergencyContact.objects.filter(user=user, is_primary=True)

    message = f"🚨 Emergency Alert! {user.username} needs urgent help: {alert.alert_message}"

    for contact in contacts:
        send_sms(contact.phone_number, message)  # Function to send SMS

    return f"Emergency notification sent for {user.username}"
