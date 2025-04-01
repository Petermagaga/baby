from django.urls import path
from .views import EmergencyAlertView, EmergencyContactView

urlpatterns = [
    path('contacts/', EmergencyContactView.as_view(), name='emergency-contacts'),
    path('send-alert/', EmergencyAlertView.as_view(), name='send-alert'),
]
