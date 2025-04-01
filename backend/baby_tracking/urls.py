from django.urls import path
from .views import BabyListCreateView, ImmunizationRecordListView, UpdateImmunizationStatusView,GrowthRecordView,BreastfeedingLogView,HealthAnalyticsView, UserDashboardView

urlpatterns = [
    path('babies/', BabyListCreateView.as_view(), name='baby-list'),
    path('immunizations/', ImmunizationRecordListView.as_view(), name='immunization-list'),
    path('immunizations/<int:pk>/', UpdateImmunizationStatusView.as_view(), name='update-immunization'),
    path('growth/', GrowthRecordView.as_view(), name='growth-records'),
    path('breastfeeding/', BreastfeedingLogView.as_view(), name='breastfeeding-logs'),
    path('health-analytics/', HealthAnalyticsView.as_view(), name='health-analytics'),
    path('dashboard/', UserDashboardView.as_view(), name='user-dashboard'),


]

