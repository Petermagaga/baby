from django.urls import path
from .views import RegisterView, LoginView, ProfileView ,UserProfileUpdateView, profile_completion

urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('profile/', UserProfileUpdateView.as_view(), name='user-profile'),
    path('profile/completion/', profile_completion, name='profile-completion'),
]
