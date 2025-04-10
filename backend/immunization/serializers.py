from rest_framework import serializers
from .models import ImmunizationRecord

class ImmunizationRecordSerializer(serializers.ModelSerializer):
    class Meta:
        model = ImmunizationRecord
        fields = '__all__'
