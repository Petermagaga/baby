from django.urls import path
from .views import PregnancyJournalView

urlpatterns = [
    path('entries/', PregnancyJournalView.as_view(), name='journal-entries'),
]
