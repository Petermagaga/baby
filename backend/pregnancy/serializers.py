from rest_framework import serializers
from .models import Pregnancy
from datetime import timedelta, date

class PregnancySerializer(serializers.ModelSerializer):
    weeks_pregnant = serializers.SerializerMethodField()
    trimester = serializers.SerializerMethodField()

    class Meta:
        model = Pregnancy
        fields = ['id', 'start_date', 'due_date', 'weeks_pregnant', 'trimester']

    def get_weeks_pregnant(self, obj):
        return (date.today() - obj.start_date).days // 7

    def get_trimester(self, obj):
        weeks = self.get_weeks_pregnant(obj)
        if weeks <= 13:
            return 1
        elif weeks <= 27:
            return 2
        else:
            return 3

    def create(self, validated_data):
        # If due_date is not passed from frontend, calculate it
        if 'due_date' not in validated_data:
            validated_data['due_date'] = validated_data['start_date'] + timedelta(days=280)
        return super().create(validated_data)
