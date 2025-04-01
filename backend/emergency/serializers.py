from rest_framework import serializers
from .models import EmergencyAlert,EmergencyContact

class EmergencyContactSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyContact
        fields = '__all__'
        read_only_fields = ['user']

class EmergencyAlertSerializer(serializers.ModelSerializer):
    class Meta:
        model = EmergencyAlert
        fields = ['id', 'user', 'alert_message', 'sent_at']
        read_only_fields = ['user', 'sent_at']
