from rest_framework import serializers
from .models import MotivationalMessage,CounselingSession

class CounselingSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = CounselingSession
        fields = '__all__'
        read_only_fields = ['user', 'status']

class MotivationalMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = MotivationalMessage
        fields = '__all__'
