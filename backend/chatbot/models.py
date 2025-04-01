from django.db import models
from django.contrib.auth import get_user_model

User=get_user_model()

class ChatbotMessage(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name="chatbot_messages")
    message = models.TextField()
    response = models.TextField()
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Chatbot Message from {self.user.username} - {self.timestamp}"
