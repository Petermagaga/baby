from django.urls import path
from .views import RegisterView, LoginView, ProfileView, UserProfileUpdateView, profile_completion,update_password

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('profile/', ProfileView.as_view(), name='profile'),  # View profile
    path('profile/update/', UserProfileUpdateView.as_view(), name='user-profile'),  # Update profile
    path('profile/completion/', profile_completion, name='profile-completion'),
     path('profile/update-password/', update_password, name='update-password'),
]
