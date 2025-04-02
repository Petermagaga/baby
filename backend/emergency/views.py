from .tasks import send_emergency_notification

from rest_framework import generics
from django.shortcuts import render
from .serializers import EmergencyAlertSerializer, EmergencyContactSerializer
from .models import EmergencyAlert, EmergencyContact

class EmergencyContactView(generics.ListCreateAPIView):
    serializer_class = EmergencyContactSerializer

    def get_queryset(self):
        return EmergencyContact.objects.all()

    def perform_create(self, serializer):
        serializer.save()

class EmergencyAlertView(generics.CreateAPIView):
    serializer_class = EmergencyAlertSerializer

    def perform_create(self, serializer):
        alert = serializer.save()
        send_emergency_notification(alert)  # Trigger notification
