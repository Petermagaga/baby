from .tasks import send_emergency_notification

from rest_framework import generics,permissions
from django.shortcuts import render
from .serializers import EmergencyAlertSerializer, EmergencyContactSerializer
from .models import EmergencyAlert,EmergencyContact


class EmergencyContactView(generics.ListCreateAPIView):
    serializer_class = EmergencyContactSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return EmergencyContact.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class EmergencyAlertView(generics.CreateAPIView):
    serializer_class = EmergencyAlertSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        alert = serializer.save(user=self.request.user)
        send_emergency_notification(alert)  # Trigger notification


