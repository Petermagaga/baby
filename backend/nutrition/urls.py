from django.urls import path
from.views import DailyMealPlanView,NutritionGuideView

urlpatterns = [
    path('nutrition-guide/', NutritionGuideView.as_view(), name='nutrition-guide'),
    path('meal-plans/', DailyMealPlanView.as_view(), name='meal-plans'),
]
