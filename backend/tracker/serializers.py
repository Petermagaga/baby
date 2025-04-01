from rest_framework import serializers
from .models import PregnancyStage
from .models import Notification

class PregnancyStageSerializer(serializers.ModelSerializer):
    class Meta:
        model = PregnancyStage
        fields = ['id', 'week', 'symptoms', 'baby_development', 'health_tips', 'created_at']


class NotificationSerializer(serializers.ModelSerializer):
    class Meta:
        model = Notification
        fields = ['id', 'message', 'created_at', 'sent']
