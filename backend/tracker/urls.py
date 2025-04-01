from django.urls import path
from .views import PregnancyStageListView,NotificationListView

urlpatterns = [
    path('stages/', PregnancyStageListView.as_view(), name='pregnancy-stages'),
    path('notifications/', NotificationListView.as_view(), name='notifications'),
]
