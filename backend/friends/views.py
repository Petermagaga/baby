from rest_framework.decorators import api_view, permission_classes
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.contrib.auth.models import User
from .models import UserProfile, calculate_distance


@api_view(["GET"])
@permission_classes([IsAuthenticated])
def find_matched_users(request):
    current_user = request.user
    try:
        current_profile = UserProfile.objects.get(user=current_user)
    except UserProfile.DoesNotExist:
        return Response({"error": "User profile not found"}, status=404)

    if not current_profile.latitude or not current_profile.longitude:
        return Response({"error": "Location not set in profile"}, status=400)

    nearby_users = []
    all_users = UserProfile.objects.exclude(user=current_user)

    for user in all_users:
        if not user.latitude or not user.longitude:
            continue

        distance = calculate_distance(
            current_profile.latitude, current_profile.longitude,
            user.latitude, user.longitude
        )

        user_interests = set(user.interests.split(",")) if user.interests else set()
        current_interests = set(current_profile.interests.split(",")) if current_profile.interests else set()

        common_interests = user_interests & current_interests

        if distance <= 10 and common_interests:  # Within 10km & has common interests
            nearby_users.append({
                "id": user.user.id,
                "username": user.user.username,
                "distance_km": round(distance, 2),
                "common_interests": list(common_interests),
            })

    return Response(nearby_users, status=200)
