from django.urls import path
from .views import CreatePregnancyView, GetPregnancyView, DeletePregnancyView
from nutrition.views import NutritionGuideView, DailyMealPlanView

urlpatterns = [
    path('create/', CreatePregnancyView.as_view(), name='create-pregnancy'),
    path('', GetPregnancyView.as_view(), name='get-pregnancy'),
    path('pregnancy/delete/', DeletePregnancyView.as_view(), name='delete-pregnancy'),
    
    path('nutrition-guide/', NutritionGuideView.as_view(), name='nutrition-guide'),
    path('meal-plans/', DailyMealPlanView.as_view(), name='meal-plans'),
]
