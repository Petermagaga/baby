from rest_framework import serializers
from .models import HealthProfile,HealthRecommendation

class HealthProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthProfile
        fields = '__all__'
        read_only_fields = ['user']

class HealthRecommendationSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthRecommendation
        fields = '__all__'
        read_only_fields = ['user', 'created_at']
