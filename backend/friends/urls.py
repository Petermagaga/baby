from django.urls import path
from .views import find_matched_users

app_name = "users"  # Helps in namespacing

urlpatterns = [
    path("match-users/", find_matched_users, name="match_users"),
]
