from django.urls import path
from .views import NotificationView, CounselingSessionView, MotivationalMessageView

urlpatterns = [
    path('notifications/', NotificationView.as_view(), name='notifications'),  # ✅ NEW API
    path('counseling/', CounselingSessionView.as_view(), name='counseling-sessions'),
    path('motivation/', MotivationalMessageView.as_view(), name='motivational-messages'),
]
