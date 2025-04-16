from rest_framework import generics, permissions
from .models import ChatMessage
from .serializers import ChatMessageSerializer

class ChatMessageListCreateView(generics.ListCreateAPIView):
    serializer_class = ChatMessageSerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        group_title = self.request.query_params.get('group')
        return ChatMessage.objects.filter(group_title=group_title).order_by('-timestamp')

    def perform_create(self, serializer):
        serializer.save(sender=self.request.user)
