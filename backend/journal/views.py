from rest_framework import generics
from .serializers import PregnancyJournalSerializer
from .models import PregnancyJournal

class PregnancyJournalView(generics.ListCreateAPIView):
    queryset = PregnancyJournal.objects.all().order_by('-date')  # 👈 show all
    serializer_class = PregnancyJournalSerializer
    permission_classes = []  # 👈 remove authentication

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)  
