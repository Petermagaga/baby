from rest_framework import generics, permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView
from .models import Pregnancy
from .serializers import PregnancySerializer
from datetime import timedelta, date

class CreatePregnancyView(generics.CreateAPIView):
    serializer_class = PregnancySerializer
    permission_classes = [permissions.IsAuthenticated]

    def perform_create(self, serializer):
        if serializer.is_valid():
            Pregnancy.objects.filter(user=self.request.user).delete()
            serializer.save(user=self.request.user)
        else:
            print(serializer.errors)

class GetPregnancyView(generics.RetrieveAPIView):
    serializer_class = PregnancySerializer
    permission_classes = [permissions.IsAuthenticated]

    def get_object(self):
        return Pregnancy.objects.get(user=self.request.user)


class DeletePregnancyView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def delete(self, request, *args, **kwargs):
        try:
            pregnancy = Pregnancy.objects.get(user=request.user)
            pregnancy.delete()
            return Response({"detail": "Pregnancy deleted."}, status=status.HTTP_204_NO_CONTENT)
        except Pregnancy.DoesNotExist:
            return Response({"detail": "No pregnancy found."}, status=status.HTTP_404_NOT_FOUND)
