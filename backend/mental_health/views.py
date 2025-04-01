from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import CounselingSession, MotivationalMessage
from .serializers import CounselingSessionSerializer, MotivationalMessageSerializer

class NotificationView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        user = request.user
        
        # Get the user's counseling sessions
        counseling_sessions = CounselingSession.objects.filter(user=user)
        counseling_data = CounselingSessionSerializer(counseling_sessions, many=True).data

        # Get the latest motivational message
        latest_message = MotivationalMessage.objects.order_by('-created_at').first()
        motivational_message = MotivationalMessageSerializer(latest_message).data if latest_message else None

        return Response({
            "counseling_sessions": counseling_data,
            "motivational_message": motivational_message
        })

class CounselingSessionView(APIView):  
    permission_classes = [IsAuthenticated]

    def get(self, request):
        sessions = CounselingSession.objects.filter(user=request.user)
        serializer = CounselingSessionSerializer(sessions, many=True)
        return Response(serializer.data)

# ✅ Add This Missing View
class MotivationalMessageView(APIView):  
    permission_classes = [IsAuthenticated]

    def get(self, request):
        messages = MotivationalMessage.objects.all().order_by('-created_at')[:10]  # Get latest 10 messages
        serializer = MotivationalMessageSerializer(messages, many=True)
        return Response(serializer.data)
