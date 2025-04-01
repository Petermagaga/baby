from django.urls import re_path
from chat.consumers import NotificationConsumer  # Make sure this import is correct

websocket_urlpatterns = [
    re_path(r"ws/notifications/$", NotificationConsumer.as_asgi()),
]
