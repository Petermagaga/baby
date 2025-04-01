from django.urls import path
from .views import (
    HealthProfileView,
    HealthRecommendationListView,
    LatestHealthRecommendationView,
    GenerateHealthRecommendationView
)

urlpatterns = [
    path('profile/', HealthProfileView.as_view(), name='health-profile'),
    path('recommendations/', HealthRecommendationListView.as_view(), name='health-recommendations'),
    path('recommendations/latest/', LatestHealthRecommendationView.as_view(), name='latest-health-recommendation'),
    path('recommendations/generate/', GenerateHealthRecommendationView.as_view(), name='generate-health-recommendation'),
]
