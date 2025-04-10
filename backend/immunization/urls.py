from django.urls import path
from .views import ImmunizationListCreateView, ImmunizationUpdateView,ImmunizationRecordsView

urlpatterns = [
    path('', ImmunizationListCreateView.as_view(), name='immunization-list-create'),
    path('update/<int:id>/', ImmunizationUpdateView.as_view(), name='immunization-update'),
    path('records/', ImmunizationRecordsView.as_view(), name='immunization-records'),
]
