from django.contrib.auth.models import AbstractUser
from django.db import models
from django.contrib.auth.hashers import make_password
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework import status

def user_profile_upload_path(instance, filename):
    """Upload profile pictures to 'profile_pics/user_id/' folder"""
    return f'profile_pics/{instance.id}/{filename}'

class UserProfile(AbstractUser):
    age = models.IntegerField(null=True, blank=True)
    health_conditions = models.TextField(blank=True)
    location = models.CharField(max_length=255, blank=True)
    job_type = models.CharField(max_length=255, blank=True)
    profile_picture = models.ImageField(upload_to=user_profile_upload_path, blank=True, null=True)

    groups = models.ManyToManyField(
        'auth.Group',
        related_name='userprofile_groups', 
        blank=True
    )
    user_permissions = models.ManyToManyField(
        'auth.Permission',
        related_name='userprofile_permissions',  
        blank=True
    )

    def profile_completion_percentage(self):
        fields = [self.age, self.health_conditions, self.location, self.job_type, self.profile_picture]
        filled_fields = sum(1 for field in fields if field)
        total_fields = len(fields)
        return int((filled_fields / total_fields) * 100) if total_fields > 0 else 0

    def __str__(self):
        return self.username


class UpdatePasswordView(APIView):
    permission_classes = [IsAuthenticated]  # Ensure authentication

    def post(self, request):
        user = request.user
        new_password = request.data.get("new_password")

        if not new_password:
            return Response({"error": "Password is required"}, status=status.HTTP_400_BAD_REQUEST)

        if len(new_password) < 8:
            return Response({"error": "Password too short"}, status=status.HTTP_400_BAD_REQUEST)

        user.set_password(new_password)  # Use Django's built-in method
        user.save()

        return Response({"message": "Password updated successfully"}, status=status.HTTP_200_OK)
