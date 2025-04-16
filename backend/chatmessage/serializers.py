# serializers.py
from rest_framework import serializers
from .models import ChatMessage

class ChatMessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.SerializerMethodField()

    class Meta:
        model = ChatMessage
        fields = ['id', 'sender', 'sender_name', 'message', 'group_title', 'timestamp']
        read_only_fields = ['id', 'sender', 'sender_name', 'timestamp']

    def get_sender_name(self, obj):
        return obj.sender.username
