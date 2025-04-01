from rest_framework import serializers
from .models import Baby, ImmunizationRecord, GrowthRecord,BreastfeedingLog,HealthAnalytics

class BabySerializer(serializers.ModelSerializer):
    class Meta:
        model = Baby
        fields = ['id', 'parent', 'name', 'date_of_birth', 'weight_at_birth']

class ImmunizationRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = ImmunizationRecord
        fields = ['id', 'baby', 'vaccine_name', 'scheduled_date', 'status']


class GrowthRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = GrowthRecord
        fields = ['id', 'baby', 'date', 'weight', 'height', 'head_circumference']

class BreastfeedingLogSerializer(serializers.ModelSerializer):
    class Meta:
        model = BreastfeedingLog
        fields = ['id', 'baby', 'date', 'duration', 'side']

class HealthAnalyticsSerializer(serializers.ModelSerializer):
    class Meta:
        model = HealthAnalytics
        fields = ['id', 'baby', 'bmi', 'immunization_status']

class UserDashboardSerializer(serializers.Serializer):
    total_babies = serializers.IntegerField()
    avg_bmi = serializers.FloatField()
    pending_vaccinations = serializers.IntegerField()


