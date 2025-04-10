
from rest_framework import serializers
from .models import NutritionAdvice

class NutritionAdviceSerializer(serializers.ModelSerializer):
    class Meta:
        model = NutritionAdvice
        fields = ['weight', 'advice']
