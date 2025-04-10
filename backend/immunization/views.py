from rest_framework import generics
from .models import ImmunizationRecord
from .serializers import ImmunizationRecordSerializer

class ImmunizationListCreateView(generics.ListCreateAPIView):
    queryset = ImmunizationRecord.objects.all()
    serializer_class = ImmunizationRecordSerializer

class ImmunizationUpdateView(generics.UpdateAPIView):
    queryset = ImmunizationRecord.objects.all()
    serializer_class = ImmunizationRecordSerializer
    lookup_field = 'id'

class ImmunizationRecordsView(generics.ListAPIView):
    queryset = ImmunizationRecord.objects.all()
    serializer_class = ImmunizationRecordSerializer