from django.contrib.auth.models import User
from django.db import models
from math import radians, sin, cos, sqrt, atan2


class UserProfile(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE)
    age = models.IntegerField(null=True, blank=True)
    location = models.CharField(max_length=255, null=True, blank=True)  # City or GPS coordinates
    latitude = models.FloatField(null=True, blank=True)  # User latitude
    longitude = models.FloatField(null=True, blank=True)  # User longitude
    interests = models.TextField(blank=True)  # Comma-separated interests
    profile_picture = models.ImageField(upload_to="profile_pics/", null=True, blank=True)

    def get_coordinates(self):
        """Returns a tuple of (latitude, longitude)"""
        return (self.latitude, self.longitude) if self.latitude and self.longitude else None

    def __str__(self):
        return self.user.username


def calculate_distance(lat1, lon1, lat2, lon2):
    """Calculate Haversine distance (great-circle distance) between two points"""
    R = 6371  # Earth’s radius in km
    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    
    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c  # Distance in km
