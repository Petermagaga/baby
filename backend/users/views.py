from rest_framework import generics, status, viewsets
from rest_framework.response import Response
from rest_framework.decorators import api_view
from rest_framework.views import APIView
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password
from django.shortcuts import get_object_or_404

from rest_framework_simplejwt.tokens import RefreshToken  # 🔐 For JWT

from .models import UserProfile
from .serializers import (
    UserSerializer,
    UserRegisterSerializer,
    LoginSerializer,
    UserProfileSerializer
)

User = get_user_model()


def get_tokens_for_user(user):
    """Generate JWT tokens for a user."""
    refresh = RefreshToken.for_user(user)
    return {
        'refresh': str(refresh),
        'access': str(refresh.access_token),
    }


class RegisterView(APIView):
    """
    Register a new user.
    """
    def post(self, request):
        serializer = UserRegisterSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.save()
            tokens = get_tokens_for_user(user)
            return Response({
                'success': True,
                'message': 'User registered successfully',
                'tokens': tokens
            }, status=status.HTTP_201_CREATED)
        return Response({
            'success': False,
            'message': 'Registration failed',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


class LoginView(APIView):
    """
    Authenticate user and return JWT tokens.
    """
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            user = serializer.validated_data['user']
            tokens = get_tokens_for_user(user)
            return Response({
                'success': True,
                'message': 'Login successful',
                'tokens': tokens,
                'user': UserSerializer(user).data
            }, status=status.HTTP_200_OK)
        return Response({
            'success': False,
            'message': 'Invalid credentials',
            'errors': serializer.errors
        }, status=status.HTTP_400_BAD_REQUEST)


class UserProfileUpdateView(generics.RetrieveUpdateAPIView):
    """
    Retrieve or update user profile by username.
    """
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer

    def get_object(self):
        username = self.request.query_params.get('username') or self.request.data.get('username')
        return get_object_or_404(UserProfile, username=username)


class ProfileView(generics.RetrieveAPIView):
    """
    Retrieve user info by username.
    """
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_object(self):
        username = self.request.query_params.get('username') or self.request.data.get('username')
        return get_object_or_404(User, username=username)


@api_view(["POST"])
def update_password(request):
    """
    Reset password using username (unauthenticated).
    """
    username = request.data.get("username")
    new_password = request.data.get("new_password")

    if not username or not new_password:
        return Response({"error": "Username and new password are required!"}, status=400)

    try:
        user = User.objects.get(username=username)
        user.password = make_password(new_password)
        user.save()
        return Response({"message": "Password updated successfully!"}, status=200)
    except User.DoesNotExist:
        return Response({"error": "User not found!"}, status=404)


@api_view(['GET'])
def profile_completion(request):
    """
    Return profile completion percentage.
    """
    username = request.query_params.get("username")
    if not username:
        return Response({"error": "Username is required!"}, status=400)

    try:
        profile = UserProfile.objects.get(username=username)
        completion_percentage = profile.profile_completion_percentage()
        return Response({"completion_percentage": completion_percentage})
    except UserProfile.DoesNotExist:
        return Response({"error": "Profile not found!"}, status=404)


class UserProfileViewSet(viewsets.ModelViewSet):
    """
    ViewSet for full CRUD operations on user profiles.
    """
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer
