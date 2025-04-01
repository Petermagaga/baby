from rest_framework import generics,permissions
from django.shortcuts import render
from .serializers import PregnancyJournalSerializer
from .models import PregnancyJournal

class PregnancyJournalView(generics.ListCreateAPIView):
    serializer_class = PregnancyJournalSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return PregnancyJournal.objects.filter(user=self.request.user).order_by('-date')

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

