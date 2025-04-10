# babydiet/urls.py
from django.urls import path
from .views import BabyNutritionAdviceView

urlpatterns = [
    path('api/nutrition-guide/', BabyNutritionAdviceView.as_view(), name='baby-nutrition-guide'),
]
