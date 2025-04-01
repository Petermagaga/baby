from rest_framework import generics, permissions
from rest_framework.views import APIView
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .models import HealthProfile, HealthRecommendation
from .serializers import HealthProfileSerializer, HealthRecommendationSerializer
import random


# 🔹 Health Profile View (Public Access)
class HealthProfileView(generics.RetrieveUpdateAPIView):
    serializer_class = HealthProfileSerializer
    permission_classes = [permissions.AllowAny]  # ✅ Public Access

    def get_object(self):
        return HealthProfile.objects.first()  # ✅ Return first profile (Demo Purpose)


# 🔹 Fetch All Health Recommendations (Public Access)
class HealthRecommendationListView(APIView):
    permission_classes = [permissions.AllowAny]  # ✅ Public Access

    def get(self, request):
        recommendations = HealthRecommendation.objects.all().order_by('-created_at')  # ✅ Return all recommendations
        serializer = HealthRecommendationSerializer(recommendations, many=True)
        return Response(serializer.data)


# 🔹 Fetch the Latest Health Recommendation (Public Access)
class LatestHealthRecommendationView(APIView):
    permission_classes = [permissions.AllowAny]  # ✅ Public Access

    def get(self, request):
        latest_recommendation = HealthRecommendation.objects.order_by('-created_at').first()  # ✅ Get latest
        if latest_recommendation:
            serializer = HealthRecommendationSerializer(latest_recommendation)
            return Response(serializer.data)
        return Response({"message": "No recommendations available."})


# 🔹 Generate & Save a New Health Recommendation (Public Access)
class GenerateHealthRecommendationView(APIView):
    permission_classes = [permissions.AllowAny]  # ✅ Public Access

    def post(self, request):
        user_profile = HealthProfile.objects.first()  # ✅ Use the first available profile
        new_recommendation = generate_recommendation(user_profile)
        recommendation = HealthRecommendation.objects.create(recommendation_text=new_recommendation)  # ✅ No user needed
        serializer = HealthRecommendationSerializer(recommendation)
        return Response(serializer.data)


# 🔹 Generate Personalized Recommendation
def generate_recommendation(profile):
    base_recommendations = [
        "Maintain a balanced diet rich in proteins, vitamins, and minerals.",
        "Stay hydrated and drink at least 8 glasses of water daily.",
        "Engage in light exercises like prenatal yoga or walking.",
        "Get enough sleep to reduce stress and promote baby’s development."
    ]

    # 🔹 Personalize based on health conditions
    if profile and profile.pre_existing_conditions:
        conditions = profile.pre_existing_conditions.lower()
        if "diabetes" in conditions:
            base_recommendations.append("Monitor blood sugar levels and avoid high-sugar foods.")
        if "hypertension" in conditions:
            base_recommendations.append("Reduce salt intake and practice relaxation techniques.")

    return random.choice(base_recommendations)
