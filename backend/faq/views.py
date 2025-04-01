from django.shortcuts import render
from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework import status
from django.utils import timezone  # ✅ Fix import
from .serializers import FAQSerializer, ExpertQuestionSerializer
from .models import FAQ, ExpertQuestion

class FAQView(generics.ListAPIView):
    serializer_class = FAQSerializer
    permission_classes = [permissions.AllowAny]

    def get_queryset(self):
        category = self.request.query_params.get('category', None)
        if category:
            faqs = FAQ.objects.filter(category=category)
        else:
            faqs = FAQ.objects.all()
        return faqs

    def list(self, request, *args, **kwargs):
        queryset = self.get_queryset()
        if not queryset.exists():
            return Response({"message": "No FAQs available for this category."}, status=status.HTTP_404_NOT_FOUND)
        
        serializer = self.get_serializer(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

class ExpertQuestionView(generics.ListCreateAPIView):
    serializer_class = ExpertQuestionSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ExpertQuestion.objects.filter(user=self.request.user).order_by('-created_at')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

class AnswerExpertQuestionView(generics.UpdateAPIView):
    serializer_class = ExpertQuestionSerializer
    permission_classes = [permissions.IsAdminUser]
    queryset = ExpertQuestion.objects.all()

    def perform_update(self, serializer):
        serializer.save(answered_by=self.request.user, answered_at=timezone.now())
