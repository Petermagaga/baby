from rest_framework import generics, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from .models import Baby, ImmunizationRecord,BreastfeedingLog,HealthAnalytics,GrowthRecord
from .serializers import BabySerializer, ImmunizationRecordSerializer, GrowthRecordSerializer, BreastfeedingLogSerializer,HealthAnalyticsSerializer
from django.db.models import Avg, Count


class BabyListCreateView(generics.ListCreateAPIView):
    serializer_class = BabySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return Baby.objects.filter(parent=self.request.user)

    def perform_create(self, serializer):
        serializer.save(parent=self.request.user)

class ImmunizationRecordListView(generics.ListAPIView):
    serializer_class = ImmunizationRecordSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ImmunizationRecord.objects.filter(baby__parent=self.request.user)

class UpdateImmunizationStatusView(generics.UpdateAPIView):
    queryset = ImmunizationRecord.objects.all()
    serializer_class = ImmunizationRecordSerializer
    permission_classes = [permissions.IsAuthenticated]

class GrowthRecordView(generics.ListCreateAPIView):
    serializer_class = GrowthRecordSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return GrowthRecord.objects.filter(baby__parent=self.request.user)

class BreastfeedingLogView(generics.ListCreateAPIView):
    serializer_class = BreastfeedingLogSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return BreastfeedingLog.objects.filter(baby__parent=self.request.user)

class HealthAnalyticsView(generics.ListAPIView):
    serializer_class = HealthAnalyticsSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return HealthAnalytics.objects.filter(baby__parent=self.request.user)
    


class UserDashboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        user = request.user
        total_babies = Baby.objects.filter(parent=user).count()
        avg_bmi = HealthAnalytics.objects.filter(baby__parent=user).aggregate(Avg('bmi'))['bmi__avg'] or 0
        pending_vaccinations = ImmunizationRecord.objects.filter(baby__parent=user, status='pending').count()

        return Response({
            "total_babies": total_babies,
            "avg_bmi": round(avg_bmi, 2),
            "pending_vaccinations": pending_vaccinations
        })

    


