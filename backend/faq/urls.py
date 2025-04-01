from django.urls import path
from .views import FAQView, ExpertQuestionView, AnswerExpertQuestionView  # ✅ Remove FAQListView if it's missing

urlpatterns = [
    path('faqs/', FAQView.as_view(), name='faqs'),
    path('ask-expert/', ExpertQuestionView.as_view(), name='ask-expert'),
    path('answer-question/<int:pk>/', AnswerExpertQuestionView.as_view(), name='answer-question'),
]
