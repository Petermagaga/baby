from rest_framework import serializers
from .models import NutritionGuide,DailyMealPlan

class NutritionGuideSerializer(serializers.ModelSerializer):
    class Meta:
        model = NutritionGuide
        fields = '__all__'

class DailyMealPlanSerializer(serializers.ModelSerializer):
    class Meta:
        model = DailyMealPlan
        fields = ['id', 'user', 'date', 'breakfast', 'lunch', 'dinner', 'snacks']
