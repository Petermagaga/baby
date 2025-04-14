import random
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from .models import CounselingSession, MotivationalMessage
from .serializers import CounselingSessionSerializer, MotivationalMessageSerializer

class NotificationView(APIView):
    permission_classes = [IsAuthenticated]  # ✅ Require auth again

    def get(self, request):
        user = request.user

        # Get counseling sessions
        counseling_sessions = CounselingSession.objects.filter(user=user)
        counseling_data = CounselingSessionSerializer(counseling_sessions, many=True).data

        # 🔁 Randomly select 1–3 motivational messages
        all_messages = list(MotivationalMessage.objects.order_by('?')[:3])  # random 3
        motivational_data = MotivationalMessageSerializer(all_messages, many=True).data  # ✅ Fix here

        return Response({
            "counseling_sessions": counseling_data,
            "motivational_message": motivational_data,
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
