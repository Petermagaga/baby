from rest_framework import generics
from .serializers import PregnancyJournalSerializer
from .models import PregnancyJournal
from rest_framework.permissions import IsAuthenticated

permission_classes = [IsAuthenticated]
class PregnancyJournalView(generics.ListCreateAPIView):
    queryset = PregnancyJournal.objects.all().order_by('-date')  # 👈 show all
    serializer_class = PregnancyJournalSerializer
    permission_classes = [IsAuthenticated] 
    
    def perform_create(self, serializer):
        if self.request.user.is_authenticated:
            serializer.save(user=self.request.user)  
        else:
            serializer.save()