from rest_framework import generics,permissions
from django.shortcuts import render

from .serializers import NutritionGuideSerializer,DailyMealPlanSerializer
from .models import NutritionGuide,DailyMealPlan

class NutritionGuideView(generics.ListAPIView):
    serializer_class = NutritionGuideSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        trimester = self.request.query_params.get('trimester')
        if trimester:
            return NutritionGuide.objects.filter(trimester=trimester)
        return NutritionGuide.objects.all()

class DailyMealPlanView(generics.ListCreateAPIView):
    serializer_class = DailyMealPlanSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return DailyMealPlan.objects.filter(user=self.request.user).order_by('-date')
