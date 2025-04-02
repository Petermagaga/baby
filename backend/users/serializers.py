from rest_framework import serializers
from django.contrib.auth import get_user_model
from rest_framework_simplejwt.tokens import RefreshToken

User = get_user_model()

from .models import UserProfile

class UserProfileSerializer(serializers.ModelSerializer):
    class Meta:
        model = UserProfile
        fields = ['id', 'username', 'email', 'age', 'health_conditions', 'location', 'job_type', 'profile_picture']


class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'age', 'health_conditions', 'location', 'job_type','profile_picture']

class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True)

    class Meta:
        model = User
        fields = ['username', 'email', 'password', 'age', 'health_conditions', 'location', 'job_type']

    def create(self, validated_data):
        user = User.objects.create_user(**validated_data)
        return user

class LoginSerializer(serializers.Serializer):
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)

    def validate(self, data):
        user = User.objects.filter(username=data['username']).first()
        if user and user.check_password(data['password']):
            refresh = RefreshToken.for_user(user)
            return {'refresh': str(refresh), 'access': str(refresh.access_token)}
        raise serializers.ValidationError("Invalid credentials")

class UpdatePasswordSerializer(serializers.Serializer):
    new_password = serializers.CharField(write_only=True, min_length=8)

    def validate_new_password(self, value):
        """Ensure password meets security requirements."""
        if len(value) < 8:
            raise serializers.ValidationError("Password must be at least 8 characters long.")
        return value