from django.urls import path
from .views import SendFriendRequestView, FriendRequestListView,ChatMessageListView,SendMessageView

urlpatterns = [
    path('send-request/', SendFriendRequestView.as_view(), name='send-friend-request'),
    path('requests/', FriendRequestListView.as_view(), name='friend-requests'),
  path('messages/', ChatMessageListView.as_view(), name='chat-messages'),
    path('send-message/', SendMessageView.as_view(), name='send-message'),
]
