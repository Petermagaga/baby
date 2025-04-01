from rest_framework import generics, permissions
from rest_framework.permissions import IsAuthenticated
from rest_framework.exceptions import ValidationError
from .models import FriendRequest
from django.contrib.auth import get_user_model
from .serializers import FriendRequestSerializer, ChatMessageSerializer,ChatMessage,ChatRequestSerializer

User = get_user_model()

class SendFriendRequestView(generics.CreateAPIView):
    serializer_class = FriendRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        receiver_id = self.request.data.get('receiver')
        receiver = User.objects.get(id=receiver_id)
        serializer.save(sender=self.request.user, receiver=receiver)
        
        if self.request.user == receiver:
                raise ValidationError({"receiver": "You cannot send a request to yourself."})

        serializer.save(sender=self.request.user)


class FriendRequestListView(generics.ListAPIView):
    serializer_class = FriendRequestSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return FriendRequest.objects.filter(receiver=self.request.user, status='pending')

class ChatMessageListView(generics.ListAPIView):
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        return ChatMessage.objects.filter(receiver=self.request.user)

from rest_framework import generics, permissions
from rest_framework.response import Response
from rest_framework.exceptions import ValidationError
from django.contrib.auth import get_user_model
from .serializers import ChatMessageSerializer

User = get_user_model()  

class SendMessageView(generics.CreateAPIView):
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        receiver_id = self.request.data.get('receiver')
        sender=self.request.user

        print(f"Sender ID: {sender.id}, Receiver ID: {receiver_id}")


        if not receiver_id:
            raise ValidationError({"receiver": "This field is required."})

        try:
            receiver = User.objects.get(id=receiver_id)
        except User.DoesNotExist:
            raise ValidationError({"receiver": f"User with ID {receiver_id} does not exist."})

        serializer.save(sender=self.request.user, receiver=receiver)


class ChatRequestView(generics.CreateAPIView):
    serializer_class = ChatRequestSerializer
    permission_classes = [IsAuthenticated]  # Ensure user is logged in

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)  # Set sender automatically
