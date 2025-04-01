from rest_framework import generics, status
from rest_framework.response import Response
from rest_framework.decorators import api_view
from django.contrib.auth import get_user_model
from django.contrib.auth.hashers import make_password
from rest_framework.views import APIView
from .models import UserProfile
from .serializers import UserSerializer, RegisterSerializer, LoginSerializer, UserProfileSerializer

User = get_user_model()


class UserProfileUpdateView(generics.RetrieveUpdateAPIView):
    queryset = UserProfile.objects.all()
    serializer_class = UserProfileSerializer

    def get_object(self):
        return self.request.user


class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    serializer_class = RegisterSerializer


class LoginView(APIView):
    def post(self, request):
        serializer = LoginSerializer(data=request.data)
        if serializer.is_valid():
            return Response(serializer.validated_data, status=status.HTTP_200_OK)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)


class ProfileView(generics.RetrieveUpdateAPIView):
    queryset = User.objects.all()
    serializer_class = UserSerializer

    def get_object(self):
        return self.request.user


@api_view(["POST"])
def update_password(request):
    data = request.data
    username = data.get("username")  # Username must be provided
    new_password = data.get("new_password")

    if not username or not new_password:
        return Response({"error": "Username and password are required!"}, status=400)

    try:
        user = User.objects.get(username=username)
        user.password = make_password(new_password)
        user.save()
        return Response({"message": "Password updated successfully!"}, status=200)
    except User.DoesNotExist:
        return Response({"error": "User not found!"}, status=404)


@api_view(['GET'])
def profile_completion(request):
    username = request.query_params.get("username")  # Accept username as a query param

    if not username:
        return Response({"error": "Username is required!"}, status=400)

    try:
        profile = UserProfile.objects.get(username=username)
        completion_percentage = profile.profile_completion_percentage()
        return Response({"completion_percentage": completion_percentage})
    except UserProfile.DoesNotExist:
        return Response({"error": "Profile not found!"}, status=404)
