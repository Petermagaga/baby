from rest_framework import serializers
from .models import ExpertQuestion,FAQ

class FAQSerializer(serializers.ModelSerializer):
    class Meta:
        model = FAQ
        fields = '__all__'

class ExpertQuestionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ExpertQuestion
        fields = ['id', 'user', 'question', 'answer', 'answered_by', 'created_at', 'answered_at']
        read_only_fields = ['answer', 'answered_by', 'answered_at']
